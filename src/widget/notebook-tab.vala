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
    private static string className = "nb-tab";

    private int index;

    private Button btn;

    private unowned Notebook notebook;


    public NotebookTab(string iconName,string title,Notebook notebook,Widget child,bool closeable)
    {
        Object(orientation:Orientation.HORIZONTAL,spacing:3);

        var label = new Label(title);
        btn   = new Button.from_icon_name("dbfx-close");
        var icon = new Image.from_icon_name(iconName,IconSize.BUTTON);

        btn.relief = ReliefStyle.NONE;
        //添加关闭事件
        btn.clicked.connect(()=>{
            this.notebook.remove_page(this.index);
        });

        this.pack_start(icon,false,false,0);
        this.pack_start(label,true,true,0);
        this.pack_start(btn,false,false,0);

        this.notebook = notebook;

        this.index = this.notebook.append_page(child,this);

        this.get_style_context().add_class(className);

        this.show_all();

        this.notebook.show_all();

        this.setCloseable(closeable);
    }

    public void setCloseable(bool closeable)
    {
        this.btn.visible = closeable;
    }
}
