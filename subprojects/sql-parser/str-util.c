//
// Created by yangkui on 22-6-9.
//

#include "system.h"
#include "str-util.h"


extern  String SQLParser_str_dump(char *sql) {
    uint64 len = strlen(sql);
    String str = SQLParser_string_new(len);
    strcpy(str, sql);
    return str;
}