using Gtk;

/**
 *
 *
 * 枚举导航树列
 *
 **/
private enum NavTreeCol
{
    ICON,
    NAME,
    COL_NUM;
}

[GtkTemplate (ui = "/cn/navclub/dbfx/ui/window.ui")]
public class MainController : Gtk.ApplicationWindow {

    [GtkChild]
    private Gtk.TreeView navTree;
    [GtkChild]
    private Gtk.TreeViewColumn iconCol;
    [GtkChild]
    private Gtk.TreeViewColumn nameCol;

    private Gtk.ListStore treeModel;


	public MainController (Gtk.Application app) {
		Object (application: app);
		this.initNavTree();
	 }

    public void initNavTree()
    {
        this.treeModel = new Gtk.ListStore
        (
            NavTreeCol.COL_NUM,
            Type.OBJECT,
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

            this.treeModel.append(out iter);

            var img = new Gtk.Image.from_icon_name(feature.icon,Gtk.IconSize.DND);
            this.treeModel.set
            (
                iter,
                NavTreeCol.ICON,img.get_pixbuf(),
                NavTreeCol.NAME,name
            );
        }

        this.navTree.model = new TreeModelSort.with_model(this.treeModel);
        this.navTree.show_all();
    }

}
