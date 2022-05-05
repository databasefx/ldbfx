public enum NTRow
{
    /**
     *
     * 数据库
     *
     **/
    ROOT,
    /**
     *
     *
     * schema
     *
     */
    SCHEMA,
    /**
     *
     * 表文件夹
     *
     **/
    TABLE_FOLDER,
    /**
     *
     * 视图文件夹
     *
     **/
    VIEW_FOLDER,
    /**
     *
     * 表
     *
     **/
    TABLE,
    /**
     *
     * 
     * 视图
     *
     *
     **/
     VIEW
}

/**
 *
 *
 * 枚举导航树列
 *
 **/
public enum NavTreeCol
{
    /**
     *
     * 图标列
     *
     **/
    ICON,
    /**
     *
     *
     * 名称列
     *
     **/
    NAME,
    /**
     *
     *
     * 列类别字段
     *
     **/
    NT_ROW,
    /**
     *
     * 当前行激活状态
     *
     **/
    STATUS,
    /**
     *
     * 数据源标识
     *
     **/
    UUID,
    /**
     *
     * 列数
     *
     **/
    COL_NUM;
}
/**
 *
 *枚举导航数菜单
 *
 **/
public enum NavTreeItem
{
    OPEN,
    BREAK_OFF,
    EDIT,
    DELETE,
    FLUSH,
    COMMAND_LINE,
    NEW_QUERY,
    DDL,
    CLEAR_TABLE,
    COPY,
    RENAME
}

public enum NavTRowStatus
{
    //非激活状态
    INACTIVE,
    //激活中
    ACTIVING,
    //已激活
    ACTIVED,
    //所有状态
    ANY
}
