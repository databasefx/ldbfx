//
// Created by yangkui on 22-6-9.
//

#include "lex.h"

/**
 *
 * Judge whether the given character is blank
 *
 */
static int SQLParser_white_space(char c) {
    return c == ' ' || c == '\r' || c == '\n' || c == '\t';
}

extern Token *SQLParser_token(Context *context) {

}
