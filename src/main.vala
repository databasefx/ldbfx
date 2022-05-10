using Gtk;
using Gee;

public const string EXIT_ACTION_NAME = "exit";
public const string NEW_CONNECT_ACTION_NAME = "new";


public class Application : Gtk.Application
{
    private Menu menu;
    
    private Object mutex;

    public static Application ctx;

    public MainController controller{
        private set;
        get;       
    }

    private Map<string,SqlConnectionPool> pools;

    private const GLib.ActionEntry[] actionEntries =
    {
        { NEW_CONNECT_ACTION_NAME,      newConnect  },
        { EXIT_ACTION_NAME,             exit        }
    };

    public Application(){
        Object(application_id:APPLICATION_ID,flags:ApplicationFlags.FLAGS_NONE);

        this.mutex = new Object();
        this.activate.connect(this.appInit);
        this.pools = new HashMap<string,SqlConnectionPool>();
    }

    public int addTab(TabService service,bool selected)
    {
        var index = -1;
        if( (index = this.tabExist(service.getPath(),selected)) != -1 )
        {
            return index;
        }
        var label = service.tab();
        var content = service as Gtk.Widget;
        var notebook = this.controller.notebook;
        index = notebook.append_page(content,label);
        if( selected )
        {
            notebook.page = index;
        }
        return index;
    }

    public int tabExist(string path,bool selected)
    {
        var notebook = this.controller.notebook;
        var num = notebook.get_n_pages();
        var index = -1;
        for (int i = 0; i < num; i++)
        {
            var service = notebook.get_nth_page(i) as TabService;
            var str = service.getPath();
            if( str == path )
            {
                index = i;
                break;
            }
        }
        if( index != -1 && selected ){
            notebook.page = index;
        }
        return index;
    }

    /**
     *
     *
     * 创建数据库连接池
     *
     **/
    public SqlConnectionPool getConnPool(string uuid) throws FXError
    {
        lock(mutex)
        {
            var pool = this.pools.get(uuid);
            if(pool != null)
            {
                return pool;
            }

            var dataSource = AppConfig.getDataSource(uuid);
            pool = new SqlConnectionPool(dataSource);
            this.pools.set(uuid,pool);

            return pool;
        }
    }

    /**
     *
     * 移除某个连接池
     *
     **/
    public void removePool(string uuid)
    {
        lock(mutex)
        {
            var pool = this.pools.get(uuid);
            if( pool == null ){
                return;
            }
            //移除缓存
            this.pools.remove(uuid);
            //执行资源释放
            pool.shutdown();
        }
    }

    /**
     *
     *
     * 便利方法用户获取连接
     *
     **/
    public static SqlConnection getConnection(string uuid) throws FXError
    {
        if(ctx == null)
        {
          throw new FXError.ERROR("Application can't instance!");  
        }
        return ctx.getConnPool(uuid).getConnection();
    }

    /**
    *
    *
    * 应用初始化
    *
    **/
    public void appInit()
    {
        //设置窗口默认图标
        Gtk.Window.set_default_icon_name("cn.navclub.dbfx");

        //  //注册快捷方式
        //  set_accels_for_action("app." + EXIT_ACTION_NAME,        {  "<Control>e"  });
        //  set_accels_for_action("app." + NEW_CONNECT_ACTION_NAME, {  "<Control>n"  });

        //  //注册action对应函数句柄
        //  add_action_entries(actionEntries, this);

        // 设置应用自定义图标搜索路径
        var iconTheme = UIUtil.getIconTheme();

        iconTheme.add_resource_path(ICON_SEARCH_PATH);

        //加载全局应用样式
        var styleProvider = new Gtk.CssProvider();
        styleProvider.load_from_resource("/cn/navclub/dbfx/style/style.css");
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            styleProvider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        );

        Gtk.Settings.get_default().gtk_application_prefer_dark_theme = true;

        this.menubar = this.menu = (Menu)UIUtil.loadXmlUI("menubar.xml","menu");

        if(this.controller == null){
            this.controller = new MainController(this);
        }

        this.controller.present();
    }

    /**
    *
    * 新建连接
    *
    **/
    public void newConnect()
    {
        new ConnectDialog();
    }

    /**
    *
    * 退出程序
    *
    **/
    public void exit()
    {
        Process.exit(0);
    }


    public static int main (string[] args)
    {
        try
        {

            //
            // 初始化应用目录
            //
            AppConfig.initAppDataFolder();

            //
            // 国际化配置
            //
            Intl.setlocale(LocaleCategory.ALL,"");
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);
            Intl.bind_textdomain_codeset (GETTEXT_PACKAGE, "utf-8");
            Intl.textdomain (GETTEXT_PACKAGE);

            //初始化线程池
            AsyncWork.createThreadPool(20);
        }
        catch(Error e)
        {
            error("Application init failed:"+e.message);
            Process.exit(0);
        }

        ctx = new Application();
        return ctx.run(args);
    }
}


