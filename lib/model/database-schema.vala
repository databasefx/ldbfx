/**
 *
 *
 * 数据库Scheme
 *
 * */
public class DatabaseSchema
{
    /**
     *
     *
     * Scheme名称
     *
     * */
    public string name;
    /**
     *
     * 字符集
     *
     * */
    public string charset;

    /**
     *
     *
     * 字符排序
     *
     * */
    public string collation{
        set;
        get;
    }
}
