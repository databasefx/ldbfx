using Gtk;

[GtkTemplate (ui = "/cn/navclub/dbfx/ui/window.ui")]
public class MainController : Gtk.ApplicationWindow {

	public MainController (Gtk.Application app) {
		Object (application: app);
	 }

}
