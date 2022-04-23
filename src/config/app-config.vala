using Environment;

//
// 数据库配置文件
//
const string dbPreference = "db-preference.json";

public class AppConfig
{
    public static string appDataFolder;

    /**
     *
     *
     * 初始化应用数据目录
     *
     */
    public static void initAppDataFolder()
    {

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
    public static Json.Node fetchDataSource()
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

        return parser.get_root();
    }

    /**
     *
     * 添加/更新数据源
     *
     */
    public static void addDataSource(string uuid,Json.Node node,bool update) throws Error
    {
        var filename = "%s%s".printf(appDataFolder,dbPreference);

        var file = File.new_for_path(filename);

        var parser = new Json.Parser();

        var exists = file.query_exists();
        //文件不存在->创建文件
        if(!exists)
        {
            createAppFolder();
            parser.load_from_data("[]");
            file.create(FileCreateFlags.NONE);
        }
        else
        {
            parser.load_from_stream(file.read());
        }

        var root = parser.get_root();
        unowned var array = root.get_array();
        if(update)
        {
            foreach(var _node in array.get_elements())
            {
                var obj = _node.get_object();
                var _uuid = obj.get_string_member(Constant.UUID);
                if(_uuid == uuid )
                {
                    _node.set_object(node.get_object());
                    break;
                }
            }
        }
        else
        {
            array.add_object_element(node.get_object());
        }

        var jsonStr = JsonUtil.jsonStr(root);
        var output = file.replace(null,false,FileCreateFlags.NONE);
        output.write(jsonStr.data);
    }

    /**
     *
     * 创建配置根目录
     *
     */
    private static void createAppFolder() throws Error
    {
        var file = File.new_for_path(appDataFolder);

        if(file.query_exists())
        {
            return;
        }

        //创建目录
        file.make_directory();
    }

}
