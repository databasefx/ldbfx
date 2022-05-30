using Gtk;
using GtkSource;

[GtkTemplate (ui = "/cn/navclub/ldbfx/ui/notebook-ddl.xml")]
public class DDNotebook : Box, TabService
{
    private bool view;

    private string pathStr;

    private unowned Buffer buffer;

    [GtkChild]
    private unowned SQLSourceView sourceView;

    public DDNotebook(string pathStr,bool view)
    {
        this.pathStr = pathStr;
        this.buffer = this.sourceView.buffer as Buffer;

        this.loadDDLScript();
    }

    [GtkCallback]
    private async void loadDDLScript()
    {

        var uuid = this.getPosVal(this.pathStr,0);
        var table = this.getPosVal(this.pathStr,-1);
        var schema = this.getPosVal(this.pathStr,-3);

        string ddl  = null;
        FXError error = null;

        var worker = AsyncWork.create(()=>{
            SqlConnection con = null;
            try
            {
                con  = Application.ctx.getConnection(uuid);
                ddl = con.ddl(schema,table,this.view);
            }
            catch(FXError e)
            {
                error = e;
            }
            finally
            {
                if(con != null)
                {
                    con.close();
                }
                Idle.add(loadDDLScript.callback);
            }
        });
        
        worker.execute();
        
        yield;

        if(error != null)
        {
            FXAlert.error(null,error.message);
        }
        else
        {
            this.buffer.text = ddl;
        }
    }

    [GtkCallback]
    public void copyText()
    {
        var text = this.buffer.text;
        if(StrUtil.isBlack(text))
        {
            return;
        }
        //Copy ddl statement to clipboard
        OSUtil.setCPBText(text);
        UIUtil.textNotification(_("_Copy success"));
    }

    public NotebookTab tab()
    {
        var title = "[DDL]%s".printf(this.getPosVal(this.pathStr,-1));
        return new NotebookTab("dbfx-ddl" , title, this , true);
    }

    public unowned Widget content()
    {
        return this;
    }


    public string path()
    {
        return TabScheme.toFullPath(TabScheme.DDL,this.pathStr);
    }

    public TabScheme scheme()
    {
        return TabScheme.DDL;
    }

}