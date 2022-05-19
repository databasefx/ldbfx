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

    public MysqlConnection.without(DataSource dataSource)
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
        this.database.select_db("information_schema");
        string sql;
        if(view)
        {
            sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '%s' ORDER BY `TABLE_NAME` ASC";
        }
        else
        {
            sql = "SELECT `TABLE_NAME` FROM information_schema.TABLES WHERE `TABLE_SCHEMA`='%s' ORDER BY `TABLE_NAME` ASC";
        }
    
        if( this.database.query(sql.printf(schema)) != 0 )
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
            table.tableType = view? TableType.VIEW : TableType.BASE_TABLE;

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


    /**
     *
     * 分页查询数据
     *
     **/
    public override Gee.List<string> pageQuery(string schema,string table,int page,int size) throws FXError
    {
        this.connect();

        var offset = (page - 1) * size;
        var sql = @"SELECT * FROM $schema.$table LIMIT  $offset,$size";
        
        if(this.database.query(sql) != 0)
        {
            throw new FXError.ERROR(this.database.error());
        }

        string[] rows;
        var rs = this.database.use_result();
        var list = new Gee.ArrayList<string>();
        while((rows=rs.fetch_row()) != null)
        {
            foreach (var item in rows)
            {

                list.add(item == null ? Constant.NULL_SYMBOL : item);
            }    
        }
        return list;
    }

    /**
     *
     * 统计某张表数据条数
     *
     */
    public override int64 count(string schema,string table) throws FXError
    {
        this.connect();
        var sql = @"SELECT COUNT(*) FROM $schema.$table";
        if(this.database.query(sql) != 0)
        {
            throw new FXError.ERROR(this.database.error());
        }
        var rs = this.database.use_result();
        var rows = rs.fetch_row();
        if(rows.length == 0)
        {
            return 0;
        }
        return int64.parse(rows[0]);
    }

    public override void shutdown()
    {
        //
        // No need manual shutdown connection
        //
     }
}
