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

    public static void addDataSource(string uuid,Json.Node node,bool update) throws Error
    {
        lock(appDataFolder)
        {
            var filename = "%s%s".printf(appDataFolder,dbPreference);

            var file = File.new_for_path(filename);

            var parser = new Json.Parser();

            var create = false;
            //文件不存在->创建文件
            if((create = (!file.query_exists())))
            {
                createAppFolder();
            }

            var ioStream = file.replace_readwrite(null,false,FileCreateFlags.NONE);

            if(!create)
            {
                parser.load_from_stream(ioStream.input_stream);
            }
            else
            {
                parser.load_from_data("[]");
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
            var output = new DataOutputStream(ioStream.output_stream);
            output.put_string(jsonStr);
        }
    }

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
