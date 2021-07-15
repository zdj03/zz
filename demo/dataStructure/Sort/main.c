//
//  main.c
//  Sort
//
//  Created by 周登杰 on 2021/6/23.
//

#include <stdio.h>
#include "Sort.h"
#include "Search.h"
#include "BTree.h"

void printArray(int array[],int len){
    for (int i = 0; i < len; i++) {
        printf("%d\n", array[i]);
    }
}

int *generateRandomArray(int len){
    int *array = (int *) malloc(len * sizeof(int));
    
    for (int i = 0; i < len; i++) {
        array[i] = rand() % 100;
    }
    
    return array;
}



    
int main(int argc, const char * argv[]) {
    
    Root *bTree = createBTree(30);
    insertBTree(bTree, 10);
    insertBTree(bTree, 5);
    insertBTree(bTree, 6);
    insertBTree(bTree, 7);
    insertBTree(bTree, 8);
    insertBTree(bTree, 9);
    insertBTree(bTree, 1);
    insertBTree(bTree, 12);
    insertBTree(bTree, 15);
    insertBTree(bTree, 46);
    insertBTree(bTree, 64);
    insertBTree(bTree, 50);
    insertBTree(bTree, 51);
    insertBTree(bTree, 32);
    insertBTree(bTree, 23);
    insertBTree(bTree, 100);
    
    inorderBTree(bTree);
//
//    delBTree(bTree, 23);
    printf("------------------\n");
//    inorderBTree(bTree);
    printf("深度遍历高度：%d", heightRecursionBTree(bTree));
    printf("层次遍历高度：%d", heightIterationBTree(bTree));
    
//    printf("maxNode:%d\n", maxNodeBTree(bTree)->data);
//    printf("minNode:%d\n", minNodeBTree(bTree)->data);
//    printf("height:%d", heightBTree(bTree));
    
//
//    int len = 20;
//    int array[] = {3,2,1,7,6,5};//{3,7,9,12, 23,27,29,40,40,42,42,42,42,42,50,72,73,78,87,92};//generateRandomArray(len);
    
//    printf("before sort------\n");
//    printArray(array, len);
//
//    mergeSort(array, len);
//
//    printf("after sort------\n");
 //   printArray(array, len);
    
    
//    printf("search index: %d\n",search(array, 6, 8));
    
    return 0;
}
