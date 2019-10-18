//
//  Stack.h
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/15.
//  Copyright © 2019 zdj. All rights reserved.
//

#ifndef Stack_h
#define Stack_h


#include <stdio.h>
#include <string.h>


struct Stack {
    int elemCount;//栈中元素个数
    int size;//栈的大小
    int *items;//数组
};

typedef struct  Stack *Stack;

Stack init(int size);
void push(Stack stack, int e);
int pop(Stack stack);

void printStack(Stack stack);

#endif /* Stack_h */
