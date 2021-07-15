//
//  Sort.c
//  Sort
//
//  Created by 周登杰 on 2021/6/27.
//

#include "Sort.h"



void bubbleSort(int array[], int len){
    if (len == 0) {
        return;
    }
    
    // 比较的边界
    int sortBorder = len - 1;

    for (int i = 0; i < len; i++) {
        // 记录此轮比较是否发生了交换，如果没有，表明数组已排好序
        int hasSwap = 0;
        // 记录上一次发生交换的位置，此位置后面的未发生交换，表明后面的已排好序，无需再进行下去，减少比较次数
        int lastSwapIndex = 0;
        for (int j = 0; j < sortBorder; j++) {
            if (array[j] > array[j+1]) {
                int tmp = array[j];
                array[j] = array[j+1];
                array[j+1] = tmp;
                hasSwap = 1;
                lastSwapIndex = j;
            }
        }
        sortBorder = lastSwapIndex;
        if (hasSwap == 0) {
            break;
        }
    }
}

// 左边为有序区间，右边无序，取出无序区间第一位找到在有序区间的位置插入
void insertSort(int arr[], int len){
    for (int i = 1; i < len; i++) {
        // 如果i位置的数大于有序区间最后一位，无需进行比较查找插入位置
        if (arr[i] < arr[i-1]) {
            int tmp = arr[i];
            int j = i - 1;
            for (; j >= 0;j--) {
                if (arr[j] > tmp) {
                    //数据往后移动
                    arr[j+1] = arr[j];
                } else {
                    //找到插入位置
                    break;;
                }
            }
            arr[j+1] = tmp;
        }
    }
}

// 二分插入排序
void binaryInsertSort(int arr[], int len){
    for (int i = 1; i < len; i++) {
        if (arr[i] < arr[i-1]) {
            int tmp = arr[i];
            int start = 0, end = i - 1;
            
            // 二分查找插入位置
            while (end >= start) {
                int mid = start + (end - start) / 2;
                if (tmp > arr[mid]) {
                    start = mid + 1;
                } else {
                    end = mid - 1;
                }
            }
            //数据往后移动
            for (int j = i; j > start; j--) {
                arr[j] = arr[j-1];
            }
            //插入数据
            arr[start] = tmp;
        }
    }
}

// 从无序区间选择最小值放到有序区间最后
void selectSort(int arr[], int len){
    for (int i = 0; i < len; i++) {
        int min = i;
        for (int j = i; j < len; j++) {
            //找到最小值
            if (arr[j] < arr[min]) {
                min = j;
            }
        }
        if (min != i) {
            int tmp = arr[min];
            arr[min] = arr[i];
            arr[i] = tmp;
        }
    }
}

/*
 // 哨兵： 左右区间各加一个最大值MAX_INT，可以利用上面for循环将元素都复制到tmp，完成后再将MAX_INT之前都元素复制回数组arr，达到简化代码的目的。
 int arrCopy[end-start+1+2], p = 0, pp = start;
 for (; pp < mid;) {
     arrCopy[p++] = arr[pp++];
 }
 arrCopy[p] = INT32_MAX;
 pp--;
 for (; pp < end;) {
     arrCopy[p++] = arr[pp++];
 }
 arrCopy[p] = INT32_MAX;
 
 int i = start, j = mid+1, k = 0;
 int tmp[end - start + 1];
 for (; i <= mid+1 && j <= end+1;) {
     if (arrCopy[i] <= arrCopy[j]) {
         tmp[k++] = arrCopy[i++];
     } else {
         tmp[k++] = arrCopy[j++];
     }
 }
 
 for (int j = 0; j < end - start + 1; j++) {
     arr[start++] = arrCopy[j];
 }
 

 */

void _merge(int arr[], int start, int mid, int end){
    int i = start, j = mid+1, k = 0;
    int tmp[end - start + 1];
    // 左右区间比较，较小值复制到tmp
    for (; i <= mid && j <= end;) {
        if (arr[i] <= arr[j]) {
            tmp[k++] = arr[i++];
        } else {
            tmp[k++] = arr[j++];
        }
    }
    
    // 判断左右区间是否遍历完，如果j==end,说明右区间已遍历完，否则说明左区间遍历完
    int p = i, q = mid;
    if(i == mid+1){
        p = j;
        q = end;
    }

    // 将未遍历完的区间剩余数据复制到tmp
    for(;p <= q;){
        tmp[k++] = arr[p++];
    }


    // 将tmp复制回原始数组arr,注：arr是从start开始，而不是0
    for (int m = 0; m < end - start + 1; m++) {
        arr[start + m] = tmp[m];
    }
}

void _mergeSort(int arr[],int start, int end){
    
    // 递归终止
    if (start == end) {
        return;
    }
    
    // 二分数组
    int mid = start + (end - start) / 2;
    
    // 分别处理左右区间
    _mergeSort(arr, start, mid);
    _mergeSort(arr, mid + 1, end);
    // 合并左右区间
    _merge(arr, start, mid, end);
}

//归并排序
void mergeSort(int arr[], int len){
    _mergeSort(arr, 0, len - 1);
}

int partion(int arr[], int start, int end){
    // 选中最后一个元素用来划分区间
    int pivot = arr[end];
    // 记录左边区间尾部
    int last = start;
    // 交换法，将小于pivot的元素移动到小区间
    for (int i = start; i < end + 1; i++) {
        if (arr[i] < pivot) {
            int tmp = arr[i];
            arr[i] = arr[last];
            arr[last] = tmp;
            last++;
        }
    }
    
    // 交换pivot与小区间尾部元素（其实是大区间第一个元素），从而形成：小区间 pivot 大区间
    int tmp = arr[last];
    arr[last] = pivot;
    arr[end] = tmp;
    
    return last;
}


// 将数组分为坐中右三个区间，左边区间值都小于分区点，右边区间都大于分区点
void _quickSort(int arr[], int start, int end){
    if (start >= end) {
        return;
    }
    
    // 获取分区点
    int q = partion(arr, start, end);
    // 分别处理左右分区
    _quickSort(arr, start, q-1);
    _quickSort(arr, q+1, end);
    
}

void quickSort(int arr[], int len){
    _quickSort(arr, 0, len - 1);
}
