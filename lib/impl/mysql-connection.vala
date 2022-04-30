using Mysql;

public class MysqlConnection : SqlConnection
{
    private Database database;

    private DataSource dataSource;

    public MysqlConnection(DataSource dataSource,SqlConnectionPool? pool)
    {
        base(pool);
        this.dataSource = dataSource;
        this.database = new Database();
    }

    public MysqlConnection.whitout(DataSource dataSource)
    {
        this(dataSource,null);
    }


    public override void connect() throws FXError
    {
        if(this.active)
        {
            return;
        }

        string user = null;
        string password = null;

        if(this.dataSource.authModel == AuthModel.USER_PASSWORD)
        {
            user = this.dataSource.user;
            password = this.dataSource.password;
        }

        var success = this.database.real_connect(
            this.dataSource.host,
            user,
            password,
            null,
            this.dataSource.port,
            null,
            0
        );
        //数据库连接失败->抛出异常
        if(!success)
        {
            throw new FXError.ERROR(this.database.error());
        }

        this.active = true;
    }

    public override DatabaseInfo serverInfo() throws FXError
    {
        var code = database.query("SHOW VARIABLES");

        if( code != 0)
        {
            throw new FXError.ERROR(this.database.error());
        }

        string[] rows;
        var info = new DatabaseInfo();
        var rs = this.database.use_result();

        while((rows=rs.fetch_row())!=null){
           var field = rows[0];
           var value = rows[1];
           if(field == "version"){
               info.version = value;
           }
           if(field == "version_comment"){
               info.name = value;
           }
        }
        return info;
    }

     public override Gee.List<DatabaseSchema> schemas() throws FXError
     {
        this.connect();
        var sql = "SELECT * FROM information_schema.SCHEMATA";
        var code = this.database.query(sql);
        if( code != 0)
        {
            throw new FXError.ERROR(this.database.error());
        }
        string[] rows;
        var rs = this.database.use_result();
        var list = new Gee.ArrayList<DatabaseSchema>();
        while((rows = rs.fetch_row())!=null)
        {
            var item = new DatabaseSchema();
            item.name = rows[1];
            item.charset = rows[2];
            item.collation = rows[3];
            list.add(item);
        }
        return list;
     }

    public override Gee.List<string> tables(string schema,bool view) throws FXError
    {
        this.connect();
        var sql = "SELECT `TABLE_NAME` FROM information_schema.TABLES WHERE `TABLE_SCHEMA`='%s' %s"
            .printf(schema,view?"":"AND `TABLE_TYPE`='BASE TABLE'");
            stdout.printf("%s\n",sql);
        if( this.database.query(sql) != 0 )
        {
            throw new FXError.ERROR(this.database.error());
        }
        var list = new Gee.ArrayList<string>();
        var rs = this.database.use_result();
        
        string[] rows;
        while((rows = rs.fetch_row())!=null )
        {
            list.add(rows[0]);
        }

        return list;
    }


    public override void shutdown()
    {
        //
        // No need manual shutdown connection
        //
     }
}
