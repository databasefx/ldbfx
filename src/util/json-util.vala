public class JsonUtil:Object
{
    /**
     *
     * 将json对象转换位json字符串
     *
     */
    public static string jsonStr(Json.Node node)
    {
        var generator = new Json.Generator();
        generator.set_root(node);
        return generator.to_data(null);
    }
}
