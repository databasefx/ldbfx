public class TableColumnMeta
{
    /**
     *
     * 列名
     *    
     **/
    public string name{
        set;
        get;
    }

    /*
     *
     * 是否可为空
     *
     **/
    public bool isNull{
        set;
        get;
    }

    /**
     *
     * 原始类型
     *
     **/
    public string originType{
        set;
        get;
    }
}