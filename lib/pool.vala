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


    public T getConnection(){
        var con = this.getConnection0();

        var maxWait = this.dataSource.maxWait;
        //连接获取失败
        if(con == null || maxWait <= 0){
            return null;
        }
        //线程等待对应时间
        Thread.usleep(maxWait*1000);
        //重新获取连接
        return this.getConnection0();
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
