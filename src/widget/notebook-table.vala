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
            var label = listItem.child as Label;
            label.label = item.getStrValue();
            if(item.isNull || item.index-1 == 0)
            {
                label.add_css_class("high-light");
            }
            else
            {
                label.remove_css_class("high-light");
            }
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

            this.diffCol(columns);

            var dSize  = this.list.size;
            var rowNum    = dSize / colNum;
            for (int j = 0; j < rowNum; j++)
            {
                //重置偏移量
                offset = j * colNum;
                
                var array  = new string[colNum+1];

                //添加序号列
                array[0] = (j + 1).to_string();
                
                for (int i = offset; i < offset + colNum; i++)
                {
                    array[i - offset + 1] = this.list.get(i);
                }

                this.listStore.append(new TableRowMeta(array));
                
                //一次性加载10条数据
                if(j % 10 == 0)
                {
                    Idle.add(callback);
                    yield;
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
        //创建索引列
        if(this.columns.size == 0)
        {
            var ccolumn = new ColumnViewColumn
            (
                "",
                factory
            );
            ccolumn.set_resizable(false);
            this.columns.add(ccolumn);
            this.tableView.append_column(ccolumn);
        }

        var index = 0;
        var newSize = list.size;
        var size = this.columns.size;

        foreach(var column in list)
        {
            var name = column.name;
            
            if(index > newSize)
            {
                this.columns.get(index+1).title = name;
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
        for(var i = (size - 1) ; i >= newSize + 1 ; i--)
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
