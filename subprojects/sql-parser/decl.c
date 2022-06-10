#include <stdio.h>
#include "lex.h"
#include "decl.h"


extern ASTNode SQLParser_direct_declare(SQLParser *parser) {
    Token token = SQLParser_token(parser);
    ASTNode astNode = NULL;
    if (token.kind == ID) {
        astNode = SQLParser_ast_new(token.kind, token.value);
    } else {
        printf("DirectDeclare: 'id' was expected!\n");
    }
    return astNode;
}