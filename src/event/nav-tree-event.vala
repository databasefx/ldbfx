using Gtk;

public class NTRowMMeta
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

    public string name {
        private set;
        get;
    }

    public string action{
        private set;
        get;
    }

    public NTRowMMeta(NavTRowStatus status,string name,string action)
    {
        this.name = name;
        this.action = action;
        this.status = status;
    }

    public static NTRowMMeta create(NavTRowStatus status,string name,string action)
    {
        return new NTRowMMeta(status,name,action);
    }

}

public const string NAV_OPEN = "nav.open";
public const string NAV_EDIT = "nav.edit";
public const string NAV_DEL = "nav.delete";
public const string NAV_BREAK_OFF = "nav.breakoff";


public class NavTreeEvent
{
    private static NTRowMMeta[] rootMetas = 
    {
        NTRowMMeta.create(NavTRowStatus.INACTIVE , _("Open"),NAV_OPEN),
        NTRowMMeta.create(NavTRowStatus.ACTIVED , _("Break off"),NAV_BREAK_OFF),
        NTRowMMeta.create(NavTRowStatus.INACTIVE , _("Edit"),NAV_EDIT),
        NTRowMMeta.create(NavTRowStatus.INACTIVE , _("Delete"),NAV_DEL)
    };

    private const GLib.ActionEntry[] actionEntries =
    {
        { NAV_OPEN,         open        },
        { NAV_BREAK_OFF,    breakOff    },
        { NAV_EDIT,         navEdit     },
        { NAV_DEL,          navDel      }
    };

    private GestureClick rGesture;
    private GestureClick lGesture;
    private PopoverMenu popoverMenu;

    private unowned TreeView navTree;
    private unowned TreeModel treeModel;
    private weak MainController controller;

    

    public NavTreeEvent.register(TreeView navTree,MainController controller)
    {
        this.navTree = navTree;
        this.controller = controller;
        this.treeModel = navTree.get_model();

        this.rGesture = new GestureClick();
        this.lGesture = new GestureClick();
        
        this.navTree.add_controller(rGesture);
        this.navTree.add_controller(lGesture);

        this.lGesture.set_button(Gdk.BUTTON_PRIMARY);
        this.rGesture.set_button(Gdk.BUTTON_SECONDARY);
        
        this.rGesture.pressed.connect(this.rightPreEvent);
        this.lGesture.pressed.connect(this.leftPreEvent);

        this.popoverMenu = new PopoverMenu.from_model(null);
        this.popoverMenu.set_autohide(true);
        this.popoverMenu.set_parent(this.navTree);

        //调整树形视图缩进
        this.navTree.row_collapsed.connect((a,b)=>{
            this.navTree.columns_autosize();
        });

        Application.ctx.add_action_entries(actionEntries,this);
    }
    /*
     *
     *
     * 导航树触发编辑
     *
     **/
    private void navEdit()
    {
        var iter = this.getSelectIter();
        if(iter == null)
        {
            return;
        }
        Value val;
        //
        // 获取行类别
        //
        this.treeModel.get_value(iter,NavTreeCol.NT_ROW,out val);
        var at = (NTRow)val.get_int();
        if(at == NTRow.ROOT)
        {
            this.treeModel.get_value(iter,NavTreeCol.UUID,out val);
            new ConnectDialog.fromEdit(val.get_string());
        }
    }
    /**
     *
     * 删除数据源
     *
     */
    private void navDel()
    {
        var iter = this.getSelectIter();
        if(iter == null){
            return;
        }

        //
        // 获取行类别
        //
        Value val;
        this.treeModel.get_value(iter,NavTreeCol.NT_ROW,out val);
        var at = (NTRow)val.get_int();
        if(at == NTRow.ROOT)
        {
            var alert = FXAlert.confirm(_("_Delete warn"),_("_Delete db"));
            alert.response.connect((ok)=>{
                if(!ok)
                {
                    return;
                }
                this.treeModel.get_value(iter,NavTreeCol.UUID,out val);
                //删除缓存
                AppConfig.deleteById(val.get_string(),true);
                //移除当前行
                this.treeStore().remove(ref iter);
            });
        }
    }
    /**
     *
     *
     * 左键按下
     *
     */
    private void leftPreEvent(int num,double x,double y)
    {
        if( num > 1)
        {
            this.open();
        }
        this.lGesture.set_state(EventSequenceState.CLAIMED);
    }

    /**
     *
     *
     *  右键按下
     *
     */
    private void rightPreEvent(int num,double x,double y)
    {
        var iter = this.getSelectIter();
        Menu menu = null;
        if(iter != null && (menu =  this.getRowMenuItem(iter)) != null)
        {
            this.popoverMenu.menu_model = menu;
            this.popoverMenu.set_pointing_to({(int)x,(int)y,1,1});
            this.popoverMenu.visible = true;
        }
        this.rGesture.set_state(EventSequenceState.CLAIMED);
    }

    private Menu? getRowMenuItem(TreeIter iter){
        
        Value val;
        
        this.treeModel.get_value(iter,NavTreeCol.NT_ROW,out val);
        
        var row = (NTRow)val.get_int();
        NTRowMMeta[] arr = null;
        
        if(row == NTRow.ROOT)
        {
            arr = rootMetas;
        }
        
        Menu menu = null;
       
        if(arr != null && arr.length > 0)
        {
            menu = new Menu();
            this.treeModel.get_value(iter,NavTreeCol.STATUS,out val);
            var status = (NavTRowStatus)val.get_int();
            foreach(var meta in arr)
            {
                if(meta.status == NavTRowStatus.ANY || status == meta.status)
                {
                    menu.append(meta.name,"app."+meta.action);
                }
            }
        }
        return menu;
    }

    /**
     *
     *
     * 响应打开Open事件
     *
     **/
    private void open()
    {
        var iter = this.getSelectIter();
        if(iter == null)
        {
            return;
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
        
        var pathStr = this.treeModel.get_string_from_iter(iter);
        var treePath = new TreePath.from_string(pathStr);
        var isExpand = this.navTree.is_row_expanded(treePath);
        var beforeEnd = false;
        if(status == NavTRowStatus.ACTIVED || (beforeEnd = (status == NavTRowStatus.ACTIVING)))
        {
            if(!beforeEnd)
            {
                collExpand(iter,isExpand);
            }
            return;
        }

        if(row == NTRow.ROOT)
        {
            this.fetchSchema(iter,uuid);
        }

        if(row == NTRow.SCHEMA)
        {
            this.fetchTable(iter,uuid);
        }

        if(row == NTRow.TABLE || row == NTRow.VIEW)
        {
            this.loadTable(row == NTRow.VIEW, iter, uuid );
        }
    }

    /**
     *
     * 
     * 断开连接
     *
     **/
    public void breakOff()
    {
        var iter = this.getSelectIter();
        if( iter == null )
        {
            return;
        }

        this.clear(iter);
        this.treeStore().set_value(
            iter,
            NavTreeCol.STATUS,
            NavTRowStatus.INACTIVE
        );
        this.navTree.columns_autosize();

        Value val;
        this.treeModel.get_value(iter,NavTreeCol.UUID,out val);
        Application.ctx.removePool(val.get_string());
    }

    /**
     *
     *
     * 将表信息加载到可视化界面中
     *
     */
    public async void loadTable(bool view,TreeIter iter,string uuid)
    {
        var str = this.treeModel.get_string_from_iter(iter);
        var path = @"$uuid:$str";
        if( Application.ctx.tabExist(path,true) != -1)
        {
            return;
        }
        var pathVal = this.getPathValue(iter);
        Application.ctx.addTab(new NotebookTable(path,pathVal,view),true);
    }

    /**
     *
     *
     * 获取schema下的表
     *
     **/
    private async void fetchTable(TreeIter iter,string uuid)
    {
        this.updateNTStatus(iter,NavTRowStatus.ACTIVING);

        Value val = new Value(typeof(string));

        this.treeModel.get_value(iter,NavTreeCol.NAME, out val);

        FXError error = null;
        
        //基础表
        Gee.List<TableInfo> tables = null;
        //视图
        Gee.List<TableInfo> views  = null;

        SourceFunc callback = fetchTable.callback;

        var work = AsyncWork.create(()=>{
            SqlConnection con = null;
            try
            {
                con  = Application.getConnection(uuid);
                tables = con.tables(val.get_string(),false);
                views  = con.tables(val.get_string(),true);
            }
            catch(FXError e)
            {
                warning("Query table list fail:%s".printf(e.message));
                error = e;
            }
            finally
            {
                con.close();
                Idle.add(callback);
            }
        });
        work.execute();

        yield;

        this.updateNTStatus(iter,error != null ? NavTRowStatus.INACTIVE : NavTRowStatus.ACTIVED );

        if(error != null)
        {
            return;
        }
        this.createTableOrView(iter,tables,false,uuid);
        this.createTableOrView(iter,views,true,uuid);
    }

    private void createTableOrView(TreeIter parent,Gee.List<TableInfo> list,bool view,string uuid)
    {
        TreeIter iter;
        this.treeStore().append(out iter,parent);
        this.treeStore().set(
            iter,
            NavTreeCol.UUID,uuid,
            NavTreeCol.ICON,"dbfx-folder",
            NavTreeCol.NAME,view?_("views"):_("tables"),
            NavTreeCol.STATUS,NavTRowStatus.INACTIVE,
            NavTreeCol.NT_ROW,view ? NTRow.VIEW_FOLDER : NTRow.TABLE_FOLDER,
            -1
        );
        
        //设置为激活状态
        this.updateNTStatus(iter,NavTRowStatus.ACTIVED);
        
        TreeIter child;
        foreach(var table in list)
        {
            this.treeStore().append(out child,iter);
               this.treeStore().set(
                child,
                NavTreeCol.NAME,table.name,
                NavTreeCol.ICON,view?"dbfx-view":"dbfx-table",
                NavTreeCol.NT_ROW,!view ? NTRow.TABLE : NTRow.VIEW,
                NavTreeCol.STATUS,NavTRowStatus.INACTIVE,
                NavTreeCol.UUID,uuid,
                -1
            );
        }
        this.collExpand(parent,false);
    }
    /**
     *
     *
     * 获取Schema列表
     *
     */
    private async void fetchSchema(TreeIter iter,string uuid)
    {
        //更新为激活中状态
        this.updateNTStatus(iter,NavTRowStatus.ACTIVING);

        FXError error = null;
        Gee.List<DatabaseSchema> list = null;
        SourceFunc callback = fetchSchema.callback;

        var work = AsyncWork.create(()=>{
            SqlConnection con = null;
            try
            {
                 var connection = Application.ctx.getConnection(uuid);
                 var dataSource = connection.dataSource;
                 var database = dataSource.database;
                 
                 list = connection.schemas();

                 var i = -1;
                 
                 if(StrUtil.isNotBlack(database))
                 {
                    var j = 0;
                    foreach(var schema in list)
                    {
                        if(schema.name == database)
                        {
                            i = j;
                            break;
                        }
                        ++j;
                    }
                 }
                 if(i != -1)
                 {
                     var target =  list.remove_at(i);
                     list.clear();
                     list.add(target);
                 }
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
                if( error != null )
                {
                    Application.ctx.removePool(uuid);
                }
                Idle.add(callback);
            }
        });

        work.execute();

        yield;

        //根据是否发生错误决定状态
        this.updateNTStatus( iter , error == null ? NavTRowStatus.ACTIVED : NavTRowStatus.INACTIVE );

        if( error != null )
        {
            FXAlert.warn(_("_Open data source fail"),error.message);
            return;
        }
        foreach(var schema in list)
        {
            TreeIter child = {0};
            this.treeStore().append(out child,iter);
            this.treeStore().set(
                child,
                NavTreeCol.ICON,"dbfx-schema",
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
        //非激活状态=>清空子节点
        if (status == NavTRowStatus.INACTIVE)
        {
            this.clear(iter);
        }
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
    /**
     *
     * 获取指定路径值,以`:`分隔
     *
     **/
    private string getPathValue(TreeIter iter)
    {
        TreeIter lIter;
        TreePath path;
        var iterStr = this.treeModel.get_string_from_iter(iter);

        var index = 0;
        var pathStr = "";
        string[] temp = {};
        var paths = iterStr.split(":");
        var val = new Value(typeof(string));

        var pathVal = "";

        foreach(unowned string str  in paths)
        {
            if( index != 0 )
            {
                pathStr = @"$pathStr:$str";
            }
            else
            {
                pathStr = str;
            }
            path = new TreePath.from_string(pathStr);
            this.treeModel.get_iter(out lIter,path);
            this.treeModel.get_value(lIter,NavTreeCol.NAME,out val);
            
            pathVal += ((index == 0 ?"":":")+val.get_string());

            index++;
        }
        
        return pathVal;
    }
}
