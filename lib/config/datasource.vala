/**
 *
 * 枚举当前支持认证方式
 *
 */
public enum AuthModel
{
        /**
     *
     * 用户名/密码认证
     *
     */
    USER_PASSWORD,

    /**
     *
     *
     * Window系统帐号认证
     *
     **/
    WINDOW_CREDENTIALS,
    /**
     *
     * 无认证方式
     */
    NONE
}

/**
 *
 * 数据源保存方式
 *
 */
public enum SaveModel
{
    /**
     *
     *
     * 持久化保存
     *
     **/
    FOREVER,
    /**
     *
     *
     * 不持久化保存
     *
     *
     **/
    NEVER
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
     *
     * 数据源唯一id
     *
     **/
    public string uuid;
    /**
     *
     *
     * 数据源名称
     *
     *
     **/
    public string name;
    /**
     *
     *
     * 数据源备注
     *
     *
     **/
    public string comment;
    /**
     *
     * 数据库服务器主机
     *
     */
    public string host;

    /**
     *
     * 数据库服务器端口
     *
     */
    public int port;

    /**
     *
     * 连接池初始化尺寸
     *
     */
    public int initSize;
    /**
     *
     * 连接池最大尺寸
     *
     */
    public int maxSize;

    /**
     *
     * 获取连接最大等待时间(秒)
     *
     */
    public int maxWait;

    /**
     *
     * 认证用户名
     *
     */
    public string user;

    /**
     *
     * 认证密码
     *
     */
    public string password;

    /**
     *
     * 认证方式
     *
     */
    public AuthModel authModel;

    /**
     *
     *
     * 数据库
     *
     *
     **/
    public string database;

    /**
     *
     * 
     * 保存模式
     *   
     **/
    public SaveModel saveModel;

    /**
     *
     * 当前数据库类型
     *
     */
    public DatabaseType dbType;

    public DataSource(DatabaseType type){
        this.dbType = type;
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
