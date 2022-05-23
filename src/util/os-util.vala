using Gdk;

public class OSUtil : Object
{
    /*
     *
     * Put plain text input system clipboard
     *
     */
    public static void setCPBText(string text)
    {
        var display = Display.get_default();
        
        if(display == null)
        {
            return;
        }

        var clipboard = display.get_clipboard();

        clipboard.set_text(text);
    }
}
