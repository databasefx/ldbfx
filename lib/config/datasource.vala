/**
 *
 * 枚举当前支持认证方式
 *
 */
public enum AuthModel
{
    /**
     *
     * 无认证方式
     */
    NONE,

    /**
     *
     * 用户名/密码认证
     *
     */
    USER_PASSWORD
}

/**
 *
 * 数据源配置
 *
 */
public class DataSource
{
    /**
     *
     * 数据库服务器主机
     *
     */
    public string host{
        set;
        get;
    }

    /**
     *
     * 数据库服务器端口
     *
     */
    public int port{
        set;
        get;
    }

    /**
     *
     * 连接池初始化尺寸
     *
     */
    public int initSize{
        set;
        get;
    }

    /**
     *
     * 连接池最大尺寸
     *
     */
    public int maxSize{
        set;
        get;
    }

    /**
     *
     * 获取连接最大等待时间(秒)
     *
     */
    public int maxWait{
        set;
        get;
    }

    /**
     *
     * 认证用户名
     *
     */
    public string user{
        set;
        get;
    }

    /**
     *
     * 认证密码
     *
     */
    public string password{
        set;
        get;
    }

    /**
     *
     * 认证方式
     *
     */
    public AuthModel authModel{
        set;
        get;
    }

    /**
     *
     * 当前数据库类型
     *
     */
    public DatabaseType _type{
        set;
        get;
    }

    public DataSource(DatabaseType type){
        this._type = type;
    }

    public string toString(){
        return """
        {
            "host":"%s",
            "port":"%d",
            "user":"%s",
            "password":"%s"
        }
        """.printf(host,port,user,password);
    }
}
