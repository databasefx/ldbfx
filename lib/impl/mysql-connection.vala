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

    public override Gee.List<TableInfo> tables(string schema,bool view) throws FXError
    {
        this.connect();
        var sql = "SELECT `TABLE_NAME`,`TABLE_TYPE` FROM information_schema.TABLES WHERE `TABLE_SCHEMA`='%s' %s"
            .printf(schema,view?"AND `TABLE_TYPE`='VIEW'":"AND `TABLE_TYPE`='BASE TABLE'");
        if( this.database.query(sql) != 0 )
        {
            throw new FXError.ERROR(this.database.error());
        }
        var rs = this.database.use_result();
        var list = new Gee.ArrayList<TableInfo>();
        
        string[] rows;
        while((rows = rs.fetch_row())!=null )
        {
            var table = new TableInfo();
            table.name = rows[0];
            table.tableType = rows[1] == "BASE TABLE"? TableType.BASE_TABLE : TableType.VIEW ;

            list.add(table);
        }

        return list;
    }


    public override Gee.List<TableColumnMeta> tableColumns(string schema,string name) throws FXError
    {
        this.connect();
        var sql = """SELECT 
                        `COLUMN_NAME`,
                        `IS_NULLABLE`,
                        `DATA_TYPE`,
                        `COLUMN_DEFAULT`
                    FROM 
                        information_schema.COLUMNS 
                    WHERE
                        `TABLE_SCHEMA`='%s' 
                    AND 
                        `TABLE_NAME`='%s'""";
        sql = sql.printf(schema,name);
        if( this.database.query(sql) != 0 )
        {
            throw new FXError.ERROR(this.database.error());
        }

        string[] rows;
        var rs = this.database.use_result();
        var list = new Gee.ArrayList<TableColumnMeta>();
        while((rows =  rs.fetch_row()) != null)
        {
            
            var meta = new TableColumnMeta();
            meta.name = rows[0];
            meta.isNull = rows[1]=="YES";
            meta.originType = rows[2];

            list.add(meta);
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
