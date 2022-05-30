using GtkSource;

public class SQLSourceView : View
{
    construct
    {   
        var buffer = this.buffer as Buffer;

        var lmanager = LanguageManager.get_default();
        var smanager = StyleSchemeManager.get_default();

        var language = lmanager.get_language("sql");
        var styleScheme = smanager.get_scheme("monokai-extended");



        if(language == null)
        {
            warning("SQL language not exist?");
        }
        else 
        {
            buffer.language = language;
        }

        if(styleScheme == null)
        {
            warning("monokai-extended style scheme not exist?");
        }
        else
        {
            buffer.style_scheme = styleScheme;
        }

        this.hexpand = true;
        this.vexpand = true;
        this.top_margin = 12;
        this.monospace = true;
        this.left_margin = 12;
        this.right_margin = 12;
        this.auto_indent = true;
        this.bottom_margin = 12;
        this.show_line_numbers = true;
        this.highlight_current_line = true;
    }
}