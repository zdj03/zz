//
//  Array.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/15.
//  Copyright © 2019 zdj. All rights reserved.
//

#include <stdio.h>
#include "Array.h"

void print(){
    int i = 0;
          
    long arr[3] = {0};
    for (; i <= 3; i++) {
        arr[i] = 0;
        printf("hello world\n");
    }
}

int searchTarget(int a[100][100], int rows, int cols, int target){
    int row = 0;
    
    while (row < rows && cols >= 0) {
        int val = a[row][cols-1];
        if (target == val) {
            return 1;
        } else if (target > val){
            row++;
        } else {
            cols--;
        }
    }
    return 0;
}
