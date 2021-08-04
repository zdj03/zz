//
//  Heap.h
//  Sort
//
//  Created by 周登杰 on 2021/8/4.
//

#ifndef Heap_h
#define Heap_h

#include <stdio.h>

struct Heap {
    int *array; // 保存元素数组
    int max;    // 元素最大个数
    int count;  // 当前元素个数
};

typedef struct Heap Heap;


/// 打印堆元素
void printHeap(Heap *heap);


/// 创建堆
/// max：最大存储数据量
Heap* initHeap(int max);
/// 堆化
void insert(Heap *heap, int a);
/// 删除根节点
void del(Heap *heap);


#endif /* Heap_h */
