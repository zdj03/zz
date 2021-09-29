//
//  StringMath.h
//  Sort
//
//  Created by 周登杰 on 2021/8/12.
//

#ifndef StringMath_h
#define StringMath_h

#include <stdio.h>
#include <stdbool.h>

// 字符串匹配：a主串，b模式串。BF算法
bool bf(char *a, char *b);
// RK算法
unsigned long rk(char *a, char *b);

#endif /* StringMath_h */
