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
#include "Heap.h"
#include "StringMath.h"

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

void _heap(){
    Heap *heap = initHeap(1000);
    insert(heap, 10);
    insert(heap, 11);
    insert(heap, 12);
    insert(heap, 13);
    insert(heap, 14);
    insert(heap, 15);
    insert(heap, 16);
    insert(heap, 17);
    insert(heap, 18);
    insert(heap, 20);
    insert(heap, 21);
    insert(heap, 22);
    insert(heap, 23);
    insert(heap, 40);
    insert(heap, 41);
    insert(heap, 42);
    insert(heap, 43);
    insert(heap, 44);
    insert(heap, 50);
    insert(heap, 51);
    insert(heap, 53);
    insert(heap, 55);
    insert(heap, 2);
    insert(heap, 4);
    printHeap(heap);
    del(heap);
    printHeap(heap);
}

    
int main(int argc, const char * argv[]) {
  
    char *a = "1234567890sdfafasa😄sdfssadfas阿斯顿发";
    char *b = "😄";
    
    printf("%d\n", bf(a, b));
    
    return 0;
}
