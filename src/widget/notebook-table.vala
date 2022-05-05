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

    private bool view;
    public string path;
    private string pathVal;
    private NotebookTab notebookTab;
    
    [GtkChild]
    private unowned Gtk.TreeView tableView;
    [GtkChild]
    private unowned Gtk.ListStore listStore;


    public NotebookTable(string path,string pathVal,bool view)
    {
        this.view = view;
        this.path = path;
        this.pathVal = pathVal;
        this.initTable();
        this.notebookTab = new NotebookTab( view ? viewIcon : tableIcon , getPosVal(pathVal,-1) , this, true );
    }


    private async void initTable()
    {
        var uuid = this.getPosVal(this.path,0);
        var table = this.getPosVal(this.pathVal,-1);
        var schema = this.getPosVal(this.pathVal,-3);

        FXError error = null;
        Gee.List<TableColumnMeta> columns = null;
        SourceFunc callback = initTable.callback;
        
        var work = AsyncWork.create(()=>{
            var connect = Application.getConnection(uuid);
            try
            {
                columns = connect.tableColumns(schema,table);
            }
            catch(FXError e)
            {
                warning("Query table column meta fail:%s".printf(e.message));
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
        foreach(var column in columns)
        {
            var tColumn = new TreeViewColumn();
            tColumn.set_resizable(true);
            tColumn.set_title(column.name);
            this.tableView.append_column(tColumn);
        }

        this.tableView.show_all();
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
}