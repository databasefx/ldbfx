using Gtk;

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
    private string pathVal;
    private NotebookTab notebookTab;
    private MultiSelection selection;
    private GLib.ListStore listStore;
    private SignalListItemFactory factory;
    
    [GtkChild]
    private unowned Label rowNLum;
    [GtkChild]
    private unowned ColumnView tableView;


    public NotebookTable(string path,string pathVal,bool view)
    {
        this.page = 1;
        this.size = 100;
        this.view = view;
        this.path = path;
        this.pathVal = pathVal;
        this.factory = new SignalListItemFactory();
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

        this.loadTableData();
    }


    private async void loadTableData()
    {
        var tab = this.tab();
        
        if(tab.loading)
        {
            return;
        }

        tab.loadStatus(true);

        var uuid = this.getPosVal(this.path,0);
        var table = this.getPosVal(this.pathVal,-1);
        var schema = this.getPosVal(this.pathVal,-3);

        FXError error = null;
        Gee.List<string> data = null;
        Gee.List<TableColumnMeta> columns = null;
        SourceFunc callback = loadTableData.callback;

        int64 total = 0;

        var work = AsyncWork.create(()=>{
            var connect = Application.getConnection(uuid);
            try
            {
                data = connect.pageQuery(schema,table,this.page,this.size);
                columns = connect.tableColumns(schema,table);
                total = connect.count(schema,table);
            }
            catch(FXError e)
            {
                warning("Query table data fail:%s".printf(e.message));
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

        tab.loadStatus(false);
        
        this.rowNLum.label = "%s %s".printf(total.to_string(),_("_Rows"));

        if(error != null)
        {
            return;
        }
        
        this.diffCol(columns);
        
        var dataSize  = data.size;
        var colNum    = columns.size;
        var rowNum    = dataSize / colNum;
        for (int j = 0; j < rowNum; j++)
        {
            var offset = j * colNum;
            var array  = new string[colNum];
            for (int i = offset; i < offset + colNum; i++)
            {
                array[i-offset] = data.get(i);
            }
            this.listStore.append(new TableRowMeta(array));
        }
    }

    /**
     *
     *
     * 差分检查列
     *
     **/
    private void diffCol(Gee.List<TableColumnMeta> list)
    {
        foreach(var column in list)
        {
            var name = column.name;
            var ccolumn = new ColumnViewColumn
            (
                name,
                factory
            );
            
            ccolumn.set_resizable(true);
            
            this.tableView.append_column(ccolumn);
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
