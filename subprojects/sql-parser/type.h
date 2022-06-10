#ifndef SQL_PARSER_TYPE_H
#define SQL_PARSER_TYPE_H

#include <stddef.h>

#define TRUE (1)
#define FALSE (0)


typedef int bool;
typedef char *String;
typedef void *Pointer;

typedef long int64;
typedef unsigned long uint64;

typedef unsigned int uint;


//Set id max length 1kb = 1024byte
#define ID_MAX_LEN  (1024)

/**
 *
 * Define token kind
 *
 */
typedef enum {
#define TOKEN(kind, name) kind,

#include "token.txt"

#undef TOKEN
} TokenKind;

/**
 *
 *
 * Define parser context
 *
 */
typedef struct {
    //current character
    char c;
    //Current row
    int row;
    //Current column
    int column;
    //Current pos
    int pos;
} Context;

/**
 *
 *
 * Define Token
 *
 */
typedef struct {
    TokenKind kind;
    char value[ID_MAX_LEN];
} Token;

/**
 *
 * Define abstract syntax tree object
 *
 */
typedef struct ASTNode {
    String value;
    TokenKind kind;
    struct ASTNode *kinds[2];
} *ASTNode;

/**
 *
 * Define SQLParser object
 *
 */
typedef struct {
    char *sql;
    Context *ctx;
    ASTNode root;
} SQLParser;




#endif //SQL_PARSER_TYPE_H
