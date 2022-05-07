using Gtk;

[GtkTemplate (ui = "/cn/navclub/dbfx/ui/main-window.ui")]
public class MainController : Gtk.ApplicationWindow {
    [GtkChild]
    private unowned Gtk.Toolbar navToolbar;
    [GtkChild]
    private unowned Gtk.TreeView navTree;
    [GtkChild]
    private unowned Gtk.TreeViewColumn iconCol;
    [GtkChild]
    private unowned Gtk.TreeViewColumn nameCol;
    [GtkChild]
    public unowned Gtk.Notebook notebook;
    [GtkChild]
    private unowned Gtk.Stack stack;

    private Gtk.TreeStore treeModel;

    private NavTreeEvent treeEvent;


	public MainController (Gtk.Application app) {
		Object (application: app);
		this.initNavTree();
	 }

    public void initNavTree()
    {
        //注册自定义弹出菜单
        this.treeEvent = new NavTreeEvent.register(this.navTree,this);

        this.treeModel = new Gtk.TreeStore
        (
            NavTreeCol.COL_NUM,
            Type.OBJECT,
            Type.STRING,
            Type.INT,
            Type.INT,
            Type.STRING
        );

        this.nameCol.set_expand(true);

        var node = AppConfig.fetchDataSource();
        var array = node.get_array();
        var elements = array.get_elements();
        var iconTheme = IconTheme.get_default();
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

            var pixbuf = iconTheme.load_icon(feature.icon,22,0);

            this.treeModel.set
            (
                iter                                ,
                NavTreeCol.ICON     ,   pixbuf      ,
                NavTreeCol.NAME     ,   name        ,
                NavTreeCol.NT_ROW   ,   NTRow.ROOT  ,
                NavTreeCol.STATUS   ,   NavTRowStatus.INACTIVE,
                NavTreeCol.UUID     ,   obj.get_string_member(Constant.UUID)
            );
        }

        this.navTree.model = this.treeModel;
        this.navTree.show_all();
    }

    [GtkCallback]
    public void noteChildChange(Gtk.Widget child,uint page)
    {
        var size = this.notebook.get_n_pages();
        this.stack.set_visible_child_name(size > 0 ? "page1" : "page0");
    }
}
