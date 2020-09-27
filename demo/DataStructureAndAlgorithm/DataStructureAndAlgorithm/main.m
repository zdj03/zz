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
#import "Algorithm.h"
#import "Array.h"

void bubble_Sort(void);
void listOp(void);
void findValOfArray(void);
void _printLinkList(void);
void bTree(void);
void _reConstuctBTree(void);
void _minOfRotateInArray(void);
void _Fibonacci(void);
void _JumpFloor(void);
void _JumpFloor2(void);
void _numberOf1(void);
void _reOrderArray(void);

int main(int argc, const char * argv[]) {
    @autoreleasepool {
 
        _reOrderArray();
    }
    return 0;
}

void _reOrderArray(void){
    int a[] = {1,2,3,4,5,6,7,8,9};
    reOrderArray(a, 9);
    for (int i = 0; i < 9; i++) {
        printf("reOrderArray:%d\n",a[i]);
    }
}

void _numberOf1(void)
{
    int n = 0b11111111111111111111111111111111;
    
    printf("_numberOf1:%d\n",numberOf11(n));
}

void _JumpFloor2(void){
    printf("the val of _JumpFloors:%d\n", abnormalJumpFloor(20));
}

void _JumpFloor(void){
    printf("the val of _JumpFloor:%d\n", JumpFloor(20));
}



void _Fibonacci(void){
    printf("the val of Fibonacci:%d\n", Fibonacci(10));
}

void _minOfRotateInArray(void){
    int a[] = {6,7,8,1,2,3};
    printf("min: %d\n",minNumInRotaterArray(a, 6));
}


void _reConstuctBTree(){
    int pre[] = {1,2,4,5,3,6,7}, ino[] = {4,2,5,1,6,3,7};
    BTree bTree = reConstructBTree(pre, ino, sizeof(pre)/sizeof(int));
    printBTreeFirstTraversal(bTree);
    printf("---------------------\n");
    printBTreeInOrderTraversal(bTree);
}

void bTree(){
    BTree root = initBTree(1);
    
    TreeNode *l0 = initBTree(2);
    TreeNode *r0 = initBTree(3);
    setLNode(root, l0);
    setRNode(root, r0);
    
    
    TreeNode *l1 = initBTree(4);
    TreeNode *r1 = initBTree(5);
    setLNode(l0, l1);
    setRNode(l0, r1);
    
    TreeNode *l2 = initBTree(6);
    TreeNode *r2 = initBTree(7);
    setLNode(r0, l2);
    setRNode(r0, r2);
    
    printBTreeFirstTraversal(root);
    printf("---------------------\n");
    printBTreeInOrderTraversal(root);
}

void _printLinkList(){
    List list = initList();
    insertNode(list, 1, 1);
    insertNode(list, 1, 3);
    insertNode(list, 1, 5);
    insertNode(list, 1, 7);
    insertNode(list, 1, 9);
    
    printLinkListFromTailToHead(list);
}

//字符串替换
void stringReplaceBySubstr(){
    char *c = "i love you!";
    char *ret = stringReplace(c, strlen(c));
}

//二维数组查值
void findValOfArray(){
    int a[3][4] = {{1,2,3,4},{5,6,7,8},{9,10,11,12}};
    printf("ret:%d\n",searchTarget((int (*)[100])a, 3, 4, 1));
}


void bubble_Sort(){
    int a[] = {9,2,7,1};
    
    //bubbleSort(a, 4);
    
   //insertSort(a, 4);
    
    quickSort(a, 4);
    
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
    printList(list);
            List revList = reverseList(list);
            printList(revList);
    
    
//            List list1 = initList();
//            insertNode(list1, 1, 2);
//            insertNode(list1, 1, 4);
//            insertNode(list1, 1, 6);
//            insertNode(list1, 1, 8);
//            insertNode(list1, 1, 10);
//
//            merge(list, list1);
//
//            delBackwardNode(list, 3);
//
//            midNode(list1);
//
//
//
//            int a[] = {10,9,5,3,4,7};
//            dual_list dualList = initDual_list(a, 6);
//            printDualList(dualList);
}
