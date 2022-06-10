#include "sql-parser.h"
#include "str-util.h"


extern void SQLParser_close(SQLParser **parser) {
    if (parser == NULL) {
        return;
    }
    SQLParser *ptr = *parser;
    //free ctx
    SQLParser_free((Pointer *) &(ptr->ctx));
    //free sql
    SQLParser_free((Pointer *) &(ptr->sql));
    //free parser
    SQLParser_free((Pointer *) parser);
}

extern SQLParser *SQLParser_new(String sql) {

    Context *ctx = SQLParser_malloc(sizeof(Context));

    ctx->row = 0;
    ctx->column = 0;

    String str = SQLParser_str_dump(sql);
    SQLParser *parser = SQLParser_malloc(sizeof(SQLParser));
    parser->sql = str;
    parser->ctx = ctx;


    return parser;
}