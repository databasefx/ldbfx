public class PageQuery : Object
{
    /**
     *
     * 当前页数
     *
     */
    public int page;
    /**
     *
     * 当前页尺寸
     *
     */
    public int size;
    /**
     *
     * schema名
     *
     */
    public string schema{
        private set;
        get;
    }

    /**
     *
     * 表名
     *
     */
    public string table{
        private set;
        get;
    }

    /**
     *
     * 自定义查询条件
     *
     */
    public string where;

    /**
     *
     * 自定义排序方式
     *
     **/
    public string sort;


    public PageQuery(string schema,string table)
    {
        this.page = 0;
        this.size = 200;
        this.sort = "";
        this.where = "";

        this.table = table;
        this.schema = schema;
    }

    /**
     *
     *
     * 检查where和sort字段是否发生改变,如果发生改变将当前页系数重置到1
     *
     */
    public bool inspect(int page,string where,string sort)
    {
        var s1 = sort.strip();
        var s2 = where.strip();

        var reset = false;

        reset = (this.where != s2);

        if(!reset)
        {
            reset = (this.sort != s1);
        }

        if(reset)
        {
            this.page = 1;
        }
        else
        {
            this.page = page;
        }
        
        this.sort = s1;
        this.where = s2;

        return reset;
    }
}