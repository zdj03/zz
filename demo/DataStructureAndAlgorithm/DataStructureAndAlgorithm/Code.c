//
//  Code.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2021/5/30.
//  Copyright © 2021 zdj. All rights reserved.
//

#include "Code.h"
#include <stdlib.h>

// 求回文数字
void plalindrome(){
    int m[16], n, i, t, count = 0;
    long unsigned a, k;
    printf("NO,  number    it's square(papindrome)\n");
    for (n = 1; n < 25 * 25; n++) {
        k = 0; t = 1; a = n*n;
        for (i = 0; a != 0; i++) {
            m[i] = a % 10;
            a /= 10;
        }
        
        for (; i > 0; i--) {
            k += m[i-1] * t;
            t *= 10;
        }
        
        if (k == n*n) {
            printf("%2d%10d%10d\n", ++count, n, n*n);
        }
    }
}

