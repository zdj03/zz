//
//  DvideConquer.c
//  Sort
//
//  Created by 周登杰 on 2022/7/9.
//

#include "DvideConquer.h"
#include <stdlib.h>
#include <string.h>

int num = 0;// 无序对数

void mergeSortCounting(int a[], int start, int end);
void merge(int a[], int start, int middle, int end);

int count(int a[], int n) {
    num = 0;
    mergeSortCounting(a, 0, n - 1);
    return num;
}

// 分治算法，二分法做归并排序，做合并的过程中，统计无序对
void mergeSortCounting(int a[], int start, int end) {
    if (start >= end) {
        return;
    }
    int middle = (start + end)/2;
    mergeSortCounting(a, start, middle);
    mergeSortCounting(a, middle+1, end);
    merge(a, start, middle, end);
}

void merge(int a[], int start, int middle, int end) {
    int i = start, j = middle + 1, k = 0;
    int *tmp = (int *) malloc((end - start + 1) * sizeof(int));
    memset(tmp, 0, sizeof(int) * (end - start + 1));
    
    while (i <= middle && j <= end) {
        if (a[i] <= a[j]) {
            tmp[k++] = a[i++];
        } else {
            // 此时前后数组都是有序的，a[i]如果比a[j]大，a[i...middle]区间的元素都比a[j]大
            num += middle - i + 1;
            tmp[k++] = a[j++];
        }
    }
    while (i <= middle) {
        tmp[k++] = a[i++];
    }
    while (j <= end) {
        tmp[k++] = a[j++];
    }
    for (i = 0; i < end - start + 1;i++) {
        a[start+i] = tmp[i];
    }
}

int* countSmaller(int* nums, int numsSize, int* returnSize){
    int *tmp = (int *)malloc(sizeof(int) * numsSize);
       int i = 0, j = i + 1,count = 0;
       while(i < numsSize){
           count = 0;
           for(j = i+1;j < numsSize;j++) {
               if (nums[i] > nums[j]) {
                   count++;
               }
           }
           tmp[i++] = count;
           *returnSize = count;
           printf("returnSize:%d\n",*returnSize);
       }
       return tmp;
}
