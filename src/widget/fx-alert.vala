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
    ERROR
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

    private AlertType type;

    public FXAlert(AlertType type,string text)
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
        else
        {
            iconName = "dbfx-alert-error";
        }

        this.label.label = text;
        this.icon.icon_name = iconName;

        this.visible = true;
    }
}