using Gee;


/**
 *
 * 数据库连接池封装
 *
 */
public class SqlConnectionPool
{
    /**
     *
     * 空闲队列
     *
     */
    private ArrayQueue<SqlConnection> freeQueue;

    /**
     *
     * 工作队列
     *
     */
    private ArrayQueue<SqlConnection> workQueue;
    /**
     *
     * Mutlip thread lock
     *
     */
    private Object mutex;

    /**
     *
     * 数据源
     *
     */
    private DataSource dataSource;


    private bool initCapacity;


    public SqlConnectionPool(DataSource dataSource) throws FXError
    {
        this.mutex = new Object();
        this.initCapacity = false;
        this.dataSource = dataSource;
        this.freeQueue = new ArrayQueue<SqlConnection>(this.equal);
        this.workQueue = new ArrayQueue<SqlConnection>(this.equal);
        //初始化扩容
        this.capacity();
    }

    /**
     *
     * 简单比较队列中两个对象是否相等
     *
     */
    private bool equal(SqlConnection a,SqlConnection b){
        return a==b;
    }


    public SqlConnection getConnection() throws FXError {
        SqlConnection con = null;
        var thread = Thread.self<bool>();
        var startTime = get_real_time();
        var maxWait =get_real_time() + this.dataSource.maxWait * 1000;
        while(true)
        {
            con = this.getConnection0();
            //判断是否已经获取连接或者连接超时
            if(con != null || ( get_real_time() > maxWait)){
                break;
            }

            thread.usleep(500);
        }

        if(con == null)
        {
            throw new FXError.ERROR(_("Not free connection"));
        }

        return con;
    }

    private SqlConnection? getConnection0(){
        lock(mutex){
            //从尾部获取连接对象,增加连接复用概率
            var con = this.freeQueue.poll_tail();
            //成功获取到连接,添加到工作队列中
            if(con != null){
                this.workQueue.add(con);
            }
            return con;
        }
    }

    /**
     *
     * 归还连接
     *
     */
    public void back(SqlConnection con){
        lock(mutex){
            var exist = this.workQueue.remove(con);
            if(!exist){
                warning("Connection already back?");
                return;
            }
            //将连接重新放入队列
            this.freeQueue.add(con);
        }
    }

    /**
     *
     *
     * 清除连接池缓存连接
     *
     **/
    public void shutdown()
    {
        this.workQueue.clear();
        this.freeQueue.clear();
    }

    private SqlConnectionPool capacity() throws FXError
    {
        if(!this.initCapacity)
        {
            var type = this.dataSource.dbType;

            unowned var instance = DatabaseFeature.getFeature(type);

            if(!instance.impl)
            {
                throw new FXError.ERROR(_("Not support"));
            }

            var maxSize = this.dataSource.maxSize;

            for(var i= 0 ; i < maxSize ; i++){
                SqlConnection con = null;
                
                //初始化MYSQL连接
                if(type == DatabaseType.MYSQL)
                {
                    con = new MysqlConnection(this.dataSource,this);
                }

                //初始化Sqlite连接
                if(type == DatabaseType.SQLITE)
                {
                    con = new SqliteConnection(this.dataSource,this);
                }

                this.freeQueue.add(con);
            }

            this.initCapacity = true;
        }

        return this;
    }
}
