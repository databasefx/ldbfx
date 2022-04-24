using Gtk;

public enum NTRow
{
    /**
     *
     * 数据库
     *
     **/
    ROOT,
    /**
     *
     *
     * scheme
     *
     */
    SCHEME,
    /**
     *
     * 表
     *
     **/
    TABLE
}
/**
 *
 * 导航视图自定义弹出菜单
 *
 *
 **/
public class NavTreeEvent : Object
{
    private unowned TreeView navTree;
    private unowned MainController controller;

    public NavTreeEvent.register(TreeView navTree,MainController controller)
    {
        this.navTree = navTree;
        this.controller = controller;
        this.navTree.button_press_event.connect(btnPreEvent);
    }

    private bool btnPreEvent(Gdk.EventButton event)
    {
        var type = event.type;
        var button = event.button;
        //右键按下=>弹出菜单
        if(button == 3)
        {

        }
        //双击
        if(type == Gdk.EventType.DOUBLE_BUTTON_PRESS && button != 3)
        {

        }

        return false;
    }
}
