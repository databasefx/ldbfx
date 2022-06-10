#ifndef SQL_PARSER_STR_UTIL_H
#define SQL_PARSER_STR_UTIL_H

#include "type.h"
#include "system.h"
/**
 *
 * Copy string
 *
 */
extern String SQLParser_str_dump(String str);


/**
 *
 * String lower
 *
 */
extern String SQLParser_str_lower(String str);

/**
 *
 * String upper
 *
 */
extern String SQLParser_str_upper(String str);

/**
 *
 * Compare a and b string is equal
 *
 */
extern bool SQLParser_str_equal(String a,String b,int ignoreCase);

#endif //SQL_PARSER_STR_UTIL_H
