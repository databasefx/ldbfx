#ifndef SQL_PARSER_SQL_PARSER_H
#define SQL_PARSER_SQL_PARSER_H

#include "system.h"

/**
 *
 * Instance SQLParser by memory sql statement
 *
 */
extern SQLParser *SQLParser_new(String sql);


/**
 *
 * Free SQLParser object
 *
 */
extern void SQLParser_close(SQLParser **parser);

/**
 *
 * Instance SQLParser by fix file path
 *
 */
extern SQLParser *SQLParser_new_with_file(String path);

#endif //SQL_PARSER_SQL_PARSER_H
