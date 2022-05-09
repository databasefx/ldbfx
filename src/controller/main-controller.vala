using Gtk;

[GtkTemplate (ui = "/cn/navclub/dbfx/ui/main-window.xml")]
public class MainController : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned Stack stack;
    [GtkChild]
    public unowned Notebook notebook;
    [GtkChild]
    private unowned TreeView navTree;
    [GtkChild]
    private unowned TreeViewColumn iconCol;
    [GtkChild]
    private unowned TreeViewColumn nameCol;

    private Gtk.TreeStore treeModel;
    
    //保存引用,防止对象被回收
    private NavTreeEvent navTreeEvent;


	public MainController (Gtk.Application app) {
		Object (application: app);
		this.initNavTree();
	 }

    public void initNavTree()
    {
        this.treeModel = new Gtk.TreeStore
        (
            NavTreeCol.COL_NUM,
            Type.STRING,
            Type.STRING,
            Type.INT,
            Type.INT,
            Type.STRING
        );

        this.nameCol.set_expand(true);

        var node = AppConfig.fetchDataSource();
        var array = node.get_array();
        var elements = array.get_elements();
        foreach(var item in elements){
            var obj = item.get_object();
            var type = (DatabaseType)obj.get_int_member(Constant.TYPE);
            var name = obj.get_string_member(Constant.NAME);
            var feature = DatabaseFeature.getFeature(type);
            if (feature == null || !feature.impl)
            {
                continue;
            }

            var iter = new TreeIter();
            this.treeModel.append(out iter,null);


            this.treeModel.set
            (
                iter                                ,
                NavTreeCol.ICON     ,   feature.icon,
                NavTreeCol.NAME     ,   name        ,
                NavTreeCol.NT_ROW   ,   NTRow.ROOT  ,
                NavTreeCol.STATUS   ,   NavTRowStatus.INACTIVE,
                NavTreeCol.UUID     ,   obj.get_string_member(Constant.UUID)
            );
        }

        this.navTree.model = this.treeModel;
        //注册自定义弹出菜单
        this.navTreeEvent = new NavTreeEvent.register(this.navTree,this);
    }

    [GtkCallback]
    public void noteChildChange(Gtk.Widget child,uint page)
    {
        var size = this.notebook.get_n_pages();
        this.stack.set_visible_child_name(size > 0 ? "page1" : "page0");
    }
}
