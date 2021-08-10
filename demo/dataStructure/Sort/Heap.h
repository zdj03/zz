//
//  Heap.h
//  Sort
//
//  Created by 周登杰 on 2021/8/4.
//

#ifndef Heap_h
#define Heap_h

#include <stdio.h>


/**
 堆排序应用：
    1、优先级队列：往队列中加入不同优先级的元素：往堆中插入元素；取队列中优先级最高的元素：删除根节点
    2、
 */

// 大顶堆
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
/// 插入元素
void insert(Heap *heap, int a);
/// 删除根节点
void del(Heap *heap);
/// 数组建堆
void buildHeap(int a[], int n);
/// 堆排序
void heapSort(int a[], int n);
#endif /* Heap_h */
