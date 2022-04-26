/**
 *
 * 连接失败
 *
 */
public errordomain SqlError
{
    /**
     *
     * 连接失败
     *
     */
    CONNECT_ERROR,

    /**
     *
     * SQL查询异常
     *
     */
    SQL_QUERY_ERROR
}

public errordomain PoolError
{
    /**
     *
     *
     * 没有空闲连接
     *
     **/
    NOT_FREE_CONNECTION
}



public errordomain DatabaseError
{
    /**
     *
     * 当前数据库暂不支持
     *
     */
    NOT_SUPPORT;
}
