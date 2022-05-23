using Gtk;

[GtkTemplate(ui="/cn/navclub/ldbfx/ui/data-source-compact.xml")]
public class CommonDataSourceCompact :Box,DataSourceConpact
{
    [GtkChild]
    private unowned Entry user;
    [GtkChild]
    private unowned PasswordEntry password;
    [GtkChild]
    private unowned ComboBox authBox;
    [GtkChild]
    private unowned ComboBox saveBox;
    [GtkChild]
    private unowned Entry host;
    [GtkChild]
    private unowned Entry port;
    [GtkChild]
    private unowned Entry database;

    public CommonDataSourceCompact()
    {
        this.saveBox.active = 0;
        this.authBox.active = 0;
    }
    /**
     *
     * 表单验证
     *
     **/
    public override bool formValid()
    {
    
        var host = this.host.text.strip();
        var port = this.port.text.strip();
        var user = this.user.text.strip();

        var require  = (authRequire()==AuthModel.USER_PASSWORD);

        var password = this.password.text.strip();


        var a =  UIUtil.formValid(this.host,()=>host!="");
        var c =  UIUtil.formValid(this.port,()=>port!="");
        var d =  UIUtil.formValid(this.user,()=>(!require || user!=""));
        var e =  UIUtil.formValid(this.password,()=>(!require ||password!=""));

        return a && c && d && e;
    }

    /**
     *
     * 将当前表单内容转换为 DataSource 模型
     *
     **/
    public override bool toDataSource(DataSource dataSource)
    {
        var valid = this.formValid();

        if(valid){
            dataSource.host = this.host.text;
            dataSource.database = this.database.text;
            dataSource.authModel = this.authBox.active;
            dataSource.saveModel = this.saveBox.active;
            dataSource.port = int.parse(this.port.text);

            if(this.authRequire() == AuthModel.USER_PASSWORD)
            {
                dataSource.user = this.user.text;
                dataSource.password = this.password.text;
            }
            else
            {
                dataSource.user = "";
                dataSource.password = "";
            }
        }

        return valid;
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

    private AuthModel authRequire()
    {
        return (AuthModel)this.authBox.get_active();
    }

    /**
     *
     * 认证方式改变
     *
    **/
    [GtkCallback]
    public void authChange(){

        var index = this.authBox.get_active();

        //如果认证方式为`NONE`则禁用认证模块
        var disable = (index == AuthModel.USER_PASSWORD);
    
        this.user.sensitive = disable;
        this.saveBox.sensitive = disable;
        this.password.sensitive = disable;
    }

    public override void initCompact(DataSource dataSource)
    {
        this.user.text = dataSource.user;
        this.host.text = dataSource.host;
        this.password.text = dataSource.password;
        this.authBox.active = dataSource.authModel;
        this.port.text = dataSource.port.to_string();
    }
}