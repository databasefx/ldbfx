#include <stdio.h>
#include "sql-parser.h"
#include "lex.h"


/**
 *
 *
 * Sql statement parser unit test
 *
 * @author GZYangKui
 */
int main(int argc, char *argv[]) {
    String s = "SELECT * FROM s WHERE id='s'";
    SQLParser *parser = SQLParser_new(s);
    while (1) {
        Token token = SQLParser_token(parser);
        if (token.kind == _EOF) {
            break;
        }
        printf("%s\n",token.value);
    }
    return 0;
}