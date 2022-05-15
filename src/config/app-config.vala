using Environment;

//
// 数据库配置文件
//
const string dbPreference = "db-preference.json";

public class AppConfig
{
    //缓存json数据
    private static Json.Node node;

    //APP配置文件路径
    private static string appDataFolder;
    
    //缓存数据源
    private static Gee.List<DataSource> dataSources;

    /**
     *
     *
     * 初始化应用数据目录
     *
     */
    public static void initAppDataFolder()
    {
        dataSources = new Gee.ArrayList<DataSource>();
        switch(SYSTEM_TYPE){
            case "linux":
            case "macos":
                appDataFolder = get_home_dir()+"/."+PROJECT_NAME+"/";
            break;
            case "window":
                appDataFolder = get_variable("APPDATA")+"\\"+PROJECT_NAME+"\\";
            break;
        }
        debug("Current app data dir:"+appDataFolder);
    }

    /**
     *
     * 加载配置文件中的数据源
     *
     **/
    public static unowned Gee.List<DataSource> fetchDataSource()
    {
        var filename = "%s%s".printf(appDataFolder,dbPreference);

        var file = File.new_for_path(filename);

        var parser = new Json.Parser();

        if(!file.query_exists())
        {
            parser.load_from_data("[]");
        }
        else
        {
            parser.load_from_stream(file.read());
        }

        var array = (node = parser.get_root()).get_array();

        foreach(var item in array.get_elements())
        {
            dataSources.add(create(item.get_object()));
        }

        return dataSources;
    }

    /**
     *
     * 添加/更新数据源
     *
     */
    public static void addDataSource(DataSource dataSource,bool update) throws FXError
    {
        var filename = "%s%s".printf(appDataFolder,dbPreference);

        var file = File.new_for_path(filename);

        var exists = file.query_exists();
        //文件不存在->创建文件
        if(!exists)
        {
            createAppFolder();
            file.create(FileCreateFlags.NONE);
        }
        var array = node.get_array();
        if(update)
        {
            foreach(var node in array.get_elements())
            {
                var obj = node.get_object();
                var uuid = obj.get_string_member(Constant.UUID);
                if(uuid == dataSource.uuid)
                {
                    node.set_object(toJson(dataSource));
                    break;
                }
            }
        }
        else
        {
            array.add_object_element(toJson(dataSource));
        }

        var jsonStr = JsonUtil.jsonStr(node);
        var output = file.replace(null,false,FileCreateFlags.NONE);
        output.write(jsonStr.data);
    }

    /**
     *
     * 根据UUID获取数据源
     *
     *
     **/
    public static  DataSource? getDataSource(string uuid)
    {
        var array = node.get_array();
        foreach(var node in array.get_elements())
        {
            var obj = node.get_object();
            var uid = obj.get_string_member(Constant.UUID);
            if( uid == uuid){
                return create(obj);
            }
        }
        return null;
    }



    /**
     *
     * 创建配置根目录
     *
     */
    private static void createAppFolder() throws FXError
    {
        var file = File.new_for_path(appDataFolder);

        if(file.query_exists())
        {
            return;
        }

        try
        {
            //创建目录
           var success = file.make_directory();
           debug("Folder:[%s] create result:%s",appDataFolder,success ? "True" : "False");
        }
        catch(Error err)
        {
            warning("Config dir create fail:%s",err.message);
            throw new FXError.ERROR(err.message);
        }
    }

    private static DataSource create(Json.Object obj)
    {
        var dataSource = new DataSource(obj.get_int_member(Constant.TYPE));

        dataSource.maxWait = 3;
        dataSource.maxSize = 10;

        dataSource.name = obj.get_string_member(Constant.NAME);
        dataSource.user = obj.get_string_member(Constant.USER);
        dataSource.host = obj.get_string_member(Constant.HOST);
        dataSource.uuid = obj.get_string_member(Constant.UUID);
        dataSource.port = (int)obj.get_int_member(Constant.PORT);
        dataSource.password = obj.get_string_member(Constant.PASSWORD);
        dataSource.authModel = obj.get_int_member(Constant.AUTH_MODEL);
        dataSource.comment = obj.get_string_member(Constant.COMMENT);
        dataSource.saveModel = (int)obj.get_int_member(Constant.SAVE_MODEL);
        dataSource.dbType = (DatabaseType)obj.get_int_member(Constant.TYPE);

        return dataSource;   
    }

    private static Json.Object toJson(DataSource dataSource)
    {
            
        var builder = new Json.Builder();

        builder.begin_object();

        builder.set_member_name(Constant.UUID);
        builder.add_string_value(dataSource.uuid);

        builder.set_member_name(Constant.TYPE);
        builder.add_int_value(dataSource.dbType);

        builder.set_member_name(Constant.NAME);
        builder.add_string_value(dataSource.name);

        builder.set_member_name(Constant.COMMENT);
        builder.add_string_value(dataSource.comment);

        builder.set_member_name(Constant.DATABASE);
        builder.add_string_value(dataSource.database);

        builder.set_member_name(Constant.AUTH_MODEL);
        builder.add_int_value(dataSource.authModel);

        builder.set_member_name(Constant.HOST);
        builder.add_string_value(dataSource.host);

        builder.set_member_name(Constant.PORT);
        builder.add_int_value(dataSource.port);

        builder.set_member_name(Constant.SAVE_MODEL);
        builder.add_int_value(dataSource.saveModel);

        builder.end_object();

        var node = builder.get_root();
        return node.get_object();
    }
}
