using Gtk;

public class NavTreeCtx
{
    /**
     *
     * 显示时机 {@link NavTRowStatus}
     *
     */
    public NavTRowStatus status {
        private set;
        get;
    }
    public NavTreeItem item {
        private set;
        get;
    }

    public NavTreeCtx(NavTRowStatus status,NavTreeItem item)
    {
        this.item = item;
        this.status = status;
    }

    private static NavTreeCtx create(NavTRowStatus status,NavTreeItem item)
    {
        return new NavTreeCtx(status,item);
    }

    private static NavTreeCtx[] rootCtx = null;


    public static NavTreeCtx[] getRootCtx()
    {
        if(rootCtx == null)
        {
            rootCtx =
            {
                NavTreeCtx.create(NavTRowStatus.INACTIVE , NavTreeItem.OPEN),
                NavTreeCtx.create(NavTRowStatus.ACTIVED , NavTreeItem.BREAK_OFF),
                NavTreeCtx.create(NavTRowStatus.ANY , NavTreeItem.EDIT),
                NavTreeCtx.create(NavTRowStatus.ANY , NavTreeItem.DELETE)
            };
        }
        return rootCtx;
    }

}


/**
 *
 * 导航视图自定义弹出菜单
 *
 *
 **/
[GtkTemplate (ui = "/cn/navclub/dbfx/ui/nav-tree-menu.ui")]
public class NavTreeEvent : Gtk.Menu
{
    private unowned TreeView navTree;
    private unowned Gtk.TreeModel treeModel;
    private unowned MainController controller;


    public NavTreeEvent.register(TreeView navTree,MainController controller)
    {
        this.navTree = navTree;
        this.controller = controller;
        this.treeModel = navTree.get_model();
        this.navTree.button_press_event.connect(btnPreEvent);
    }

    private bool btnPreEvent(Gdk.EventButton event)
    {
        var type = event.type;
        var button = event.button;
        var iter = this.getSelectIter();
        if( iter != null )
        {
            //右键按下=>弹出菜单
            if(button == 3)
            {
               this.showMenu(iter,event);
            }
            //双击
            if(type == Gdk.EventType.DOUBLE_BUTTON_PRESS && button != 3)
            {

            }
        }
        return false;
    }

    private void showMenu(TreeIter iter,Gdk.EventButton event)
    {
        Value val;
        this.treeModel.get_value(iter,NavTreeCol.NT_ROW,out val);
        var row = (NTRow)val.get_int();
        var arr = new NavTreeCtx[0];
        if(row == NTRow.ROOT)
        {
            arr = NavTreeCtx.getRootCtx();
        }
        //菜单不存在则不显示
        if(arr.length == 0)
        {
            return;
        }
        this.treeModel.get_value(iter,NavTreeCol.STATUS,out val);
        var status = (NavTRowStatus)val.get_int();

        var index = 0;
        this.foreach((child)=>{
            child.visible = false;
            foreach(var temp in arr)
            {
                var _status = temp.status;
                if(temp.item == index && (_status == NavTRowStatus.ANY || status == _status))
                {
                    child.visible = true;
                    break;
                }
            }
            ++index;
        });

        this.show();
        this.popup_at_pointer(event);
    }

    /**
     *
     *
     * 响应打开Open事件
     *
     **/
    [GtkCallback]
    public bool open(Gtk.Widget item,Gdk.EventButton event)
    {
        var iter = this.getSelectIter();
        if(iter == null)
        {
            return false;
        }
        Value val;

        //
        // 获取行类别
        //
        this.treeModel.get_value(iter,NavTreeCol.NT_ROW,out val);
        var row = (NTRow)val.get_int();

        //
        // 获取行状态
        //
        this.treeModel.get_value(iter,NavTreeCol.STATUS,out val);
        var status = (NavTRowStatus)val.get_int();

        //
        // 获取行id
        //
        this.treeModel.get_value(iter,NavTreeCol.UUID, out val);
        var uuid = val.get_string();

        if(row == NTRow.ROOT)
        {
            this.openRoot.begin(iter,status,uuid);
        }

        return false;
    }

    private async void openRoot(TreeIter iter,NavTRowStatus status,string uuid)
    {
        if(status != NavTRowStatus.INACTIVE)
        {
            return;
        }

        Value val = new Value(typeof(string));
        val.set_string("NavTRowStatus.ACTIVING");

        var work = AsyncWork.create(()=>{

            try
            {
                var context = Application.ctx;
                var pool = context.getConnPool(uuid);
            }
            catch(FXError e)
            {

            }
            finally
            {
                SourceFunc callback = openRoot.callback;
                Idle.add(callback);
            }
        });
        work.execute();

        yield;
    }


    public void getColValue(TreeIter iter,NavTreeCol col,out Value val)
    {
        this.treeModel.get_value(iter,col,out val);
    }

    /**
     *
     *
     * 从{@link TreeModelSort}中获取{@link ListStore}
     *
     **/
    private Gtk.ListStore listStore()
    {
        return (Gtk.ListStore)this.treeModel;
    }

    /**
     *
     * 获取当前选中行
     *
     *
     **/
    private TreeIter? getSelectIter()
    {
        TreeIter iter;
        var selection = this.navTree.get_selection();
        var selected = selection.get_selected(out treeModel,out iter);
        if(!selected)
        {
            return null;
        }
        return iter;
    }
}
