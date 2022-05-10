using Gtk;

public class TableRowMeta : Object
{
    public string value;

    public TableRowMeta(string value)
    {
        this.value = value;
    }
}
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
    private unowned Gtk.ColumnView tableView;

    [GtkChild]
    private unowned Gtk.ScrolledWindow scrolledWindow;



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
            (listItem.child as Label).label = item.value;
        });
        this.factory.setup.connect((listItem)=>{
            listItem.activatable  = true;
            listItem.child = new Label("");
        });

        this.factory.unbind.connect((listItem)=>{
            listItem.child = null;
            listItem.activatable = false;
        });

        this.tableView.model = this.selection;

        this.loadTableData();
    }


    private async void loadTableData()
    {
        var uuid = this.getPosVal(this.path,0);
        var table = this.getPosVal(this.pathVal,-1);
        var schema = this.getPosVal(this.pathVal,-3);

        FXError error = null;
        Gee.List<string> data = null;
        Gee.List<TableColumnMeta> columns = null;
        SourceFunc callback = loadTableData.callback;

        var work = AsyncWork.create(()=>{
            var connect = Application.getConnection(uuid);
            try
            {
                data = connect.pageQuery(schema,table,this.page,this.size);
                columns = connect.tableColumns(schema,table);
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

        if(error != null)
        {
            return;
        }
        
        this.diffCol(columns);
        
        var dataSize  = data.size;
        var colNum    = columns.size;
        var rowNum    = dataSize / colNum;

        for (int i = 0; i < colNum; i++)
        {
            for (int j = 0; j < rowNum; j++)
            {
                //  stdout.printf("%s\n",data.get(j*colNum+i));
                this.listStore.append(new TableRowMeta(data.get(j*colNum+i)));
            }
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
    
    public  void destory() throws FXError
    {

    }
}