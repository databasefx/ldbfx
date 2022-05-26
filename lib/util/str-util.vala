public class StrUtil
{
    /**
     *
     * 判断是否空白字符串
     *
     **/
    public static bool isBlack(string? str)
    {
        return str == null || str.strip() == "";
    }


    /**
     *
     *
     * 判断字符串是否不为空
     *
     */
    public static bool isNotBlack(string? str)
    {
        return !isBlack(str);
    }
}