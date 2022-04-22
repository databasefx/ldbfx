/**
*
* 枚举数据库类型
*
*/
public enum DatabaseType
{
    MYSQL,
    SQLITE,
    ORACLE
}

/**
*
*
* 配置当前支持数据库特征信息
*
*
*/
public class DatabaseFeature : Object {

    //数据库名称
    public string name
    {
        private set;
        get;
    }

    //数据库图标
    public string icon
    {
        private set;
        get;
    }

    //当前数据库类型
    public DatabaseType _type
    {
        private set;
        get;
    }

    //当前版本是否支持
    public bool impl
    {
        private set;
        get;
    }

    public DatabaseFeature(string name,string icon,DatabaseType type,bool impl)
    {
        this._type = type;
        this.impl = impl;
        this.name = name;
        this.icon = icon;
    }

    private static DatabaseFeature[] features = null;

    public static DatabaseFeature[] getFeatures()
    {
        if(features == null )
        {
            features =
            {
                new DatabaseFeature("MySQL","dbfx-mysql",DatabaseType.MYSQL,true),
                new DatabaseFeature("SQLite","dbfx-sqlite",DatabaseType.SQLITE,false)
            };
        }
        return features;
    }

    public static unowned DatabaseFeature? getFeature(DatabaseType type)
    {
        foreach(unowned var feature in features)
        {
            if(feature._type == type)
            {
                return feature;
            }
        }

        return null;
    }

}
