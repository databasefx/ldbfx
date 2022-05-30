public enum TabScheme
{
    TABLE,
    DDL;

    public static string toFullPath(TabScheme schema,string path)
    {
        string prefix;
        if(schema == TABLE)
        {
            prefix = "table";
        }
        else if (schema == DDL)
        {
            prefix = "ddl";
        }
        else
        {
            prefix = "app";
        }
        return @"$prefix:$path";
    }
}

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
    public unowned Gtk.Notebook notebook(){
        return Application.ctx.controller.notebook;
    }


    /**
     *
     * 
     * 获取Tab路径字符串
     *
     **/
    public abstract string path();


    /**
     *
     *
     * 当前Tab销毁时调用该函数
     *
     *
     **/
    public virtual void destory() throws FXError
    {

    }


    /**
     *
     *
     *  获取指定位置值
     * 
     *
     **/
    protected virtual string getPosVal(string str,int pos)
    {
        var array = str.split(":");
        var len = array.length;
        pos = pos < 0 ? len+pos : pos;
        return array[pos];
    }


    /**
     *
     *
     * 获取当前视图组件
     *
     *
     */
    public abstract unowned Gtk.Widget content();



    /**
     *
     *
     * Tab scheme
     *
     *
     */
    public abstract TabScheme scheme();
}