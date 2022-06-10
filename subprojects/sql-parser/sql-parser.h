//
// Created by yangkui on 22-6-9.
//

#ifndef SQL_PARSER_SQL_PARSER_H
#define SQL_PARSER_SQL_PARSER_H

typedef enum {
#define TOKEN(kind, name) kind,

#include "token.txt"

#undef TOKEN
} TokenKind;

typedef struct {
    //Current character
    char c;
    //Current row
    int row;
    //Current column
    int column;
} Context;

typedef struct {
    TokenKind kind;
    char *value;
} Token;


typedef struct {
    char *sql;
    Context *ctx;
} SQLParser;

/**
 *
 * Instance SQLParser by memory sql statement
 *
 */
extern SQLParser *SQLParser_new(char *sql);


/**
 *
 * Free SQLParser object
 *
 */
extern void SQLParser_close(SQLParser **parser);

/**
 *
 * Instance SQLParser by fix file path
 *
 */
extern SQLParser *SQLParser_new_whit_file(char *file);

#endif //SQL_PARSER_SQL_PARSER_H
