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
[GtkTemplate (ui="/cn/navclub/ldbfx/ui/fx-alert.xml")]
public class FXAlert : Window
{
    [GtkChild]
    private unowned Button ok;
    [GtkChild]
    private unowned Image icon;
    [GtkChild]
    private unowned Button cancel;
    [GtkChild]
    private unowned Label subTitle;
    [GtkChild]
    private unowned Label textView;

    private AlertType type;

    public signal void response(bool ok);

    private FXAlert(AlertType type,string subTitle,string content)
    {
        this.type = type;
        string iconName;
        if(this.type == AlertType.INFOMATION)
        {
            iconName = "dbfx-alert-info";
            this.title = _("_Information");
        }
        else if(type == AlertType.WARNING)
        {
            iconName = "dbfx-alert-warn";
            this.title = _("_Warn");
        }
        else if(type == AlertType.CONFIRMATION)
        {
            iconName = "dbfx-alert-help";
            this.title = _("_Confirmation");
        }
        else
        {
            this.title = _("_Error");
            iconName = "dbfx-alert-error";
        }

        this.textView.label = content;
        this.subTitle.label = subTitle;

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

    public static FXAlert info(string? subTitle,string content)
    {
        return new FXAlert(AlertType.INFOMATION,subTitle??_("_Information"),content);
    }

    public static FXAlert warn(string? subTitle,string content)
    {
        return new FXAlert(AlertType.WARNING,subTitle??_("_Warn info"),content);
    }

    public static FXAlert confirm(string? subTitle,string content)
    {
        return new FXAlert(AlertType.CONFIRMATION,subTitle??_("_Confirm info"),content);
    }

    public static FXAlert error(string? subTitle,string content)
    {
        return new FXAlert(AlertType.ERROR,subTitle??_("Error infor"),content);
    }
}