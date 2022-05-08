using Gtk;

/*
 *
 *
 * NoteBook Table
 * 
 *
 **/
 [GtkTemplate (ui="/cn/navclub/dbfx/ui/notebook-table.ui")]
public class NotebookTable : Box, TabService
{
    /**
      缓存表格和视图图标
    */
    private static Gdk.Pixbuf viewIcon;
    private static Gdk.Pixbuf tableIcon;

    static construct
    {
        viewIcon = IconTheme.get_default().load_icon("dbfx-view",22,0);
        tableIcon = IconTheme.get_default().load_icon("dbfx-table",15,0);
    }

    private int page;
    private int size;
    private bool view;
    public string path;
    private string pathVal;
    private NotebookTab notebookTab;
    private unowned Gtk.ListStore listStore;
    
    [GtkChild]
    private unowned Gtk.TreeView tableView;

    [GtkChild]
    private unowned Gtk.ScrolledWindow scrolledWindow;



    public NotebookTable(string path,string pathVal,bool view)
    {
        this.page = 1;
        this.size = 100;
        this.view = view;
        this.path = path;
        this.pathVal = pathVal;
        this.notebookTab = new NotebookTab( view ? viewIcon : tableIcon , getPosVal(pathVal,-1) , this, true );
        
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


        this.listStore.clear();

        var index = 0;
        var colNum = columns.size;
        var rowNum = data.size/colNum;
    
        TreeIter iter;
        var val = new Value(typeof(string));

        for (int i = 0; i < rowNum; i++)
        {
            var offset = i * colNum;
            for (int j = offset; j < offset+colNum; j++)
            {
                val.set_string(data.get(j));
                this.listStore.append(out iter);
                this.listStore.set_value(iter,j-offset,val);
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
        var index = 0;
        var types = new Type[list.size];
        for (int i = 0; i < list.size; i++)
        {
            types[i] = Type.STRING;
        }

        //重置TreeModel
        this.listStore = (this.tableView.model =  new Gtk.ListStore.newv(types)) as Gtk.ListStore;

        foreach(var column in list)
        {
            var name = column.name;
            var tColumn = new TreeViewColumn.with_attributes
            (
                name,
                new Gtk.CellRendererText(),
                "text",index,
                null
            );
            
            tColumn.set_resizable(true);
            
            this.tableView.append_column(tColumn);

            index++;
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