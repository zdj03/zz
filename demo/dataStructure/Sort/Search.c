//
//  Search.c
//  Sort
//
//  Created by 周登杰 on 2021/6/27.
//

#include "Search.h"


// 递归实现
int _binarySearch(int arr[], int start, int end, int value){
    
    if (start > end) {
        return -1;
    }
    
    int mid = start + (end - start) / 2;
    
    if (arr[mid] == value) {
        return mid;
    } else if(arr[mid] < value){
        return  _binarySearch(arr, mid + 1, end, value);
    } else {
        return  _binarySearch(arr, 0, mid - 1, value);
    }
}

// 迭代实现
int _binarySearch1(int arr[], int start, int end, int value){
        
    while (end >= start) {
        int mid = start + (end - start) / 2;
        if (arr[mid] == value) {
            return mid;
        } else if(arr[mid] < value){
            start = mid + 1;
        } else {
            end = mid - 1;
        }
    }
    return -1;
}


int binarySearch(int arr[], int len, int value){
    return _binarySearch1(arr, 0, len - 1, value);
}

int _binarySearchFirstEqual0(int arr[], int len, int value){
    int start = 0, end = len - 1;
    
    while (start <= end) {
        int mid = start + (end - start) / 2;
        if (arr[mid] > value) {
            end = mid - 1;
        } else if (arr[mid] < value){
            start = mid + 1;
        } else {
            if (mid == 0 || arr[mid - 1] != value) {
                return mid;
            } else {
                end = mid - 1;
            }
        }
    }
    return -1;
}

int _binarySearchFirstEqual1(int arr[], int len, int value){
    int start = 0, end = len - 1;
    
    while (start <= end) {
        int mid = start + (end - start) / 2;

        // 如有重复元素，则一直向下查找
        if (arr[mid] >= value) {
            end = mid - 1;
        } else if (arr[mid] < value){
            start = mid + 1;
        }
    }
    
    if (start < len && arr[start] == value) {
        return start;
    }
    
    return -1;
}



int binarySearchFirstEqual(int arr[], int len, int value){
    return _binarySearchFirstEqual1(arr, len, value);
}


int _binarySearchLastEqual0(int arr[], int len, int value){
    int start = 0, end = len - 1;
    while (start <= end) {
        int mid = start + (end - start) / 2;
        // 如果不大于value，一直向上查找
        if (arr[mid] <= value) {
            start = mid + 1;
        } else {
            end = mid - 1;
        }
    }
    if (end > 0 && arr[end] == value) {
        return end;
    }
    return -1;
}

int _binarySearchLastEqual1(int arr[], int len, int value){
    int start = 0, end = len - 1;
    while (start <= end) {
        int mid = start + (end - start) / 2;
        if (arr[mid] > value) {
            end = mid - 1;
        } else if(arr[mid] < value) {
            start = mid + 1;
        } else {
            if (mid == len - 1 || arr[mid + 1] != value) {
                return end;
            } else {
                start = mid + 1;
            }
        }
    }
    return -1;
}



int binarySearchLastEqual(int arr[], int len, int value){
    return _binarySearchLastEqual0(arr, len, value);
}


int _binarySearchFirstNotLess0(int arr[], int len, int value){
    int start = 0, end = len - 1;
    while (start <= end) {
        int mid = start + (end - start) / 2;
        if (arr[mid] >= value) {
            if (mid == 0 || arr[mid - 1] < value) {
                return mid;
            } else {
                end = mid - 1;
            }
        } else {
            start = mid + 1;
        }
    }
    return -1;
}


int binarySearchFirstNotLess(int arr[], int len, int value){
    return _binarySearchFirstNotLess0(arr, len, value);
}

// 100

// 3,3,9,12, 23,27,29,40,40,42,42,42,42,42,50,72,73,78,87,92
int _binarySearchLastNotLarger0(int arr[], int len, int value){
    
    int start = 0, end = len - 1;
    while (start <= end) {
        int mid = start + (end - start) / 2;
        if (arr[mid] <= value) {
            if (mid == len - 1 || arr[mid + 1] > value) {
                return mid;
            } else {
                start = mid  + 1;
            }
        } else {
            end = mid - 1;
        }
    }
    
    return -1;
}

int binarySearchLastNotLarger(int arr[], int len, int value){
    return _binarySearchLastNotLarger0(arr, len, value);
}



int binaySeach(int *nums,int start, int end, int target){
    while(start <= end){
        int mid = start + ((end - start) >> 1);
        if(nums[mid] < target){
            start = mid + 1;
        } else if(nums[mid] > target){
            end = mid - 1;
        } else {
            return mid;
        }
    }
    return -1;
}

// 旋转数组
int search(int* nums, int numsSize, int target){
    if(numsSize == 1){
        if(nums[0] == target) return 0;
        return -1;
    }
    
    int pivot = 0;
    while(pivot <= numsSize - 1){
        if(nums[pivot] > nums[pivot + 1]){
            break;
        }
        pivot++;
    }
    if(nums[0] < target){
       return binaySeach(nums, 1, pivot, target);
    } else if(nums[0] > target){
        return binaySeach(nums, pivot + 1, numsSize - 1, target);
    } else{
        return 0;
    }
}

int search1(int* nums, int numsSize, int target){
    if(numsSize == 1){
        if(nums[0] == target) return 0;
        return -1;
    }
    
    int low = 0, high = numsSize - 1;
    while (low <= high) {
        int mid = low + (high - low) / 2;
        if (nums[mid] == target) {
            return mid;
        }
        if (nums[low] <= nums[mid]) {//左边是有序的
            if (nums[low] <= target && target < nums[mid]) {
                // 目标值在左边
                high = mid - 1;
            } else {
                // 目标值在右边
                low = mid + 1;
            }
        }else { //右边是有序的
            if(nums[mid] < target && target <= nums[high]){
                // 目标值值右边
                low = mid + 1;
            } else {
                // 目标值值左边
                high = mid - 1;
            }
        }
    }
    
    return -1;
}
    
