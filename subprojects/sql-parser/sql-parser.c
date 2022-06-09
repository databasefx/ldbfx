//
// Created by yangkui on 22-6-9.
//
#include "sql-parser.h"
#include "str-util.h"

extern SQLParser *SQLParser_new(char *sql) {

    Context *ctx= SQLParser_malloc(sizeof(Context));

    ctx->row = 0;
    ctx->column=0;

    String str = SQLParser_str_dump(sql);
    SQLParser *parser = SQLParser_malloc(sizeof(SQLParser));
    parser->sql = str;
    parser->ctx = ctx;


    return parser;
}