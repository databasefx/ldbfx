using Gtk;
using Gee;

/*
 *
 *
 * NoteBook Table
 * 
 *
 **/
 [GtkTemplate (ui="/cn/navclub/dbfx/ui/notebook-table.xml")]
public class NotebookTable : Box, TabService
{
    private int page;
    private int size;
    private bool view;
    public string path;
    private int64 total;
    private string pathVal;
    private NotebookTab notebookTab;
    private MultiSelection selection;
    private GLib.ListStore listStore;
    private SignalListItemFactory factory;

    private Gee.List<string> list = null;
    //缓存当前列属性
    private Gee.List<ColumnViewColumn> columns;
    
    [GtkChild]
    private unowned Label rowNLum;
    [GtkChild]
    private unowned ColumnView tableView;


    public NotebookTable(string path,string pathVal,bool view)
    {
        this.page = 0;
        this.total = 0;
        this.size = 200;
        this.view = view;
        this.path = path;
        this.pathVal = pathVal;
        this.list = new ArrayList<string>();
        this.factory = new SignalListItemFactory();
        this.columns = new ArrayList<ColumnViewColumn>();
        this.listStore = new GLib.ListStore(typeof(TableRowMeta));
        this.selection = new MultiSelection(this.listStore);
        this.notebookTab = new NotebookTab( view ? "dbfx-view" : "dbfx-table" , getPosVal(pathVal,-1) , this, true );

        this.factory.bind.connect(listItem=>{
            var item = listItem.item as TableRowMeta;
            (listItem.child as Label).label = item.getStrValue();
        });
        this.factory.setup.connect((listItem)=>{
            listItem.child = new Label("");
        });

        this.tableView.model = this.selection;

        this.loadTableData(1);
    }

    [GtkCallback]
    private void nextPage()
    {
        this.loadTableData(1);
    }

    [GtkCallback]
    private void prePage()
    {
        this.loadTableData(-1);
    }

    [GtkCallback]
    private void refresh()
    {
        this.loadTableData(0);
    }

    private async void loadTableData(int offset)
    {
        var tab = this.tab();
        
        if(tab.loading)
        {
            return;
        }

        var temp = (this.page + offset);

        this.page = (temp <= 0 ? 1 : temp);

        //清除先前数据
        this.listStore.remove_all();

        tab.loadStatus(true);

        var uuid = this.getPosVal(this.path,0);
        var table = this.getPosVal(this.pathVal,-1);
        var schema = this.getPosVal(this.pathVal,-3);

        FXError error = null;
        Gee.List<TableColumnMeta> columns = null;
        SourceFunc callback = loadTableData.callback;

        int64 total = 0;

        var work = AsyncWork.create(()=>{
            var connect = Application.getConnection(uuid);
            try
            {
                total = connect.count(schema,table);
                columns = connect.tableColumns(schema,table);
                list = connect.pageQuery(schema,table,this.page,this.size);
            }
            catch(FXError e)
            {
                error = e;
            }
            finally
            {
                connect.close();
                Idle.add(callback);
            }
        });
        work.execute();
        
        yield;
        
        this.rowNLum.label = "%s %s".printf(total.to_string(),_("_Rows"));

        if(error == null)
        {
            var colNum = columns.size;

            if(colNum > 0)
            {
                this.diffCol(columns);

                var dataSize  = this.list.size;
                var rowNum    = dataSize / colNum;
                for (int j = 0; j < rowNum; j++)
                {
                    var _offset = j * colNum;
                    var array  = new string[colNum];
                    for (int i = _offset; i < _offset + colNum; i++)
                    {
                        array[i-_offset] = this.list.get(i);
                        //一次性加载10条数据
                        if(j % 10 == 0)
                        {
                            Idle.add(callback);
                            yield;
                        }
                    }
                    this.listStore.append(new TableRowMeta(array));
                }
            }
        }
        else
        {
            FXAlert.error(_("_Loading fail"),error.message);
        }

        this.total = total;

        tab.loadStatus(false);

        this.list.clear();
    }

    /**
     *
     *
     * 差分检查列
     *
     **/
    private void diffCol(Gee.List<TableColumnMeta> list)
    {
        var index = 0;
        
        var newSize = list.size;
        var size = this.columns.size;
        
        foreach(var column in list)
        {
            var name = column.name;
            var exist = (size != 0 && size >= newSize);
            if(exist)
            {
                this.columns.get(index).title = name;
            }
            else
            {
                var ccolumn = new ColumnViewColumn
                (
                    name,
                    factory
                );
            
                ccolumn.set_resizable(true);
                this.columns.add(ccolumn);
                this.tableView.append_column(ccolumn);
            }
            index++;
        }

        //移除多余列
        for(var i = (size - 1) ; i >= newSize ; i--)
        {
            var column = this.columns.remove_at(i);
            this.tableView.remove_column(column);
        }
    }

    /**
     *
     *
     *  获取指定位置值
     * 
     *
     **/
    private string getPosVal(string str,int pos)
    {
        var array = str.split(":");
        var len = array.length;
        pos = pos < 0 ? len+pos : pos;
        return array[pos];
    }

    public  NotebookTab tab()
    {
        return this.notebookTab;
    }

    public string getPath()
    {
        return this.path;
    }

    public unowned Gtk.Widget getContent()
    {
        return this;
    }
    
    public  void destory() throws FXError
    {

    }
}
