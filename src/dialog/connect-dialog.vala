
[GtkTemplate ( ui = "/cn/navclub/dbfx/ui/connect_dialog.ui" )]
public class ConnectDialog : Gtk.Dialog {
    [GtkChild]
    private unowned Gtk.Entry name;
    [GtkChild]
    private unowned Gtk.Entry comment;
    [GtkChild]
    private unowned Gtk.Stack stack;
    [GtkChild]
    private unowned Gtk.Entry user;
    [GtkChild]
    private unowned Gtk.Entry password;
    [GtkChild]
    private unowned Gtk.ListBox listBox;
    [GtkChild]
    private unowned Gtk.ComboBox authBox;
    [GtkChild]
    private unowned Gtk.ComboBox saveBox;
    [GtkChild]
    private unowned Gtk.Entry host;
    [GtkChild]
    private unowned Gtk.Entry port;
    [GtkChild]
    private unowned Gtk.Entry database;
    [GtkChild]
    private unowned Gtk.Spinner spinner;
    [GtkChild]
    private unowned Gtk.Label describle;
    [GtkChild]
    private unowned Gtk.Button saveBtn;

    private string uuid;

    //当前数据库配置信息
    private unowned DatabaseFeature feature;

    public ConnectDialog()
    {
        this.initListBox();
        this.set_default_response(0);
    }

    public ConnectDialog.update(string uuid)
    {
        this.uuid = uuid;
    }

    private void initListBox(){
        var features = DatabaseFeature.getFeatures();

        foreach(var feature in features){

            var label = new Gtk.Label(feature.name);
            var icon = new Gtk.Image.from_icon_name(feature.icon,Gtk.IconSize.DND);
            var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,1);

            box.pack_start(icon,false,false);
            box.pack_start(label);

            this.listBox.insert(box,-1);
        }

        this.listBox.show_all();
    }

  /**
   *
   *
   *
   * 检查当前配置是否可用
   *
   *
   */
  [GtkCallback]
  public async void testConnect(Gtk.Button btn){
    if(!this.feature.impl)
    {
        warning("Current database not support!");
        return;
    }

    if(!this.formValid())
    {
        warning("Connect info miss!");
        return;
    }

    var dataSource = new DataSource(this.feature._type);

    dataSource.host = this.host.text;
    dataSource.port = int.parse(this.port.text);

    if(authRequire())
    {
        dataSource.user = this.user.text;
        dataSource.password = this.password.text;
        dataSource.authModel = AuthModel.USER_PASSWORD;
    }else
    {
        dataSource.authModel = AuthModel.NONE;
    }

    this.spinner.active = true;

    string errmsg = null;

    DatabaseInfo info = null;

    SourceFunc callback = testConnect.callback;

    WorkDetail work = ()=>{
        try{
            var con = new MysqlConnection.whitout(dataSource);
            con.connect();
            info = con.serverInfo();
        }catch(SqlError e){
            errmsg = e.message;
        }
        Idle.add(callback);
    };

    AsyncWork.create(work).execute();

    yield;

    if(errmsg != null){
        this.describle.label = errmsg;
    }else{
        this.describle.label = "%s(%s)".printf(info.name,info.version);
    }

    this.spinner.active = false;
  }

  /**
   *
   * 验证当前表单是否完整
   *
   */
  private bool formValid()
  {

    var host = this.host.text.strip();
    var port = this.port.text.strip();
    var user = this.user.text.strip();
    var name = this.name.text.strip();

    var require  = authRequire();
    var password = this.password.text.strip();


    var a =  UIUtil.formValid(this.host,()=>host!="");
    var b =  UIUtil.formValid(this.name,()=>name!="");
    var c =  UIUtil.formValid(this.port,()=>port!="");
    var d = UIUtil.formValid(this.user,()=>(!require || user!=""));
    var e = UIUtil.formValid(this.password,()=>(!require ||password!=""));

    return a && b && c && d && e;
  }

  private bool authRequire()
  {
      return this.authBox.get_active()!=1;
  }

  /**
   *
   * 数据源改变
   *
   */
  [GtkCallback]
  public void rowSelected(Gtk.ListBoxRow? selectRow){
    if(selectRow == null){
        return;
    }

    var index = selectRow.get_index();

    unowned var t = this.feature =DatabaseFeature.getFeatures()[index];

    var impl = t.impl;
    //判断是否需要显示保存按钮
    this.saveBtn.visible = impl;
    //根据当前数据库实现情况判断显示页面
    this.stack.set_visible_child_name(impl?"properties":"none");

  }

  /**
   *
   * 认证方式改变
   *
   */
  [GtkCallback]
  public void authChange(){

    var index = this.authBox.get_active();
    if ( index == -1 ){
        return;
    }

    //如果认证方式为`NONE`则禁用认证模块
    var disable = (index != 1);

    this.user.sensitive = disable;
    this.saveBox.sensitive = disable;
    this.password.sensitive = disable;
  }

  [GtkCallback]
  public void cancel()
  {
    this.response(1);
    this.close();
  }

  [GtkCallback]
  public void save()
  {

    var valid = this.formValid();
    if(!valid){
        return;
    }

    var node = new Json.Node(Json.NodeType.OBJECT);

    node.set_object(new Json.Object());

    var builder = new Json.Builder();
    builder.begin_object();
    builder.set_member_name("url");
    builder.add_string_value("https://baidu.com");
    builder.set_member_name("obj");
    builder.add_value(node);
    builder.end_object();

    stdout.printf("%s\n",JsonUtil.jsonStr(builder));
  }

}
