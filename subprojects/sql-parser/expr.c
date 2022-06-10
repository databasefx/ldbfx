#include <stdio.h>
#include "expr.h"
#include "lex.h"
#include "str-util.h"

extern ASTNode SQLParser_expression(SQLParser *parser) {
//    Token token = SQLParser_token(parser);
//    ASTNode astNode = SQLParser_ast_new();
//
//    if (token.kind == ID) {
//        astNode->kind = ID;
//        astNode->value = token.value;
//    } else if (token.kind == ASSIGN) {
//        astNode->kind = ASSIGN;
//        token = SQLParser_token(parser);
//        if (token.kind == ID) {
//            astNode->value = SQLParser_str_dump(token.value);
//        }
//    } else {
//        printf("Expression: unknown Token %d\n", token.kind);
//    }
//    return astNode;
}

