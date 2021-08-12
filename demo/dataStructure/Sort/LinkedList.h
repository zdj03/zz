//
//  LinkedList.h
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#ifndef LinkedList_h
#define LinkedList_h

#include <stdio.h>

typedef struct Node{
    int data;
    struct Node *next;
}Node;

// 初始化队头为值为-1的元素（作为哨兵），避免进行边界判断
typedef struct LinkedList {
    int sum;    // 节点数
    Node *head; // 表头
    Node *tail;  // 表尾
} LinkedList;

/// 生成节点
Node *initNode(int data);
/// 生成链表
LinkedList *initLinkedList(void);
/// 添加元素
void addNode(LinkedList *linkedList, int data);
/// 删除尾元素(作为栈用)
Node *delLastNode(LinkedList *linkedList);
/// 删除头元素(作为队列用)
Node *delFirstNode(LinkedList *linkedList);
/// 获取第index个元素
Node *nodeOfIndex(LinkedList *linkedList, int index);


#endif /* LinkedList_h */
