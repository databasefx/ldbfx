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
        className = "nb-tab";
    }

    private int index;

    private Button btn;

    private weak TabService tabService;

    public NotebookTab(Gdk.Pixbuf pixbuf,string title,TabService tabService,bool closeable)
    {
        Object(orientation:Orientation.HORIZONTAL,spacing:3);
        
        this.tabService = tabService;

        var label = new Label(title);
        var icon = new Image.from_pixbuf(pixbuf);

        btn = new Button.from_icon_name("dbfx-close");
        
        unowned var notebook = this.tabService.getNotebook();

        //添加关闭事件
        btn.clicked.connect(()=>{
            notebook.remove_page(this.index);
        });

        this.append(icon);
        this.append(label);
        this.append(btn);

        this.get_style_context().add_class(className);

        this.setCloseable(closeable);
    }

    public void setCloseable(bool closeable)
    {
        this.btn.visible = closeable;
    }
}
