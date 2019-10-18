//
//  main.m
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/14.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkList.h"
#import "Stack.h"
#import "RecursionExample.h"
#import "Sort.h"

void bubble_Sort(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        bubble_Sort();
    }
    return 0;
}


void bubble_Sort(){
    int a[] = {9,7,3,1};
    
    //bubbleSort(a, 4);
    
   //insertSort(a, 4);
    
    selectionSort(a, 4);
    
    print_after_sort(a, 4);
}

void recursionAlgorithm(){
    printf("theSteps : %d",theSteps(50));
}

void stackOp(){
    Stack stack = init(10);
    push(stack, 1);
    push(stack, 2);
    push(stack, 3);
    printStack(stack);
    
    printf("the top : %d", pop(stack));
}


void listOp(){

    
            List list = initList();
            insertNode(list, 1, 1);
            insertNode(list, 1, 3);
            insertNode(list, 1, 5);
            insertNode(list, 1, 7);
            insertNode(list, 1, 9);
    
            List revList = reverseList(list);
            printList(revList);
    
    
            List list1 = initList();
            insertNode(list1, 1, 2);
            insertNode(list1, 1, 4);
            insertNode(list1, 1, 6);
            insertNode(list1, 1, 8);
            insertNode(list1, 1, 10);
            
            merge(list, list1);
    
            delBackwardNode(list, 3);
    
            midNode(list1);
    
    
    
            int a[] = {10,9,5,3,4,7};
            dual_list dualList = initDual_list(a, 6);
            printDualList(dualList);
}
