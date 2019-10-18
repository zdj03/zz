//
//  RecursionExample.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/16.
//  Copyright © 2019 zdj. All rights reserved.
//

#include "RecursionExample.h"


int theSteps(int n){
    
    // n==1时，只有一种走法：直接跨过1个台阶
    if (n == 1) {
        return 1;
    }
    
    // n == 2时，可以直接跨1个或者2个
    if (n == 2) {
        return 2;
    }
    
    return theSteps(n - 1) + theSteps(n - 2);
}
