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

    public static void addDataSource(Json.Node node,bool update) throws Error
    {
        lock(appDataFolder)
        {
            var filename = "%s%s".printf(appDataFolder,dbPreference);

            var file = File.new_for_path(filename);

            var parser = new Json.Parser();

            var create = false;
            //文件不存在->创建文件
            if((create = (!file.query_exists())
            {
                createAppFolder();
                file.create(FileCreateFlags.NONE);
                parser.load_from_data("[]");
            }

            var ioStream = file.open_readwrite();

            //从文件中加载数据
            if(!create)
            {
                var inputStream = ioStream.input_stream as FileInputStream;
                parser.load_from_stream(inputStream);
            }

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
