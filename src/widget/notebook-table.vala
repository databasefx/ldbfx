using Gtk;
using Gee;

/*
 *
 *
 * NoteBook Table
 * 
 *
 **/
 [GtkTemplate (ui="/cn/navclub/ldbfx/ui/notebook-table.xml")]
public class NotebookTable : Box, TabService
{
    private bool view;
    private string uuid;
    private int64 total;
    private string pathStr;
    private PageQuery pageQuery;
    private NotebookTab notebookTab;
    private MultiSelection selection;
    private GLib.ListStore listStore;
    private SignalListItemFactory factory;

    private Gee.List<string> list = null;
    //缓存当前列属性
    private Gee.List<ColumnViewColumn> columns;
    

    [GtkChild]
    private unowned Entry sEntry;
    [GtkChild]
    private unowned Entry wEntry;
    [GtkChild]
    private unowned Label rowNLum;
    [GtkChild]
    private unowned ColumnView tableView;


    public NotebookTable(string path,bool view)
    {
        this.total = 0;
        this.view = view;
        this.pathStr = path;

        this.uuid = this.getPosVal(path,0);

        this.list = new ArrayList<string>();
        this.factory = new SignalListItemFactory();
        this.columns = new ArrayList<ColumnViewColumn>();

        this.listStore = new GLib.ListStore(typeof(TableRowMeta));
        this.selection = new MultiSelection(this.listStore);
        
        this.pageQuery = new PageQuery(this.getPosVal(this.pathStr,-3),this.getPosVal(this.pathStr,-1));
        
        this.notebookTab = new NotebookTab( view ? "dbfx-view" : "dbfx-table" , getPosVal(pathStr,-1) , this, true );

        var count = 0;
        this.factory.bind.connect(listItem=>{
            var item = listItem.item as TableRowMeta;
            var label = listItem.child as Label;

            var text = item.getStrValue();

            if(item.isNull)
            {
                label.add_css_class("table-cell-high-light");
            }
            else
            {
                label.remove_css_class("table-cell-high-light");
            }

            //Set index cell center show
            if((item.index - 1 == 0) && label.xalign != 0.5f)
            {
                label.xalign = 0.5f;
            }

            label.label = text;
        });

        this.factory.setup.connect((listItem)=>{
            var label = new Label("");

            label.xalign = 0f;
            //Set single show model
            label.single_line_mode = true;
            //Add custom class name
            label.add_css_class("table-cell");
            
            listItem.child = label;
        });

        this.factory.teardown.connect((listItem)=>{
            listItem.child = null;
        });

        this.tableView.model = this.selection;

        this.loadTableData(1);
    }

    [GtkCallback]
    private void nextPage()
    {
        this.loadTableData(1);
    }

    [GtkCallback]
    private void prePage()
    {
        this.loadTableData(-1);
    }

    [GtkCallback]
    private void refresh()
    {
        this.loadTableData(0,true);
    }

    [GtkCallback]
    private async void showDDL()
    {
        if(Application.ctx.tabExist(TabScheme.DDL,this.pathStr) != -1)
        {
            return;
        }

        Application.ctx.addTab(new DDNotebook(this.pathStr,this.view));
    }

    private async void loadTableData(int offset,bool flush=false)
    {
        var tab = this.tab();
        
        if(tab.loading)
        {
            return;
        }
        
        var page = this.pageQuery.page;

        var temp = (page + offset);

        temp = (temp <= 0 ? 1 : temp);

        if(!flush && temp == page)
        {
            return;
        }

        tab.loadStatus(true);

        this.listStore.remove_all();

        FXError error = null;
        Gee.List<TableColumnMeta> columns = null;
        SourceFunc callback = loadTableData.callback;

        int64 total = 0;
        
        this.pageQuery.inspect(temp,this.wEntry.text, this.sEntry.text);
        
        var work = AsyncWork.create(()=>{
            var connect = Application.getConnection(uuid);
            try
            {
                list = connect.pageQuery(this.pageQuery);
                total = connect.pageCount(this.pageQuery);
                columns = connect.tableColumns(this.pageQuery.schema,this.pageQuery.table);
            }
            catch(FXError e)
            {
                error = e;
            }
            finally
            {
                connect.close();
                Idle.add(callback);
            }
        });
        work.execute();
        
        yield;
        
        this.rowNLum.label = "%s %s".printf(total.to_string(),_("_Rows"));

        if(error == null)
        {
            var colNum = columns.size;

            this.diffCol(columns);
            var dSize  = this.list.size;
            var rowNum    = dSize / colNum;
            for (int j = 0; j < rowNum; j++)
            {
                //重置偏移量
                offset = j * colNum;
                
                var array  = new string[colNum+1];

                //添加序号列
                array[0] = (j + 1).to_string();
                
                for (int i = offset; i < offset + colNum; i++)
                {
                    array[i - offset + 1] = this.list.get(i);
                }

                this.listStore.append(new TableRowMeta(array));
                
                //一次性加载80条数据
                if(dSize > 80 && j % 80 == 0)
                {
                    Idle.add(callback);
                    yield;
                }
            }
        }
        else
        {
            FXAlert.error(_("_Loading fail"),error.message);
        }

        this.total = total;

        tab.loadStatus(false);

        this.list.clear();
    }

    /**
     *
     *
     * 差分检查列
     *
     **/
    private void diffCol(Gee.List<TableColumnMeta> list)
    {
        //创建索引列
        if(this.columns.size == 0)
        {
            this.createColumn("",false,40);
        }

        var index = 0;
        var newSize = list.size;
        var size = this.columns.size;

        foreach(var column in list)
        {
            var name = column.name;
            
            if(index < size-1)
            {
                var ccolumn = this.columns.get(index+1);
                if(ccolumn.title != name)
                {
                    ccolumn.title = name;
                }
            }
            else
            {
                this.createColumn(name,true,150);
            }
            index++;
        }

        //移除多余列
        for(var i = (size - 1) ; i >= newSize + 1 ; i--)
        {
            var column = this.columns.remove_at(i);
            this.tableView.remove_column(column);
        }
    }

    /**
     *
     * 创建列
     *
     */
    private void createColumn(string title,bool resizable,int fixWidth)
    {
        var ccolumn = new ColumnViewColumn
        (
            title,
            factory
        );

        ccolumn.resizable = resizable;
        ccolumn.fixed_width = fixWidth;

        this.columns.add(ccolumn);
        this.tableView.append_column(ccolumn);
    }

    public  NotebookTab tab()
    {
        return this.notebookTab;
    }

    public string path()
    {
        return TabScheme.toFullPath(TabScheme.TABLE,this.pathStr);
    }

    public unowned Gtk.Widget content()
    {
        return this;
    }

    public TabScheme scheme()
    {
        return TabScheme.TABLE;
    }
}
