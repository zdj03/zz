//
//  StringMath.c
//  Sort
//
//  Created by 周登杰 on 2021/8/12.
//

#include "StringMath.h"
#include <string.h>

bool bf(char *a, char *b){
    unsigned long aLen = strlen(a);
    unsigned long bLen = strlen(b);
    
    for (int i = 0; i < aLen - bLen + 1; ++i) {
        bool math = false;
        for (int j = 0; j < bLen; ++j) {
            math = (a[i+ j] == b[j]);
        }
        if (math == true) {
            return true;
        }
    }
    return false;
}

int hash(char *t){
    return 0;
}

bool rk(char *a, char *b){
    
    return false;
}
