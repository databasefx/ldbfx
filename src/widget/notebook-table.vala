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


    public NotebookTable(string path,string pathVal,bool view)
    {
        this.view = view;
        this.path = path;
        this.pathVal = pathVal;
        this.notebookTab = new NotebookTab( view ? viewIcon : tableIcon , getPosVal(pathVal,-1) , this, true );
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
        pos = pos < 0 ? len-1 : pos;
        return array[pos];
    }
}