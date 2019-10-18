//
//  Stack.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/15.
//  Copyright © 2019 zdj. All rights reserved.
//

#include "Stack.h"
#include <stdlib.h>

Stack init(int size){

    Stack stack = (Stack)malloc(sizeof(Stack));
 
    stack->items = (int *)malloc(sizeof(int));
    
    stack->size = size;
    stack->elemCount = 0;
        
    return stack;
}

void push(Stack stack, int e){
    if (stack->elemCount >= stack->size) {
        return;
    }
    
    stack->items[stack->elemCount++] = e;
    
}

int pop(Stack stack) {
    if (stack->elemCount == 0) {
        return -1;
    }
    
    int top = stack->items[--stack->elemCount];
    
    stack->items[stack->elemCount] = -1;
        
    return top;
}


void printStack(Stack stack){
    
    Stack copyStack = stack;
    
    int *elements = copyStack->items;
    for (int i = 0; i < copyStack->elemCount; ++i) {
        printf("item : %d\n",elements[i]);
    }
    
}
