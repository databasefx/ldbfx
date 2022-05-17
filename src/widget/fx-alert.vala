using Gtk;

public enum AlertType
{
    /**
     *
     * 普通信息
     *
     */
    INFOMATION,
    /**
     *
     * 警告信息
     *
     */
    WARNING,
    /**
     *
     * 错误信息
     *
     */
    ERROR,
    /**
     *
     * 确认框
     *
     */
     CONFIRMATION
}
/**
 *
 * 一个包含信息、警告、错误对话框
 *
 */
[GtkTemplate (ui="/cn/navclub/dbfx/ui/fx-alert.xml")]
public class FXAlert : Window
{
    [GtkChild]
    private unowned Image icon;
    [GtkChild]
    private unowned Label label;
    [GtkChild]
    private unowned Button cancel;
    [GtkChild]
    private unowned Button ok;

    private AlertType type;

    public signal void response(bool ok);

    private FXAlert(AlertType type,string text)
    {
        this.type = type;
        string iconName;
        if(this.type == AlertType.INFOMATION)
        {
            iconName = "dbfx-alert-info";
        }
        else if(type == AlertType.WARNING)
        {
            iconName = "dbfx-alert-warn";
        }
        else if(type == AlertType.CONFIRMATION)
        {
            iconName = "dbfx-alert-help";
        }
        else
        {
            iconName = "dbfx-alert-error";
        }

        this.label.label = text;
        this.icon.icon_name = iconName;

        this.ok.clicked.connect(()=>this.manualClose(true));
        this.cancel.clicked.connect(()=>this.manualClose(false));

        this.cancel.visible = (type == AlertType.CONFIRMATION);

        this.visible = true;

    }

    private void manualClose(bool ok)
    {
        this.response(ok);
        this.close();
    }

    public static FXAlert create(AlertType type,string text)
    {
        return new FXAlert(type,text);
    }
}