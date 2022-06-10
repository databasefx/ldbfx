#ifndef SQL_PARSER_EXPR_H
#define SQL_PARSER_EXPR_H
#include "system.h"

/**
 *
 *
 * Expression ——> id | id=Expression
 *
 */
extern ASTNode SQLParser_expression(SQLParser *parser);

#endif //SQL_PARSER_EXPR_H
