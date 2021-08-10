//
//  LinkedList.h
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#ifndef LinkedList_h
#define LinkedList_h

#include <stdio.h>

typedef struct LinkedList{
    int data;
    struct LinkedList *next;
} LinkedList, Node;

/// 生成链表
LinkedList *initLinkedList(int data);


#endif /* LinkedList_h */
