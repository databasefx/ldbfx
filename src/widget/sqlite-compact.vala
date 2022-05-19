using Gtk;

[GtkTemplate(ui="/cn/navclub/dbfx/ui/sqlite-compact.xml")]
public class SqliteCompact : Box,DataSourceConpact
{
    
    private ConnectDialog dialog;

    [GtkChild]
    private unowned Entry fileEntry;

    public SqliteCompact(ConnectDialog dialog)
    {
        this.dialog = dialog;
    }
    /**
     *
     * 表单验证
     *
     **/
    public override bool formValid()
    {
        var path = this.fileEntry.text.strip();

        stdout.printf("%s\n",path!=""?"true":"false");
        var pass = UIUtil.formValid(this.fileEntry,()=>path != "");

        return pass;
    }
    /**
     *
     * 获取当前ui组件
     *
     */
    public override Widget content()
    {
        return this;
    }


    /**
     *
     * 将当前表单内容转换为 DataSource 模型
     *
     **/
    public override bool toDataSource(DataSource dataSource)
    {
        var pass = this.formValid();
        if(pass)
        {
            dataSource.dbFilePath = this.fileEntry.text;
        }
        return pass;
    }


    public override void initCompact(DataSource dataSource)
    {
        this.fileEntry.text = dataSource.dbFilePath;
    }

    [GtkCallback]
    public void openFileChooser()
    {
        this.dialog.modal = false;
        
        var fileChooser = new FileChooserDialog("Please choose sqlite file",null,FileChooserAction.OPEN,_("_Select"),1,_("_Cancel"),0,null);
        var fileFilter = new FileFilter();

        fileFilter.add_pattern("*.db");
        fileChooser. select_multiple = false;
        fileFilter.set_filter_name(".db file");

        fileChooser.add_filter(fileFilter);
        fileChooser.response.connect((id)=>{
            //IF cancel was actived,direct close FileChooser
            if(id == 1)
            {
                var file = fileChooser.get_file();
                if(file == null)
                {
                    return;
                }
                this.fileEntry.text = file.get_path();
            }
            fileChooser.close();
            this.dialog.modal = true;
        });

        fileChooser.visible = true;
    }

}