public interface TabService
{
    /**
     *
     * Tab 实例
     *
     */
    public abstract NotebookTab notebookTab();


    /**
     *
     *
     * 当前Tab销毁时调用该函数
     *
     *
     **/
    public abstract void destory() throws FXError;
}