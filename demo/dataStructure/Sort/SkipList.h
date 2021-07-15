//
//  SkipList.h
//  Sort
//
//  Created by 周登杰 on 2021/6/30.
//

#ifndef SkipList_h
#define SkipList_h

#include <stdio.h>

typedef struct Node {
    int key;                //  唯一值
    int val;                //节点值
    int maxLevel;           //当前层数
    struct Node *forward[]; //每层的节点数组
} Node;

typedef struct SkipList{
    int level;  // 层数
    int num;    // 节点数
    Node *head; //头指针
} SkipList;

SkipList * createSkipList(int maxLevel);
int insertSkipList(SkipList *list, int key, int val);
int delSkipList(SkipList *list, int key);
int modifySkipList(SkipList *list, int key, int val);
int searchSkipList(SkipList *list, int key, int val);

#endif /* SkipList_h */
