/**
 *
 * 表格行原始数据
 *
 **/
public class TableRowMeta : Object
{
    /**
     *
     *
     * 记录当前渲染单元格位位置
     *
     **/
    public int index{
        private set;
        private get;
    }

    public string[] value{
        private set;
        private get;
    }

    public TableRowMeta(string[] value)
    {
        this.value = value;
        this.index = 0;
    }

    public string getStrValue(){
        if(this.index >= this.value.length)
        {
            index = 0;
        }
        var str =  this.value[index++];
        return str == Constant.NULL_SYMBOL ? "null" : str;
    }
}