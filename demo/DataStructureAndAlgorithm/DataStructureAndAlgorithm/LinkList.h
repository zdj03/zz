//
//  LinkList.h
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/15.
//  Copyright © 2019 zdj. All rights reserved.
//

#ifndef LinkList_h
#define LinkList_h

#include <stdio.h>

//单链表
struct single_list {
    struct single_list *next;
    int val;
};

typedef struct single_list *List, LNode;

/*
 单链表反转
 链表中环的检测
 两个有序链表合并
 删除链表倒数第n个节点
 求链表的中间节点
*/
List initList(void);
void printList(List list);
void insertNode(List list, int i, int e);
void delNode(List list, int i);
List reverseList(List list);
int list_is_cycle(List list);
List merge(List list0, List list1);
void delBackwardNode(List list, int i);
LNode* midNode(List list);




/// 双向链表

//双向链表
struct dual_list{
    struct dual_list *pre;
    struct dual_list *next;
    int val;
};

typedef struct dual_list *dual_list, cycle_list, dual_node;

void printDualList(dual_list list);
dual_list initDual_list(int a[], int length);



/// LRU缓存淘汰算法
void LRU(List list, LNode *node);

#endif /* LinkList_h */



