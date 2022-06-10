#include <stdio.h>
#include "expr.h"
#include "lex.h"

extern ASTNode SQLParser_expression(SQLParser *parser) {
    Token token = SQLParser_token(parser);
    ASTNode astNode = NULL;
    if (token.kind == ID) {
        astNode = SQLParser_ast_new(ID,token.value);
    }else {
        printf("Expression: 'id' was expected!");
    }
    return astNode;
}

