public class PageQuery
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


    public bool inspect(int page,string where,string sort)
    {
        var s1 = sort.strip();
        var s2 = where.strip();

        var reset = false;

        reset = (this.where != s1);

        if(!reset)
        {
            reset = (this.sort != s2);
        }

        if(reset)
        {
            this.page = 1;
        }
        else
        {
            this.page = page;
        }
        
        this.sort = s2;
        this.where = s1;

        return reset;
    }
}