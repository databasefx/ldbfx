public interface TabService : GLib.Object
{
    /**
     *
     * 
     *  获取Tab实例
     *
     **/
    public abstract NotebookTab tab();
    
    /**
     *
     *
     * 获取Notebook实例
     *
     **/
    public unowned Gtk.Notebook getNotebook(){
        return Application.ctx.controller.notebook;
    }


    /**
     *
     * 
     * 获取Tab路径字符串
     *
     **/
    public abstract string getPath();


    /**
     *
     *
     * 当前Tab销毁时调用该函数
     *
     *
     **/
    public abstract void destory() throws FXError;
}