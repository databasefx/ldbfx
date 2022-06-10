#ifndef SQL_PARSER_STMT_H
#define SQL_PARSER_STMT_H

#include "system.h"

/**
 *
 *
 * ExpressionStatement ——> id=value | id!=value | id<>value |  id>value | id<value | id>=value |id<=value | IS NULL | IS NOT NULL
 *
 */
extern ASTNode SQLParser_expression_statement(SQLParser *parser);

/**
 *
 *
 * Select statement
 *
 *
 */
extern ASTNode SQLParser_select(SQLParser *parser);

/**
 *
 * Insert statement
 *
 */
extern ASTNode SQLParser_insert(SQLParser *parser);

/**
 *
 * Update statement
 *
 */
extern ASTNode SQLParser_update(SQLParser *parser);

/**
 *
 * Delete statement
 *
 */
extern ASTNode SQLParser_delete(SQLParser *parser);

#endif //SQL_PARSER_STMT_H
