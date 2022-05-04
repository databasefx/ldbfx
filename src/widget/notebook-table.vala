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
    public string path;

    private string pathVal;

    private NotebookTab notebookTab;

    public NotebookTable(string path,string pathVal)
    {
        this.path = path;
        this.pathVal = pathVal;
        this.notebookTab = new NotebookTab("dbfx-table",getPosVal(pathVal,-1),this,true);
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