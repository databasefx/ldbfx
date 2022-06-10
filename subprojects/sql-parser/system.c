#include <malloc.h>
#include <string.h>
#include "system.h"
#include "str-util.h"

extern Pointer SQLParser_malloc(uint64 size) {
    return malloc(size);
}


extern void SQLParser_free(Pointer *pointer) {
    if (pointer == NULL || *pointer == NULL) {
        return;
    }
    free(*pointer);
    *pointer = NULL;
}

extern String SQLParser_string_new(uint64 size) {
    String ptr = (String) malloc(size);
    memset(ptr, '\0', size);
    return ptr;
}

extern ASTNode SQLParser_ast_new(TokenKind kind, String value) {
    ASTNode astNode = SQLParser_malloc(sizeof(struct ASTNode));
    astNode->kind = kind;
    if (value != NULL && strlen(value) != 0) {
        astNode->value = SQLParser_str_dump(value);
    }
    return astNode;
}