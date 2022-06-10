#include <string.h>
#include "str-util.h"

typedef enum {
    LOWER,
    UPPER,
    NAA
} TLetter;

static TLetter SQLParser_is_letter(char c) {
    if (c >= 65 && c < 91) {
        return UPPER;
    }
    if (c >= 97 && c < 123) {
        return LOWER;
    }
    return NAA;
}

extern String SQLParser_str_dump(String str) {
    uint64 len = strlen(str);
    String temp = SQLParser_string_new(len + 1);
    strcpy(temp, str);
    return temp;
}


extern String SQLParser_str_lower(String str) {
    String temp = SQLParser_str_dump(str);
    uint64 len = strlen(temp);
    for (int i = 0; i < len; ++i) {
        char c = *(temp + i);
        if (SQLParser_is_letter(c) == UPPER) {
            *(temp + i) = (char) (c + 32);
        }
    }
    return temp;
}

extern String SQLParser_str_upper(String str) {
    String temp = SQLParser_str_dump(str);
    uint64 len = strlen(temp);
    for (int i = 0; i < len; ++i) {
        char c = *(temp + i);
        if (SQLParser_is_letter(c) == LOWER) {
            *(temp + i) = (char) (c - 32);
        }
    }
    return temp;
}


extern bool SQLParser_str_equal(String a, String b, int ignoreCase) {
    uint la = strlen(a);
    uint lb = strlen(b);
    bool equal = (la == lb);
    for (int i = 0; (i < la && equal); i++) {
        char ac = *(a + i);
        char bc = *(b + i);
        if ((equal = (ac == bc))) {
            continue;
        }
        if (ignoreCase) {
            TLetter t = SQLParser_is_letter(ac);
            TLetter t1 = SQLParser_is_letter(bc);
            equal = t != t1 && (t != NA && t1 != NA);
            if (equal) {
                if (t != LOWER) {
                    ac += 32;
                }
                if (t1 != LOWER) {
                    bc += 32;
                }
                equal = (ac == bc);
            }
        }
    }
    return equal;
}