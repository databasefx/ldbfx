using Gtk;

private class FeatureListItem : Box
{
  private unowned DatabaseFeature feature;
  
  public FeatureListItem(unowned DatabaseFeature feature)
  {

    this.vexpand = false;
    this.feature = feature;
    this.valign = Align.CENTER;
    this.orientation = Orientation.VERTICAL;

    var label = new Label(feature.name);
    var image = new Image.from_icon_name(feature.icon);

    image.icon_size = IconSize.LARGE;

    this.append(image);
    this.append(label);

  }
}
[GtkTemplate ( ui = "/cn/navclub/dbfx/ui/connect-dialog.xml" )]
public class ConnectDialog : Gtk.Dialog {
    //  [GtkChild]
    //  private unowned Entry name;
    //  [GtkChild]
    //  private unowned Entry comment;
    //  [GtkChild]
    //  private unowned Entry user;
    //  [GtkChild]
    //  private unowned Entry password;
    //  [GtkChild]
    //  private unowned ComboBox authBox;
    //  [GtkChild]
    //  private unowned ComboBox saveBox;
    //  [GtkChild]
    //  private unowned Entry host;
    //  [GtkChild]
    //  private unowned Entry port;
    //  [GtkChild]
    //  private unowned Spinner spinner;
    //  [GtkChild]
    //  private unowned Label tText;
    //  [GtkChild]
    //  private unowned Button apply;
    //  [GtkChild]
    //  private unowned Button cancel;
    [GtkChild]
    private unowned Stack stack;
    [GtkChild]
    private unowned FlowBox flowBox;
    
    //当前数据库配置信息
    private unowned DatabaseFeature feature;

    public ConnectDialog()
    {
        this.createListItem();
        this.visible = true;
    }

    public ConnectDialog.edit(string uuid)
    {
    }

    private void createListItem()
    {
      var list = DatabaseFeature.getFeatures();
            
      foreach(var feature in list)
      {
        var box = new FlowBoxChild();
        box.width_request  = 100;
        box.height_request = 100;
        box.child = new FeatureListItem(feature);
        this.flowBox.append(box); 
      }
    }

    [GtkCallback]
    public void nextOrSave()
    {
      var visibleName = this.stack.visible_child_name;
      if(visibleName == "page0")
      {
        this.stack.set_visible_child_name("page1");
      }
      stdout.printf("%s\n",visibleName);
    }

  /**
   *
   *
   *
   * 检查当前配置是否可用
   *
   *
   */
  //  [GtkCallback]
  public async void testConnect(Gtk.Button btn){
//      if(!this.feature.impl)
//      {
//          warning("Current database not support!");
//          return;
//      }

//      if(!this.formValid())
//      {
//          warning("Connect info miss!");
//          return;
//      }

//      var dataSource = new DataSource(this.feature.dbType);

//      dataSource.host = this.host.text;
//      dataSource.port = int.parse(this.port.text);

//      if(authRequire()== AuthModel.USER_PASSWORD)
//      {
//          dataSource.user = this.user.text;
//          dataSource.password = this.password.text;
//          dataSource.authModel = AuthModel.USER_PASSWORD;
//      }else
//      {
//          dataSource.authModel = AuthModel.NONE;
//      }

//      this.spinner.start();

//      string errmsg = null;

//      DatabaseInfo info = null;

//      SourceFunc callback = testConnect.callback;

//      WorkDetail work = ()=>{
//          try{
//              var con = new MysqlConnection.whitout(dataSource);
//              con.connect();
//              info = con.serverInfo();
//          }catch(FXError e){
//              errmsg = e.message;
//          }
//          Idle.add(callback);
//      };

//      AsyncWork.create(work).execute();

//      yield;

//      if(errmsg != null){
//          this.describle.label = errmsg;
//      }else{
//          this.describle.label = "%s(%s)".printf(info.name,info.version);
//      }

//      this.spinner.stop();
  }

//    /**
//     *
//     * 验证当前表单是否完整
//     *
//     */
//    private bool formValid()
//    {

//      var host = this.host.text.strip();
//      var port = this.port.text.strip();
//      var user = this.user.text.strip();
//      var name = this.name.text.strip();

//      var require  = authRequire()==AuthModel.USER_PASSWORD;

//      var password = this.password.text.strip();


//      var a =  UIUtil.formValid(this.host,()=>host!="");
//      var b =  UIUtil.formValid(this.name,()=>name!="");
//      var c =  UIUtil.formValid(this.port,()=>port!="");
//      var d =  UIUtil.formValid(this.user,()=>(!require || user!=""));
//      var e =  UIUtil.formValid(this.password,()=>(!require ||password!=""));

//      return a && b && c && d && e;
//    }

//    private AuthModel authRequire()
//    {
//        return (AuthModel)this.authBox.get_active();
//    }

//    /**
//     *
//     * 数据源改变
//     *
//     */
//    [GtkCallback]
//    public void rowSelected(Gtk.ListBoxRow? selectRow){
//      if(selectRow == null){
//          return;
//      }

//      var index = selectRow.get_index();

//      unowned var t = this.feature =DatabaseFeature.getFeatures()[index];

//      var impl = t.impl;
//      //判断是否需要显示保存按钮
//      this.saveBtn.visible = impl;
//      this.testBox.visible = impl;
//      //根据当前数据库实现情况判断显示页面
//      this.stack.set_visible_child_name(impl?"properties":"none");

//    }

//    /**
//     *
//     * 认证方式改变
//     *
//     */
//    [GtkCallback]
//    public void authChange(){

//      var index = this.authBox.get_active();
//      if ( index == -1 ){
//          return;
//      }

//      //如果认证方式为`NONE`则禁用认证模块
//      var disable = (index == 1);

//      this.user.sensitive = disable;
//      this.saveBox.sensitive = disable;
//      this.password.sensitive = disable;
//    }

//    [GtkCallback]
//    public void cancel()
//    {
//      this.response(1);
//      this.close();
//    }

//    [GtkCallback]
//    public async void save()
//    {

//      var valid = this.formValid();

//      if(!valid){
//          return;
//      }

//      var update = false;
//      var uuid = this.uuid;

//      if(!(update = !(uuid == null)))
//      {
//          uuid = Uuid.string_random();
//      }

//      var builder = new Json.Builder();

//      builder.begin_object();

//      builder.set_member_name(Constant.UUID);
//      builder.add_string_value(uuid);

//      builder.set_member_name(Constant.TYPE);
//      builder.add_int_value(this.feature.dbType);

//      builder.set_member_name(Constant.NAME);
//      builder.add_string_value(this.name.text);

//      builder.set_member_name(Constant.COMMENT);
//      builder.add_string_value(this.comment.text);

//      builder.set_member_name(Constant.DATABASE);
//      builder.add_string_value(this.database.text);

//      builder.set_member_name(Constant.AUTH_MODEL);
//      builder.add_int_value(this.authRequire());

//      builder.set_member_name(Constant.HOST);
//      builder.add_string_value(this.host.text);

//      builder.set_member_name(Constant.PORT);
//      builder.add_int_value(int.parse(this.port.text));

//      if(this.authRequire() == AuthModel.USER_PASSWORD)
//      {
//          builder.set_member_name(Constant.USER);
//          builder.add_string_value(this.user.text);

//          builder.set_member_name(Constant.PASSWORD);
//          builder.add_string_value(this.password.text);
//      }

//      builder.end_object();

//      //持久化到文件
//      if(this.saveBox.get_active_id()=="1")
//      {
//          Error error = null;
//          SourceFunc callback = save.callback;
//          var work = AsyncWork.create(()=>{
//              try{
//                  AppConfig.addDataSource(uuid,builder.get_root(),update);
//              }catch(Error e){
//                  error = e;
//                  var errmsg = error.message;
//                  warning(@"Write config file fail:$errmsg");
//              }
//              Idle.add(callback);
//          });

//          work.execute();

//          yield;

//          if(error!=null)
//          {
//              new Notification(_("Save config fail"));
//          }
//      }

//      UIUtil.textNotification(_("Save config fail"));

//    }

}
