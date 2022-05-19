using Gtk;


private class FeatureListItem : Box
{
  private const string DEFAULT_CLASS_NAME = "feature-list-item";

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

    image.pixel_size = 100;

    this.append(image);
    this.append(label);

    this.add_css_class(DEFAULT_CLASS_NAME);
  }
}

[GtkTemplate ( ui = "/cn/navclub/dbfx/ui/connect-dialog.xml" )]
public class ConnectDialog : Gtk.Dialog {


  public signal void callback(DataSource dataSource);

  [GtkChild]
  private unowned Entry name;
  [GtkChild]
  private unowned Entry comment;  
  [GtkChild]
  private unowned Button cancel;
  [GtkChild]
  private unowned Stack stack;
  [GtkChild]
  private unowned Label tText;
  [GtkChild]
  private unowned Button apply;
  [GtkChild]
  private unowned Button stepBtn;
  [GtkChild]
  private unowned Box compactBox;
  [GtkChild]
  private unowned Spinner spinner;
  [GtkChild]
  private unowned FlowBox flowBox;


  private string uuid;

  private DataSourceConpact compact;

  //当前数据库配置信息
  private unowned DatabaseFeature feature;

  public ConnectDialog()
  {
    this.compact = null;
    this.visible = true;
    this.createListItem();
  }

  public ConnectDialog.fromEdit(string uuid)
  {
    var dataSource = AppConfig.getDataSource(this.uuid=uuid);

    this.feature = DatabaseFeature.getFeature(dataSource.dbType);

    this.nextOrSave();

    this.visible = true;
    this.stepBtn.visible = false;

    compact.initCompact(dataSource);

    this.name.text = dataSource.name;
    this.comment.text = dataSource.comment;
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
      if(this.compact != null)
      {
        this.name.text = "";
        this.comment.text = "";
        this.compactBox.remove(this.compact.content());
      }
      if(this.feature.dbType == DatabaseType.SQLITE)
      {
        this.compact = new SqliteCompact(this);
      }
      else
      {
        this.compact = new CommonDataSourceCompact();
      }
      this.compactBox.append(this.compact.content());
      this.stack.set_visible_child_name("page1");
    }
    else
    {
      //执行保存
      this.save();
    }
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
  public async void testConnect(Gtk.Button btn)
  {
    var dataSource = new DataSource(this.feature.dbType);
    var success = this.compact.toDataSource(dataSource);
    if(!success)
    {
      return;
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

  [GtkCallback]
  public void dialogClose()
  {
    this.close();
  }

  private async void save()
  {

    var dataSource = DataSource.default(this.feature.dbType);
    var success = this.compact.toDataSource(dataSource);
    if(!success || !basicValid(dataSource))
    {
      return;
    }
    
    var update = false;

    if((update = (uuid != null)))
    {
      dataSource.uuid = this.uuid;
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

    this.callback(dataSource);

    this.close();
  }

  private bool basicValid(DataSource? dataSource)
  {
    var name = this.name.text.strip();
    var b =  UIUtil.formValid(this.name,()=>name!="");
    if(b && dataSource != null)
    {
      dataSource.name= name;
      dataSource.comment = this.comment.text;
    }
    return b;
  }

}

public interface DataSourceConpact:Object
{
    /**
     *
     * 表单验证
     *
     **/
    public abstract bool formValid();

    /**
     *
     * 初始化组建
     *
     */
    public abstract void initCompact(DataSource dataSource);

    /**
     *
     * 将当前表单内容转换为 DataSource 模型
     *
     **/
    public abstract bool toDataSource(DataSource dataSource);

    /**
     *
     * 获取当前ui组件
     *
     */
    public abstract Widget content();
}