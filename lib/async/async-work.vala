/**
 *
 * 任务详情
 *
 */
public delegate void WorkDetail();

/**
 *
 * 一个异步任务的封装
 *
 */
public class AsyncWork
{
    //当前任务优先级
    private int priority;

    //任务详情
    public WorkDetail work;

    //任务开始时间
    public int64 startTime{
        private set;
        get;
        default  = 0;
    }

    //任务结束时间
    private int64 endTime{
        private set;
        get;
        default =  0;
    }

    //任务耗时
    private int64 duration{
        private set{
            duration = value;
        }

        get {
           return endTime-startTime;
        }
    }

    private static ThreadPool<AsyncWork> pool;

    protected AsyncWork(WorkDetail work)
    {
        this.work = work;
        this.priority = 0;
    }

    protected void run()
    {

        this.startTime = get_monotonic_time();
        this.work();
        this.endTime = get_monotonic_time();
    }

    public async void execute()
    {
        pool.add(this);
    }

    public async void executePri(int priority)
    {
        this.priority = priority;
        this.execute();
    }

    /**
     *
     * 静态方法创建任务
     *
     */
    public static AsyncWork create(WorkDetail work){
        return new AsyncWork(work);
    }

    public static void createThreadPool(int maxThreads) throws ThreadError
    {
        pool = new ThreadPool<AsyncWork>.with_owned_data((work)=> { work.run();},3,true);

        //设置任务优先级
        pool.set_sort_function((w1,w2)=>{
            return (w1.priority < w2.priority)
                ?-1
                :(int)(w1.priority > w2.priority);
        });
    }

}
