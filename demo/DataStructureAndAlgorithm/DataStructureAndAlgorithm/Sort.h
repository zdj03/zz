//
//  Sort.h
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/16.
//  Copyright © 2019 zdj. All rights reserved.
//

#ifndef Sort_h
#define Sort_h

#include <stdio.h>

//冒泡排序
void bubbleSort(int a[], int length);
//插入排序
void insertSort(int a[], int length);
//选择排序
void selectionSort(int a[], int length);
//归并排序
void mergeSort(int *a, int length);
//快速排序
void quickSort(int a[], int length);


void print_after_sort(int a[], int length);

#endif /* Sort_h */
