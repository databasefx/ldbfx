#include "sql-parser.h"
/**
 *
 *
 * Sql statement parser unit test
 *
 * @author GZYangKui
 */
int main(int argc, char *argv[])
{
    SQLParser *parser = SQLParser_new("SELECT * FROM test");
    SQLParser_close(&parser);
    return 0;
}