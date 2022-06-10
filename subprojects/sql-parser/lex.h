#ifndef SQL_PARSER_LEX_H
#define SQL_PARSER_LEX_H

#include "sql-parser.h"

#define    EOF_CH        ((char)0xFF)

/**
 *
 *
 * From give string construct lexical unit
 *
 */
extern Token SQLParser_token(SQLParser *parser);


#endif //SQL_PARSER_LEX_H
