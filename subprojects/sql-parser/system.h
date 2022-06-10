#ifndef SQL_PARSER_SYSTEM_H
#define SQL_PARSER_SYSTEM_H

#include "type.h"

/**
 *
 * Malloc size byte memory
 *
 */
extern Pointer SQLParser_malloc(uint64 size);


/**
 *
 * Free signal pointer object
 *
 */
extern void SQLParser_free(Pointer *pointer);

/**
 *
 * Malloc size byte string and reset
 *
 */
extern String SQLParser_string_new(uint64 size);


/**
 *
 *
 * New AstNode object
 *
 */
extern ASTNode SQLParser_ast_new(TokenKind kind,String value);

#endif //SQL_PARSER_SYSTEM_H
