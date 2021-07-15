//
//  Search.h
//  Sort
//
//  Created by 周登杰 on 2021/6/27.
//

#ifndef Search_h
#define Search_h

#include <stdio.h>

// 二分查找
int binarySearch(int arr[], int len, int value);
// 二分查找第一个等于value的元素
int binarySearchFirstEqual(int arr[], int len, int value);
//查找最后一个值等于给定值的元素
int binarySearchLastEqual(int arr[], int len, int value);
// 二分查找第一个大于等于value的元素
int binarySearchFirstNotLess(int arr[], int len, int value);
//查找最后一个值小于等于给定值的元素
int binarySearchLastNotLarger(int arr[], int len, int value);


#endif /* Search_h */
