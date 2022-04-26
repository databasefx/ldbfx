using Gee;


/**
 *
 * 数据库连接池封装
 *
 */
public class SqlConnectionPool<T>
{
    /**
     *
     * 空闲队列
     *
     */
    private ArrayQueue<T> freeQueue;

    /**
     *
     * 工作队列
     *
     */
    private ArrayQueue<T> workQueue;
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


    public SqlConnectionPool(DataSource dataSource)
    {
        this.mutex = new Object();
        this.initCapacity = false;
        this.dataSource = dataSource;
        this.freeQueue = new ArrayQueue<T>(this.equal);
        this.workQueue = new ArrayQueue<T>(this.equal);
    }

    /**
     *
     * 简单比较队列中两个对象是否相等
     *
     */
    private bool equal(T a,T b){
        return a==b;
    }


    public T getConnection() throws PoolError {
        T con = null;
        var thread = Thread.self<bool>();
        var startTime = get_real_time();
        var maxWait =get_real_time() + this.dataSource.maxWait*1000;
        while(true){
            con = this.getConnection0();
            //判断是否已经获取连接或者连接超时
            if(con != null || ( get_real_time() > maxWait)){
                break;
            }

            thread.usleep(500);
        }

        if(con == null)
        {
            throw new PoolError.NOT_FREE_CONNECTION(_("Not free connection"));
        }

        return con;
    }

    private T? getConnection0(){
        lock(mutex){
            var con = this.freeQueue.poll_head();
            //成功获取到连接
            if(con != null){
                return con;
            }
            return null;
        }
    }

    /**
     *
     * 归还连接
     *
     */
    public void conBack(T con){
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

    public SqlConnectionPool<T> capacity() throws DatabaseError
    {

        if(!this.initCapacity)
        {

            var type = this.dataSource._type;

            unowned var instance = DatabaseFeature.getFeature(type);

            if(!instance.impl)
            {
                throw new DatabaseError.NOT_SUPPORT(_("Not support"));
            }

            var maxSize = this.dataSource.maxSize;

            for(var i=0;i<maxSize;i++){
                //初始化MYSQL连接
                if(type == DatabaseType.MYSQL)
                {
                    this.freeQueue.add(new MysqlConnection(this.dataSource,this));
                }
            }

            this.initCapacity = true;
        }

        return this;
    }
}
