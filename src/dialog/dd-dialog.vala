using Gtk;

[GtkTemplate (ui = "/cn/navclub/ldbfx/ui/dd-dialog.xml")]
public class DDDialog : Dialog
{
    private bool view;
    private string uuid;
    private string schema;
    private string table;
    private unowned TextBuffer buffer;
    
    [GtkChild]
    private unowned Stack stack;
    [GtkChild]
    private unowned Button copy;
    [GtkChild]
    private unowned Label errLabel;
    [GtkChild]
    private unowned Spinner spinner;
    [GtkChild]
    private unowned TextView textView;

    public DDDialog(string uuid,string schema,string table,bool view)
    {
        this.title = @"$table($schema) - DDL";

        this.view = view;
        this.uuid = uuid;
        this.table = table;
        this.schema = schema;
        this.buffer = this.textView.get_buffer();
        this.loadDDLScript();
    }


    private async void loadDDLScript()
    {
        string ddl  = null;
        FXError error = null;
        //Ref current object
        DDDialog dialog = this;
        var worker = AsyncWork.create(()=>{
            SqlConnection con = null;
            try
            {
                con  = Application.ctx.getConnection(this.uuid);
                ddl = con.ddl(this.schema,this.table,this.view);
            }
            catch(FXError error)
            {
                error = error;
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
            this.errLabel.label = error.message;
        }
        else
        {
            this.buffer.text = ddl;
            this.copy.visible = true;
            this.stack.set_visible_child_name("p1");
        }
        dialog.spinner.stop();
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

    [GtkCallback]
    private void cancel()
    {
        this.close();
    }
}