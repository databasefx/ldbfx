//
// Created by yangkui on 22-6-9.
//
#include <malloc.h>
#include <string.h>
#include "system.h"

extern Pointer SQLParser_malloc(uint64 size){
    return malloc(size);
}

extern String SQLParser_string_new(uint64 size) {
    String ptr = (String) malloc(size);
    memset(ptr, '\0', size);
    return ptr;
}