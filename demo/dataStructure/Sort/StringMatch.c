//
//  StringMatch.c
//  Sort
//
//  Created by 周登杰 on 2021/8/12.
//

#include "StringMatch.h"
#include <string.h>
#include <stdlib.h>

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

//
//int hash(char *t){
//    unsigned long len = strlen(t);
//
//
//    int hashValue = 0;
//    for (int i = 0; i < len; ++i) {
//        char ch = t[i];
//        hashValue = ch * decimal;
//    }
//
//    return 0;
//}

// 避免hash值过大，对hash值取余
#define  HASHSIZE 10000019
//避免符号为扩展
#define UNSINGED(x) ((unsigned int)x & 0x000000FF)

#define decimal 256

unsigned long rk(char *a, char *b){
    
    unsigned long n = strlen(a);
    unsigned long m = strlen(b);
    
    if (m > n || n == 0 || m == 0) {
        return -1;
    }
    
    //base存储子串最高位的值
    unsigned long sa = UNSINGED(a[0]), sb = UNSINGED(b[0]), base = 1;
    unsigned long i = 0, j = 0;
    for (i = 1; i < m; ++i) {
        sa = (sa  * 10 + UNSINGED(a[i])) % HASHSIZE;
        sb = (sb * 10 + UNSINGED(b[i])) % HASHSIZE;
        base = (base * 10) % HASHSIZE;
    }
    
    // 指向下一位，即下一次子字符串移动到的位置
    i = m;
    
    do {
        // 如果hash值相等，hash冲突，逐个比较字符
        if (sa == sb) {
            // i - m：a子串的起始位置
            for(j = 0; j < m && a[i - m + j] == b[j]; ++j){
                ;
            }
            if (j == m) {
                return i - m + 1;
            }
        }
       
        // 减去子串最高位值
        sa = (sa - UNSINGED(a[i-m]) * base) % HASHSIZE;
        // 子串右移一位，加上下一位的值
        sa = (sa * 10 + UNSINGED(a[i])) % HASHSIZE;
        i++;
        
    } while (i < n);
    
    
    return -1;
}
