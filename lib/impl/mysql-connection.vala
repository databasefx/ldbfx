using Mysql;

public class MysqlConnection : SqlConnection
{
    private Database database;

    private DataSource dataSource;

    public MysqlConnection(DataSource dataSource,SqlConnectionPool? pool)
    {
        base(dataSource,pool);
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
        this.execute("SHOW VARIABLES");

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
        var sql = "SELECT * FROM information_schema.SCHEMATA";

        this.execute(sql);

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
        string sql;

        if(view)
        {
            sql = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_SCHEMA = '%s' ORDER BY `TABLE_NAME` ASC";
        }
        else
        {
            sql = "SELECT `TABLE_NAME` FROM information_schema.TABLES WHERE `TABLE_SCHEMA`='%s' ORDER BY `TABLE_NAME` ASC";
        }
        
        sql = sql.printf(schema);

        this.execute(sql);

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
                        `TABLE_NAME`='%s' 
                    ORDER BY
                        `ORDINAL_POSITION` 
                    ASC""";
        sql = sql.printf(schema,name);

        this.execute(sql);

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
    public override Gee.List<string> pageQuery(PageQuery query) throws FXError
    {
        this.connect();

        var size =query.size;
        var page = query.page;
        var sort = query.sort;
        var where = query.where;
        var table = query.table;
        var schema = query.schema;

        var offset = (page - 1) * size;

        var sql = @"SELECT * FROM $schema.$table $where $sort LIMIT $offset,$size";

        this.execute(sql);
        
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
        
        GLib.debug(query.where);

        return list;
    }

    /**
     *
     * 统计某张表数据条数
     *
     */
    public override int64 pageCount(PageQuery query) throws FXError
    {        
        var table = query.table;
        var schema = query.schema;
                
        var sql = "SELECT COUNT(*) FROM %s.%s %s".printf(query.schema,query.table, query.where);
        
        this.execute(sql);

        var rs = this.database.use_result();
        var rows = rs.fetch_row();
        if(rows.length == 0)
        {
            return 0;
        }
        return int64.parse(rows[0]);
    }


    public override string ddl(string schema,string table,bool view) throws FXError
    {
        var sql = @"SHOW CREATE TABLE `$schema`.`$table`";

        this.execute(sql);

        var rs = this.database.use_result();

        var row = rs.fetch_row();

        return row[1];
    }


    public override void shutdown()
    {
        //
        // No need manual shutdown connection
        //
     }

     private void execute(string sql) throws FXError
     {
        this.connect();

        GLib.debug("Mysql:Execute sql:[%s]".printf(sql));

        if(this.database.query(sql) == 0)
        {
            return;
        }
        
        var errmsg = this.database.error();

        warning("Mysql:Sql execute error:SQL:[%s],ERR:[%s]".printf(sql,errmsg));

        throw new FXError.ERROR(errmsg);
     }
}
