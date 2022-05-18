using Gtk;
/**
 *
 *
 * 自定义Tab组件
 *
 *
 **/
public class NotebookTab : Box
{
    private static string className;


    static construct
    {
        className = "tab";
    }

    private Button btn;
    private weak TabService tabService;

    //判断当前是否处于加载状态
    public bool loading{
        private set;
        get;
    }

    //加载状态信号
    public signal void loadStatus(bool loading);

    public NotebookTab(string iconName,string title,TabService tabService,bool closeable)
    {
        Object(orientation:Orientation.HORIZONTAL,spacing:5);
        
        this.tabService = tabService;

        var label = new Label(title);
        var spinner = new Spinner();
        var icon = new Image.from_icon_name(iconName);
        btn = new Button.from_icon_name("dbfx-close");

        spinner.visible = false;

        var notebook = this.tabService.getNotebook();

        //添加关闭事件
        btn.clicked.connect(()=>{
            notebook.detach_tab(this.tabService.getContent());
        });

        this.append(spinner);
        this.append(icon);
        this.append(label);
        this.append(btn);

        this.get_style_context().add_class(className);

        this.setCloseable(closeable);

        //动态显示图标和加载状态
        this.loadStatus.connect((loading)=>{
            this.loading = loading;
            spinner.visible = !(icon.visible = !loading);
            if(spinner.visible)
            {
                spinner.start();
            }
            else
            {
                spinner.stop();
            }
        });
    }

    public void setCloseable(bool closeable)
    {
        this.btn.visible = closeable;
    }
}
