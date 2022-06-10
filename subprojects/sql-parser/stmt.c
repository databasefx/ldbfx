#include <stdio.h>
#include "stmt.h"
#include "lex.h"
#include "str-util.h"

extern ASTNode SQLParser_expression_statement(SQLParser *parser) {
    Token token = SQLParser_token(parser);
    ASTNode stmt = NULL;
    if (token.kind == ID) {
        Token t = SQLParser_token(parser);
        if (t.kind == ASSIGN
            || token.kind == UNEQUAL
            || token.kind == GREATER_THAN
            || token.kind == LESS_THAN
            || token.kind == LESS_THAN_EQUAL
            || token.kind == GRANTER_THAN_EQUAL) {
            stmt = SQLParser_ast_new(t.kind, NULL);
            Token t1 = SQLParser_token(parser);
            stmt->kinds[0] = SQLParser_ast_new(ID, SQLParser_str_dump(token.value));
            stmt->kinds[1] = SQLParser_ast_new(VALUE, SQLParser_str_dump(t1.value));
        } else if (t.kind == IS) {
            Token t1 = SQLParser_token(parser);
            if (t1.kind == _NULL || t1.kind == NOT_NULL) {
                stmt = SQLParser_ast_new(t1.kind, NULL);
                stmt->kinds[0] = SQLParser_ast_new(ID, SQLParser_str_dump(token.value));
            } else {
                printf("ExpStmt: 'null' or 'not null' was expected!");
            }
        } else {
            printf("ExpStmt:Assign or Compare or logic symbol was required!\n");
        }
    } else {
        printf("ExpStmt: 'id' was expected!\n");
    }
}

extern ASTNode SQLParser_select(SQLParser *parser) {

}

extern ASTNode SQLParser_insert(SQLParser *parser) {

}


extern ASTNode SQLParser_update(SQLParser *parser) {

}

extern ASTNode SQLParser_delete(SQLParser *parser) {

}