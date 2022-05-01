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
    private NotebookTab tab;

    public NotebookTable(string path,Notebook notebook)
    {
        this.tab = new NotebookTab("dbfx-table","测试",notebook,this,true);
    }

    public  NotebookTab notebookTab()
    {
        return this.tab;
    }

    
    public  void destory() throws FXError
    {

    }

}