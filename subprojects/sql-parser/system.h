//
// Created by yangkui on 22-6-9.
//

#ifndef SQL_PARSER_SYSTEM_H
#define SQL_PARSER_SYSTEM_H


typedef char* String;
typedef void* Pointer;

typedef long int64;
typedef unsigned long uint64;

typedef unsigned int uint;

/**
 *
 * Malloc size byte memory
 *
 */
extern Pointer SQLParser_malloc(uint64 size);

/**
 *
 * Malloc size byte string and reset
 *
 */
extern String SQLParser_string_new(uint64 size);

#endif //SQL_PARSER_SYSTEM_H
