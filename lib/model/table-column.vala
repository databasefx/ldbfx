public class TableColumnMeta
{
    /**
     *
     * 列名
     *    
     **/
    public string name;
    /*
     *
     * 是否可为空
     *
     **/
    public bool isNull;

    /**
     *
     * 原始类型
     *
     **/
    public string originType;


    /**
     *
     * 创建空列
     *
     */
    public TableColumnMeta.empty()
    {
        this.name = "";
        this.isNull = false;
    }
}