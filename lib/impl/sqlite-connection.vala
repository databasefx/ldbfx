using Sqlite;

public class SqliteConnection : SqlConnection
{
    private Database database;
    
    private DataSource dataSource;

    public SqliteConnection(DataSource dataSource,SqlConnectionPool? pool)
    {
        base(pool);
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
        this.connect();

        Statement smt;

        var sql = "select name from sqlite_master where type =$table order by name";
        var code = this.database.prepare_v2(sql,sql.length,out smt); 
        
        if(code != OK)
        {
            throw new FXError.ERROR(this.database.errmsg());
        }

        //预编译
        var index =smt.bind_parameter_index("$table");
        //绑定参数
        smt.bind_text(index,"table");

        var cols = smt.column_count();
       
        var list = new Gee.ArrayList<TableInfo>();

        while(smt.step() == Sqlite.ROW)
        {
            var table = new TableInfo();

            for (int i = 0; i < cols; i++) 
            {
			    var col_name = smt.column_name (i) ?? "<none>";
			    var val = smt.column_text (i) ?? "<none>";
			    var type_id = smt.column_type (i);

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
        return new Gee.ArrayList<TableColumnMeta>();
    }

    /**
     *
     * 分页查询数据
     *
     **/
    public override Gee.List<string> pageQuery(string schema,string table,int page,int size) throws FXError
    {
        return new Gee.ArrayList<string>();
    }

    /**
     *
     * 统计某张表数据条数
     *
     */
    public override int64 count(string schema,string table) throws FXError
    {
        return 0;
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

    /**
     *
     * 关闭当前连接
     *
     */
    public override void shutdown()
    {

    }   
}