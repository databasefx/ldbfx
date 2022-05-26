using Sqlite;

public class SqliteConnection : SqlConnection
{
    private Database database;
    
    private DataSource dataSource;

    public SqliteConnection(DataSource dataSource,SqlConnectionPool? pool)
    {
        base(dataSource,pool);
        this.database = null;
        this.dataSource = dataSource;
    }

    public SqliteConnection.without(DataSource dataSource)
    {
        this(dataSource,null);
    }
   /**
     *
     * 连接到指定数据库
     *
     */
    public override void connect() throws FXError
    {
        if(this.active)
        {
            return;
        }

        var code = Database.open_v2(this.dataSource.dbFilePath,out this.database,OPEN_READWRITE);
        
        if(code != OK)
        {
            warning("Open sqlite database fail:%s".printf(this.database.errmsg()));
    
            throw new FXError.ERROR(this.database.errmsg());
        }

        this.active = true;
    }


    /**
     *
     * 获取服务器信息
     *
     */
    public override DatabaseInfo serverInfo() throws FXError
    {
        var info =  new DatabaseInfo();
        
        info.name = "sqlite";
        info.version = "3.0";

        return info;
    }


    /**
     *
     * 获取数据库schema列表
     *
     *
     * */
    public override Gee.List<DatabaseSchema> schemas() throws FXError
    {
        var list =  new Gee.ArrayList<DatabaseSchema>();
        var schema = new DatabaseSchema();
        
        schema.name = "main";
        schema.charset = "utf8";
        schema.collation = "utf8bin";

        list.add(schema);

        return list;
    }


    /**
     *
     *
     * 获取某个Schema下的表列表
     *
     **/
    public override Gee.List<TableInfo> tables(string schema,bool view) throws FXError
    {


        var sql = "select name from sqlite_master where type =$table order by name";

        var stmt = this.execute(sql);

        //预编译
        var index =stmt.bind_parameter_index("$table");
        
        //绑定参数
        stmt.bind_text(index,view ? "view" : "table");

        var cols = stmt.column_count();
       
        var list = new Gee.ArrayList<TableInfo>();

        while(stmt.step() == Sqlite.ROW)
        {
            var table = new TableInfo();

            for (int i = 0; i < cols; i++) 
            {
			    var col_name = stmt.column_name (i) ?? "<none>";
			    var val = stmt.column_text (i) ?? "<none>";
			    var type_id = stmt.column_type (i);

                if(col_name == "name")
                {
                    table.name = val;
                }

		    }
            list.add(table);
        }
        return list;
    }

    /**
     *
     * 获取某张表列信息
     *
     **/
    public override Gee.List<TableColumnMeta> tableColumns(string schema,string name) throws FXError
    {
        
        var sql = @"PRAGMA table_info($name)";

        var stmt = this.execute(sql);
        var cols = stmt.column_count();
        
        var list = new Gee.ArrayList<TableColumnMeta>();

        while(stmt.step() == Sqlite.ROW)
        {
            var columnMeta = new TableColumnMeta();

            for (int i = 0; i < cols; i++)
            {
                var column = stmt.column_name(i);
                if(column == "name")
                {
                    columnMeta.name = stmt.column_text(i)??Constant.NULL_SYMBOL;
                }
                if(column == "notnull")
                {
                    columnMeta.isNull = (stmt.column_int(i) == 1);
                }
                if(column == "type")
                {
                    columnMeta.originType = stmt.column_text(i);
                }
            }

            list.add(columnMeta);
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
        var size = query.size;
        var offset = (query.page - 1) * size;

        var sql = "SELECT * FROM %s %s %s LIMIT $size offset $offset".printf(query.table,query.where,query.sort);

        var stmt = this.execute(sql);

        var j = stmt.bind_parameter_index("$size");
        var k = stmt.bind_parameter_index("$offset");
        
        stmt.bind_int(j,size);
        stmt.bind_int(k,offset);

        var cols = stmt.column_count();
        var list  = new Gee.ArrayList<string>();

        while(stmt.step() == ROW)
        {
            for(var l = 0;l < cols ; l++)
            {
                list.add(stmt.column_text(l));
            }
        }

        return list;
    }

    /**
     *
     * 统计某张表数据条数
     *
     */
    public override int64 pageCount(PageQuery query) throws FXError
    {        
        
        var sql = "SELECT COUNT(*) FROM %s %s".printf(query.table,query.where);

        var stmt = this.execute(sql);
 
        int64 count = 0;
        if(stmt.step() == ROW)
        {
            count = stmt.column_int(0);
        }

        return count;
    }

    /**
     *
     * 关闭当前连接(放回连接池中)
     *
     */
    public void close(){
        if( this.pool == null )
        {
            return;
        }
        this.pool.back(this);
    }

    public override string ddl(string schema,string table,bool view) throws FXError
    {
        var sql = "SELECT sql FROM sqlite_master WHERE type=$type AND tbl_name=$name";

        var stmt = this.execute(sql);

        var i = stmt.bind_parameter_index("$type");
        var j = stmt.bind_parameter_index("$name");

        stmt.bind_text(j,table);
        stmt.bind_text(i,view?"view":"table");

        var ddl = "";

        var cols = stmt.column_count();

        if(stmt.step() == ROW)
        {
            for(var k = 0 ; k < cols ; k++)
            {
                ddl = stmt.column_text(k);
            }
        }

        return ddl;
    }

    private Statement execute(string sql) throws FXError
    {
        this.connect();
        
        Statement stmt;

        var code = this.database.prepare_v2(sql,sql.length,out stmt);
        
        debug("Sqlite:%s".printf(sql));

        if(code == OK)
        {
            return stmt;
        }

        var errmsg = this.database.errmsg();

        warning("Sqlite:Execute sql fail:[%s],errmsg:[%s]".printf(sql,errmsg));

        throw new FXError.ERROR(errmsg);
    }

    /**
     *
     * 关闭当前连接
     *
     */
    public override void shutdown()
    {

    }   
}