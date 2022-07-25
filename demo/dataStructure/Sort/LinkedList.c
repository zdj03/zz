//
//  LinkedList.c
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#include "LinkedList.h"
#include <stdlib.h>

Node *initNode(int data){
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = data;
    node->next = NULL;
    
    return node;
}


LinkedList *initLinkedList(void){
    LinkedList *linkedList = (LinkedList *)malloc(sizeof(LinkedList));
    linkedList->sum = 0;
    
    Node *node = initNode(-1);
    linkedList->head = node;
    linkedList->tail = node;
    
    return linkedList;
}


void addNode(LinkedList *linkedList, int data){
    if (linkedList == NULL) {
        return;
    }
    
    Node *node = initNode(data);
    linkedList->tail->next = node;
    linkedList->tail = node;
    linkedList->sum++;
}

/// 删除尾节点，用作栈
Node *delLastNode(LinkedList *linkedList){
    if (linkedList == NULL || linkedList->sum == 0) {
        return NULL;
    }
    Node *tmp = linkedList->head;
    while (tmp->next != linkedList->tail) {
        tmp = tmp->next;
    }
    Node *tail = linkedList->tail;
    linkedList->tail = tmp;
    linkedList->sum--;
    return tail;
}
/// 删除头元素(作为队列用)
Node *delFirstNode(LinkedList *linkedList){
    if (linkedList == NULL || linkedList->sum == 0) {
        return NULL;
    }
    Node *firstNode = linkedList->head;
    linkedList->head = firstNode->next;
    linkedList->sum--;
    return firstNode;
}

Node *nodeOfIndex(LinkedList *linkedList, int index){
    if (index < 0 || index >= linkedList->sum) {
        return NULL;
    }
    Node *tmp = linkedList->head;
    while (index-- >= 0) {
        tmp = tmp->next;
    }
    return tmp;
}
