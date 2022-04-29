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
                this.open(null,null);
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
    public bool open(Gtk.Widget? item,Gdk.EventButton? event)
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

    /**
     *
     * 
     * 断开连接
     *
     **/
    [GtkCallback]
    public bool breakOff(Gtk.Widget item,Gdk.EventButton event)
    {
        var iter = this.getSelectIter();
        if( iter == null )
        {
            return false;
        }
        this.clear(iter);
        var val = new Value(typeof(string));
        this.treeModel.get_value(iter,NavTreeCol.UUID,out val);
        var uuid = val.get_string();
        //移除连接池
        Application.ctx.removePool(uuid);
        this.treeStore().set_value( iter , NavTreeCol.STATUS , NavTRowStatus.INACTIVE );
        return false;
    }

    private async void openRoot(TreeIter iter,NavTRowStatus status,string uuid)
    {
        if(status != NavTRowStatus.INACTIVE)
        {
            return;
        }

        //更新为激活中状态
        this.updateNTStatus(iter,NavTRowStatus.ACTIVING);

        FXError error = null;
        Gee.List<DatabaseSchema> list = null;

        var work = AsyncWork.create(()=>{
            SqlConnection con = null;
            try
            {
                var context = Application.ctx;
                var pool = context.getConnPool(uuid);
                con = pool.getConnection();
                list = con.schemas();
            }
            catch(FXError e)
            {
                warning("Open/Query database schema fail:%s".printf(e.message));
                error = e;
            }
            finally
            {
                //关闭连接
                if( con != null ){
                    con.close();
                }

                //清除连接池
                if( error == null )
                {
                    Application.ctx.removePool(uuid);
                }
                SourceFunc callback = openRoot.callback;
                Idle.add(callback);
            }
        });

        work.execute();

        yield;

        //根据是否发生错误决定状态
        this.updateNTStatus( iter , error == null ? NavTRowStatus.ACTIVED : NavTRowStatus.INACTIVE );

        if( error != null )
        {
            
            return;
        }
        var pixbuf =  IconTheme.get_default().load_icon("dbfx-schema",22,0);
        foreach(var schema in list)
        {
            TreeIter child = {0};
            this.treeStore().append(out child,iter);
            this.treeStore().set(
                child,
                NavTreeCol.ICON,pixbuf,
                NavTreeCol.NAME,schema.name,
                NavTreeCol.NT_ROW,NTRow.SCHEMA,
                NavTreeCol.STATUS,NavTRowStatus.INACTIVE,
                NavTreeCol.UUID,uuid,
                -1
            );
        }
        if ( list.size > 0 )
        {
            this.collExpand(iter,false);
        }
    }

    private void collExpand(TreeIter iter,bool collapse)
    {
        var pathStr = this.treeModel.get_string_from_iter(iter);
        var treePath = new TreePath.from_string(pathStr);
        if(collapse)
        {
            this.navTree.collapse_row(treePath);
        }
        else
        {
            this.navTree.expand_row(treePath,false);    
        }
    }

    /**
     *
     *
     * 从{@link TreeModel}中获取{@link TreeStore}
     *
     **/
    private Gtk.TreeStore treeStore()
    {
        return (Gtk.TreeStore)this.treeModel;
    }

    /**
     *
     * 更新某一行状态
     *
     **/
    private void updateNTStatus(TreeIter iter,NavTRowStatus status)
    {
        var val = new Value(typeof(int));
        val.set_int(status);
        this.treeStore().set_value(iter,NavTreeCol.STATUS,val);
    }

    /**
     *
     * 
     * 清除指定行子节点
     *    
     **/
    private void clear(TreeIter? parent)
    {
        TreeIter child;
        while(this.treeModel.iter_children(out child,parent))
        {
            this.treeStore().remove(ref child);
        }
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