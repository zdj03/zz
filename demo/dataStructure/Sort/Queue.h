//
//  Queue.h
//  Sort
//
//  Created by 周登杰 on 2021/7/14.
//

#ifndef Queue_h
#define Queue_h

#include "BTree.h"

#include <stdio.h>

typedef struct Queue{
    int queueTail;
    int queueHead;
    Node *nodes[100];
}Queue;

Queue *createQueue(void);
void enqueue(Queue *queue, Node *node);
Node *dequeue(Queue *queue);

#endif /* Queue_h */
