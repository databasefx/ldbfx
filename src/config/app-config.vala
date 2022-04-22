using Environment;

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
                appDataFolder = get_home_dir()+"/."+PROJECT_NAME;
            break;
            case "window":
                appDataFolder = get_variable("APPDATA")+"\\"+PROJECT_NAME;
            break;
        }

        debug("Current app data dir:"+appDataFolder);
    }
}
