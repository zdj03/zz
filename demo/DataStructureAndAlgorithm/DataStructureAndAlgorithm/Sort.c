//
//  Sort.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/16.
//  Copyright © 2019 zdj. All rights reserved.
//

#include "Sort.h"
#include <stdlib.h>


/***************************************/
/********** 归并排序 *****************/
/***************************************/
void _merge(int *a, int start, int mid, int end){
    int *tmp = (int*)malloc((end - start -1) * sizeof(int));
    
    if (!tmp) {
        abort();
    }
    
    int i, j, k;
    for (i = start, j = mid+1,k = 0; i <= mid && j <= end;) {
        if (a[i] <= a[j]) {
            tmp[k++] = a[i++];
        } else {
            tmp[k++] = a[j++];
        }
    }
    
    if (i == mid + 1) {
        for (; j <= end;) {
            tmp[k++] = a[j++];
        }
    } else {
        for (; i <= mid; ) {
            tmp[k++] = a[i++];
        }
    }
    memcpy(a+start, tmp, (end - start + 1) * sizeof(int));
    
    free(tmp);
}

void merge_sort(int *a, int p, int r) {
    if (p >= r) {
        return;
    }
    
    int q = (p+r) / 2;
    
    //先处理子问题，再合并
    merge_sort(a, p, q);
    merge_sort(a, q+1, r);
    _merge(a, p, q, r);
}


/// 归并排序
/// @param a 将数组分成两部分，无限分割，直到不能再分，最后将排好序的两个部分合并。时间复杂度：O(nlogn)，空间复杂度：O(n)
/// @param length 数组长度
void mergeSort(int *a, int length){
    merge_sort(a, 0, length - 1);
}

/***************************************/
/********** 快速排序 *****************/
/***************************************/

int partition(int *a, int p, int r){
    
    int pivot = a[r];
    int i = p;//i是已排区间尾部
    for (int j = p; j < r; ++j) {
        if (a[j] < pivot) {
            int tmp = a[i];
            a[i] = a[j];
            a[j] = tmp;
            ++i;
        }
    }
    
    int tmp = a[i];
    a[i] = pivot;
    a[r] = tmp;
    
    return i;
}

void quick_sort_c(int *a, int p, int r){
    if (p >= r) {//只剩一个元素，自然是有序的
        return;
    }
    
    
    //先分区，再处理子问题
    int q = partition(a, p, r);//获取分区点
    quick_sort_c(a, p, q-1);
    quick_sort_c(a, q+1, r);
}

/// 选择数组中下标p到r之间的数据任意一个数据作为分区点（pivot），遍历这组数据，将小于pivot的放到坐标，大于pivot的放到右边。时间复杂度：一般情况：O(nlogn)，极端：O(n2)
/// @param a 数组
/// @param length 数组长度
void quickSort(int a[], int length){
    quick_sort_c(a, 0, length - 1);
}

/***************************************/
/********** 选择排序 *****************/
/***************************************/

/// 将数组分为已排序和未排序区间，每次在未排序区间找到最小的元素，放到已排序区间的末尾（即未排区间的头部）。时间复杂度：O(n*n)
/// @param a 数组
/// @param length 数组长度
void selectionSort(int a[], int length) {
    for(int i = 0; i < length; ++i) {
        int min = i;
        for (int j = i; j < length; ++j) {
            if (a[j] < a[j+1]) {//找到最小值
                min = j;
            }
        }
        
        if (min != i) {
            int value = a[i];
            a[i] = a[min];
            a[min] = value;
        }
    }
}


/***************************************/
/********** 插入排序 *****************/
/***************************************/

/// 将数组分为已排序和未排序区间，每次取未排序区间的一个元素与已排序区间的元素比较，找到插入位置，将已排序区间该位置后的元素向后移动，最后插入该元素。时间复杂度：O(n*n)
/// @param a 数组
/// @param length 数组长度
void insertSort(int a[], int length){
    
    for (int i = 1; i < length; ++i) {
        int value = a[i];
        int j = i - 1;
        
        //查找插入位置
        for (; j >= 0; --j) {
            
            if (a[j] > value) {
                //数据移动
                a[j+1] = a[j];
            } else {
                //此时已经有序，无需再比较
                break;
            }
        }
        //插入数据
        a[j+1] = value;
    }
}

/***************************************/
/********** 冒泡排序 *****************/
/***************************************/

//
/// 每轮排序都是相邻元素两两比较，将较小元素排到后面，最后将最小的元素排到最上面
/// 经过length-1过后，数组所有元素就是有序了。时间复杂度：O(n*n)
/// @param a 数组
/// @param length 数组长度
void bubbleSort(int a[], int length){
        
    static int loops = 0;
    
    for (int i = 0; i < length-1; ++i) {//需要冒泡的轮数
        
        //0:表示没有发生数据交换，1：表示发生了数据交换。如果数组已经有序，则无需进行冒泡
        int hasSwap = 0;
        
        for (int j = 0; j < length - i - 1; ++j) {//每轮两两比较的次数
            if (a[j] < a[j+1]) {
                int tmp = a[j];
                a[j] = a[j+1];
                a[j+1] = tmp;
                
                hasSwap = 1;
                loops++;
            }
        }
        if (hasSwap == 0) {//如果此轮没有发生数据交换，则说明数据已排好序，无需进行下一轮
            break;
        }
    }
    printf("loops ：%d\n", loops);
}


/***************************************/
/********** 数组打印 *****************/
/***************************************/
void print_after_sort(int a[], int length) {
    for (int i = 0; i < length; ++i) {
        printf("[%d] : %d\n", i, a[i]);
    }
}
