//
//  GreedyAlgorithm.c
//  Sort
//
//  Created by 周登杰 on 2022/7/14.
//

#include "GreedyAlgorithm.h"
#include <stdlib.h>
#include <string.h>

typedef struct NodeData {
    char ch;
    int frequency;
    int code;
} NodeData;

typedef struct TreeNode {
    NodeData *data;
    struct TreeNode *lChild;
    struct TreeNode *rChild;
} TreeNode;

// 0-9 a-z A-Z
static int chCount = 10 + 26 + 26;

// 归并排序
void greedy_merge(NodeData **a, int start, int middle, int end) {
    int i = start, j = middle + 1, k = 0;
    NodeData **tmp = (NodeData **)malloc(sizeof(NodeData) * (end - start + 1));
    memset(tmp, 0, end - start + 1);
    
    while (i <= middle && j <= end) {
        NodeData *left = a[i];
        NodeData *right = a[j];
        if (left->frequency > right->frequency) {
            tmp[k++] = a[i++];
        } else {
            tmp[k++] = a[j++];
        }
    }
    while (i <= middle) {
        tmp[k++] = a[i++];
    }
    while (j < end) {
        tmp[k++] = a[j++];
    }
    i = 0;
    while (i < end - start + 1) {
        a[start + i] = tmp[i];
    }
}

// 根据频次排序，升序
void sortByChFrequency(NodeData **a, int start, int end) {
    if (start >= end) {
        return;
    }
    int middle = (start + end)/2;
    sortByChFrequency(a, start, middle);
    sortByChFrequency(a, middle + 1, end);
    greedy_merge(a, start, middle, end);
}

// 遍历字符串，计算出现频次
int traverseCharCount(char *a, NodeData **b) {
    unsigned long len = strlen(a);
    if (len == 0) {
        return 0;
    }
    size_t size = chCount * sizeof(int);
    int *chFrequency = (int *)malloc(size);
    memset(chFrequency, 0, size);
    
    int i = 0;
    // 实际字符个数
    int count = 0;
    while (i < len) {
        char ch = a[i];
        // 0-9
        if (ch >= '0' && ch <= '9') {
            count++;
            chFrequency[ch - 48]++;
        }
        // A-Z
        if (ch >= 'A' && ch <= 'Z') {
            count++;
            chFrequency[ch - 65 + 10]++;
        }
        // a-z
        if (ch >= 'a' && ch <= 'z') {
            count++;
            chFrequency[ch - 97 + 36]++;
        }
    }
    
    if (count != 0) {
        size_t size = count * sizeof(int);
        b = (NodeData **)malloc(size);
        memset(chFrequency, 0, size);
        for (int i = 0, j = 0; i < chCount; ++i) {
            if (chFrequency[i] != 0) {
                NodeData *data = (NodeData *)malloc(sizeof(NodeData));
                data->ch = (char)i;
                data->frequency = chFrequency[i];
                b[j++] = data;
            }
        }
    }
    return count;
}

// 构造树


void huffmanCode(char *a) {
    NodeData **chCountArr = NULL;
    int chFrequency = traverseCharCount(a, chCountArr);
    sortByChFrequency(chCountArr, 0, chFrequency - 1);
}
