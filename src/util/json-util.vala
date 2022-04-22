public class JsonUtil:Object
{
    /**
     *
     * 将json对象转换位json字符串
     *
     */
    public static string jsonStr(Json.Builder builder)
    {
        var root = builder.get_root();
        var generator = new Json.Generator();
        generator.set_root(root);
        return generator.to_data(null);
    }
}
