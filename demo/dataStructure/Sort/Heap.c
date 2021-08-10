//
//  Heap.c
//  Sort
//
//  Created by 周登杰 on 2021/8/4.
//

#include "Heap.h"
#include <stdlib.h>
#include <string.h>

Heap* initHeap(int max){
    Heap *heap = (Heap *)malloc(sizeof(Heap));
    heap->max = max;
    heap->count = 0;
    heap->array = (int*)malloc(sizeof(int) * max);
    memset(heap->array, 0, max);
    return heap;
}

void printHeap(Heap *heap){
    for (int i = 0; i < heap->count; i++) {
        printf("%d ", heap->array[i+1]);
    }
    
    printf("\n\n");
}

void swap(int *a, int *b){
    int tmp = *a;
    *a = *b;
    *b = tmp;
}


// 大顶堆：父节点值比子节点值都大。父节点位置为i，左子节点位置为2i,右子节点位置为2i+1
void insert(Heap *heap, int a){
    // 已满
    if (heap->count > heap->max) {
        return;
    }
    // 先将节点插入到最后一个叶子节点，一步步往上与父节点进行比较交换
    heap->array[++heap->count] = a;
    int i = heap->count;
    while (i/2 > 0 && heap->array[i/2] < heap->array[i]) {
        swap(&(heap->array[i/2]), &(heap->array[i]));
        i = i/2;
    }
}


void del(Heap *heap){
    if (heap->count == 0) {
        return;
    }
    
    // 交换根节点与最后一个叶子节点
    swap(&heap->array[1], &heap->array[heap->count]);
    // 将最后一个叶子节点值置为0，达到删除效果
    heap->array[heap->count--] = 0;
    printHeap(heap);
    
    // 从根节点开始处理
    int i = 1, j = 1;
    while (1) {
        // j指向要交换的节点
        // 与左右节点较大的进行交换，达到交换后的根节点值仍然大于左右节点值
        if (heap->array[i*2] > heap->array[i*2 + 1]) {
            j = i * 2;
        } else {
            j = i * 2 + 1;
        }
        // 如果超过数组元素个数，停止
        if (j > heap->count) {
            break;
        }
        // 交换值
        swap(&heap->array[i], &heap->array[j]);
        // i指向子节点
        i = j;
    }
}


void heapify(int a[], int n, int i){
    while (1) {
        int maxPos = i;
        // 如果左子节点比跟节点大
        if (i*2 < n && a[i] < a[i*2]) {
            maxPos = i*2;
        }
        // 如果右子节点比左子节点大
        if (i*2+1 < n && a[i*2] < a[i*2 + 1]) {
            maxPos = i*2 + 1;
        }
        // 位置为i的节点值比子节点都大，无需交换
        if (maxPos == i) {
            break;
        }
        swap(&a[i], &a[maxPos]);
        // 继续往下操作子节点
        i = maxPos;
    }
}

void buildHeap(int a[], int n){
    for (int i = n / 2; i > 1; --i) {
        heapify(a, n, i);
    }
}


void heapSort(int a[], int n){
    // 建堆完成后，堆顶元素最大
    buildHeap(a, n);
    int k = n;
    // 交换堆顶和第k个叶子节点元素，将剩余元素堆化，逐渐将元素交换到数组尾部，完成排序
    while (k > 1) {
        swap(&a[1], &a[k]);
        --k;
        heapify(a, k, 1);
    }
}
