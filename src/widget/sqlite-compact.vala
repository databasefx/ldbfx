using Gtk;

[GtkTemplate(ui="/cn/navclub/dbfx/ui/sqlite-compact.xml")]
public class SqliteCompact : Box,DataSourceConpact
{
    private ConnectDialog dialog;

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
        return true;
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
        return true;
    }


    public override void initCompact(DataSource dataSource)
    {

    }

    [GtkCallback]
    public void openFileChooser()
    {
        this.dialog.modal = false;
        
        var fileChooser = new FileChooserDialog("Please choose sqlite file",null,FileChooserAction.OPEN);

        fileChooser.visible = true;
    }

}