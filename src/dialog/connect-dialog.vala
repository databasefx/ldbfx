using Gtk;

private class FeatureListItem : Box
{
  
  public unowned DatabaseFeature feature{
    private set;
    get;
  }
  
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

public delegate void DFunction(DataSource dataSource);

[GtkTemplate ( ui = "/cn/navclub/dbfx/ui/connect-dialog.xml" )]
public class ConnectDialog : Gtk.Dialog {
  [GtkChild]
  private unowned Entry name;
  [GtkChild]
  private unowned Entry comment;
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
  private unowned Spinner spinner;
  [GtkChild]
  private unowned Label tText;
  [GtkChild]
  private unowned Button apply;
  [GtkChild]
  private unowned Button cancel;
  [GtkChild]
  private unowned Stack stack;
  [GtkChild]
  private unowned Button stepBtn;
  [GtkChild]
  private unowned FlowBox flowBox;
  [GtkChild]
  private unowned Entry database;

  public DFunction callback;

  private string uuid;
    
  //当前数据库配置信息
  private unowned DatabaseFeature feature;

  public ConnectDialog()
  {
    this.createListItem();
    this.saveBox.active = 0;
    this.authBox.active = 0;
    this.visible = true;
  }

  public ConnectDialog.fromEdit(string uuid)
  {
    this.uuid = uuid;
    this.initDialog();
    this.visible = true;
  }


  private void initDialog()
  {
    this.nextOrSave();
    this.stepBtn.visible = false;

    //更新编辑属性
    var dataSource = AppConfig.getDataSource(this.uuid);
    if(dataSource != null)
    {
      this.host.text = dataSource.host;
      this.user.text = dataSource.user;
      this.name.text = dataSource.name;
      this.comment.text = dataSource.comment;
      this.password.text = dataSource.password;
      this.authBox.active = dataSource.authModel;
      this.port.text = dataSource.port.to_string();
    }
  }

  /**
   *
   *
   * 创建支持数据库条目
   *
   */
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

    //默认选中第一个
    if((this.apply.sensitive =(list.length > 0)))
    {
      this.feature = list[0];
    }

  }

  [GtkCallback]
  public void nextOrSave()
  {
    var visibleName = this.stack.visible_child_name;
    if(visibleName == "page0")
    {
      this.apply.label = _("_Ok");
      this.stepBtn.visible = true;
      this.stack.set_visible_child_name("page1");
      return;
    }
    //执行保存
    this.save();
  }

  [GtkCallback]
  public void back()
  {
    this.stack.set_visible_child_name("page0");
    this.apply.label = _("_Next");
    this.stepBtn.visible = false;
  }

  [GtkCallback]
  public void flowBoxChildActive(FlowBoxChild box){
    this.apply.sensitive = true;
    var item = box.child as FeatureListItem;
    this.feature = item.feature;
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
        debug("Current database not support!");
        return;
    }

    if(!this.formValid())
    {
        debug("Connect info miss!");
        return;
    }

    var dataSource = new DataSource(this.feature.dbType);

    dataSource.host = this.host.text;
    dataSource.port = int.parse(this.port.text);

    if(authRequire()== AuthModel.USER_PASSWORD)
    {
        dataSource.user = this.user.text;
        dataSource.password = this.password.text;
        dataSource.authModel = AuthModel.USER_PASSWORD;
    }else
    {
        dataSource.authModel = AuthModel.NONE;
    }

    this.spinner.start();

    string errmsg = null;

    DatabaseInfo info = null;

    SourceFunc callback = testConnect.callback;

    WorkDetail work = ()=>{
        try{
            var con = new MysqlConnection.whitout(dataSource);
            con.connect();
            info = con.serverInfo();
        }catch(FXError e){
            errmsg = e.message;
        }
        Idle.add(callback);
    };

    AsyncWork.create(work).execute();

    yield;

    if(errmsg != null){
        this.tText.label = errmsg;
    }else{
        this.tText.label = "%s(%s)".printf(info.name,info.version);
    }

    this.spinner.stop();
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

    var require  = (authRequire()==AuthModel.USER_PASSWORD);

    var password = this.password.text.strip();


    var a =  UIUtil.formValid(this.host,()=>host!="");
    var b =  UIUtil.formValid(this.name,()=>name!="");
    var c =  UIUtil.formValid(this.port,()=>port!="");
    var d =  UIUtil.formValid(this.user,()=>(!require || user!=""));
    var e =  UIUtil.formValid(this.password,()=>(!require ||password!=""));

    return a && b && c && d && e;
  }

  private AuthModel authRequire()
  {
      return (AuthModel)this.authBox.get_active();
  }

  /**
   *
   * 认证方式改变
   *
   */
  [GtkCallback]
  public void authChange(){

    var index = this.authBox.get_active();

    //如果认证方式为`NONE`则禁用认证模块
    var disable = (index == AuthModel.USER_PASSWORD);
    
    this.user.sensitive = disable;
    this.saveBox.sensitive = disable;
    this.password.sensitive = disable;
  }

  [GtkCallback]
  public void dialogClose()
  {
    this.close();
  }

  private async void save()
  {

    var valid = this.formValid();

    if(!valid){
        return;
    }

    var update = false;
    var uuid = this.uuid;

    if(!(update = !(uuid == null)))
    {
        uuid = Uuid.string_random();
    }

    var dataSource = new DataSource(this.feature.dbType);

    dataSource.uuid = uuid;
    dataSource.host = this.host.text;
    dataSource.comment = this.comment.text;
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
    
    FXError error = null;
    SourceFunc callback = save.callback;
    var work = AsyncWork.create(()=>{
      try
      {
        AppConfig.addDataSource(dataSource,update);
      }
      catch(FXError e)
      {
        error = e;
        var errmsg = error.message;
        warning(@"Write config file fail:$errmsg");
      }
      Idle.add(callback);
    });

    work.execute();

    yield;

    if(error != null)
    {
      UIUtil.textNotification(_("Save config fail"));
      return;
    }
  }

}
