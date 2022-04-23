using Gtk;

/**
 *
 * 表单验证失败显示样式
 *
 */
private const string FORM_VALID_FAIL = "form-valid-fail";

/**
 *
 * 表单验证
 *
 */
public delegate bool FormValidator();

public class UIUtil : Object {
    /**
     *
     * 显示消息对话框
     *
     **/
    public static void showMsgDialog(string msg,MessageType type,Gtk.Window ?window=null){

        var dialog = new MessageDialog
        (
            window,
            DialogFlags.DESTROY_WITH_PARENT,
            type,
            ButtonsType.OK,
            msg
        );

        dialog.show_all();
    }

    /**
     *
     * 表单验证
     *
     **/
    public static bool formValid(Widget widget,FormValidator validator){
        var success = validator();
        var ctx = widget.get_style_context();
        if(success)
        {
            if(ctx.has_class(FORM_VALID_FAIL)){
                ctx.remove_class(FORM_VALID_FAIL);
            }

        }else
        {
            ctx.add_class(FORM_VALID_FAIL);
        }
        return success;
    }

    /**
     *
     * 普通文本通知
     *
     **/
    public static void textNotification(string text)
    {
        var notification = new Notification(text);
        Application.ctx.send_notification(Uuid.string_random(),notification);
    }
}
