/**
 *
 *
 * 数据库连接封装
 *
 */
public abstract class SqlConnection
{
    /**
     *
     * 数据库连接池
     *
     */
    protected SqlConnectionPool? pool{
        set;
        get;
    }

    /**
     *
     * 判断当前连接是否已经连接
     *
     */
    protected bool active{
        set;
        get;
    }

    protected SqlConnection(SqlConnectionPool? pool){
        this.pool = pool;
    }

    /**
     *
     * 连接到指定数据库
     *
     */
    public abstract void connect() throws FXError;


    /**
     *
     * 获取服务器信息
     *
     */
    public abstract DatabaseInfo serverInfo() throws FXError;


    /**
     *
     * 获取数据库schema列表
     *
     *
     * */
    public abstract Gee.List<DatabaseSchema> schemas() throws FXError;

    /**
     *
     * 关闭当前连接(放回连接池中)
     *
     */
    public void close(){
        if( this.pool == null )
        {
            return;
        }
        this.pool.back(this);
    }

    /**
     *
     * 关闭当前连接
     *
     */
    public abstract void shutdown();
}