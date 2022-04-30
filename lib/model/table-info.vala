public enum TableType
{
    /**
     *
     *
     * 基础表
     *
     **/
    BASE_TABLE,
    /**
     *
     * 视图
     *
     **/
    VIEW
}
public class TableInfo : GLib.Object
{
    /*
     *
     * 表名
     *
     **/
    public string name{
        get;
        set;
    }
    /*
     *
     * 表类型
     *
     **/
    public TableType  tableType{
        set;
        get;
    }
}