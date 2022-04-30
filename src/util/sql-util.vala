

public delegate void SQLExecutorFinally(FXError error);

public delegate void SQLExecutorContext(SqlConnection connection);

public class SQLUtil
{
    public static async void asyncTask(string uuid,SQLExecutorContext ctx,SQLExecutorFinally? finally){
        var work = AsyncWork.create(()=>{
            FXError error = null;
            SqlConnection con = null;
            try
            {
                con = Application.ctx.getConnection(uuid);
                ctx(con);
            }
            catch(FXError e)
            {
                error = e;
            }
            finally
            {
                if(con != null)
                {
                    con.close();
                }
                if(finally != null)
                {
                    finally(error);
                }
            }
        });

       yield work.execute();
    }
}
