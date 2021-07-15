//
//  Queue.c
//  Sort
//
//  Created by 周登杰 on 2021/7/14.
//

#include "Queue.h"
#include <stdlib.h>

Queue *createQueue(void){
    Queue *queue = (Queue *)malloc(sizeof(Queue));
    queue->queueTail = 0;
    queue->queueHead = 0;
    return queue;
}
void enqueue(Queue *queue, Node *node){
    if (queue == NULL || node == NULL) {
        return;
    }
    queue->nodes[queue->queueTail++] = node;
}

Node *dequeue(Queue *queue){
    if (queue == NULL) {
        return NULL;
    }
    
    if (queue->queueHead == queue->queueTail) {
        // 队头队尾指向同一个元素，说明只剩余一个元素
        Node *ret = queue->nodes[queue->queueHead];
        
        //清空队列
        for (int i = 0; i < queue->queueTail; i++) {
            Node *node = queue->nodes[i];
            queue->nodes[i] = NULL;
            queue->queueHead = 0;
            queue->queueTail = 0;
            free(node);
        }
        return ret;
    } else {
        //返回队头元素，并将队头后移1
        return queue->nodes[queue->queueHead++];
    }
}
