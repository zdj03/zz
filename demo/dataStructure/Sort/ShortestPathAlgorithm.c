//
//  ShortestPathAlgorithm.c
//  Sort
//
//  Created by 周登杰 on 2022/7/25.
//

#include "ShortestPathAlgorithm.h"
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

/*    PriorityQueue       */
PriorityQueue *initQueue(void) {
    PriorityQueue *queue = (PriorityQueue *)malloc(sizeof(struct PriorityQueue));
    queue->capacity = 100;
    queue->count = 0;
    queue->nodes = (Vertex **)malloc(sizeof(Vertex) * queue->capacity);
    return queue;
}

// 元素位置互换
void swap(PriorityQueue *queue, int l, int r) {
    Vertex *tmp = queue->nodes[l];
    queue->nodes[l] = queue->nodes[r];
    queue->nodes[r] = tmp;
}
// 数组扩容
void increaseMemQueue(PriorityQueue *queue) {
    if (queue->count >= queue->capacity) {
        int capacity = queue->capacity * 2;
        Vertex **expandNodes = (Vertex **)malloc(sizeof(Vertex*) * capacity);
        memcpy(expandNodes, queue->nodes, capacity);
        queue->nodes = expandNodes;
        queue->capacity = capacity;
    }
}

// 数组缩容
void decreaseMemQueue(PriorityQueue *queue) {
    if (queue->count <= queue->capacity / 2) {
        int capacity = queue->capacity / 2;
        if (capacity > 100) {
            Vertex **expandNodes = (Vertex **)malloc(sizeof(Vertex*) * capacity);
            memcpy(expandNodes, queue->nodes, capacity);
            queue->nodes = expandNodes;
            queue->capacity = capacity;
        }
    }
}


Vertex *polling(PriorityQueue *queue) {
    // 将堆顶元素移到数组末尾
    Vertex *vertex = queue->nodes[0];
    swap(queue, 0, queue->count-1);
    queue->count--;
    decreaseMemQueue(queue);
    // 从上往下堆化
    int i = 0;
    while (1) {
        int minPos = i;
        if (2*i+1 <= queue->count-1 && queue->nodes[i] > queue->nodes[2*i+1]) {
            minPos = 2*i+1;
        }
        if (2*i+2 <= queue->count-1 && queue->nodes[i] > queue->nodes[2*i+2]) {
            minPos = 2*i+2;
        }
        if (minPos == i) {
            break;
        }
        swap(queue, i, minPos);
    }
    return vertex;
}

void add(PriorityQueue *queue, Vertex *vertex) {
    if (!vertex) {
        return;
    }
    increaseMemQueue(queue);
    queue->nodes[queue->count++] = vertex;
    // 从下往上开始堆化
    int i = queue->count-1;
    while (i >= 0 && (queue->nodes[i] < queue->nodes[i/2-1])) {
        swap(queue, i, i/2-1);
        i = i/2-1;
    }
}

bool _update(PriorityQueue *queue, Vertex *vertex, int i) {
    if (queue->nodes[i]->vid == vertex->vid) {
        queue->nodes[i]->dist = vertex->dist;
        return true;
    }
    if (_update(queue, vertex, 2*i+1)) {
        return true;
    }
    return _update(queue, vertex, 2*i+2);
}
// 更新节点的最短路径值
void update(PriorityQueue *queue, Vertex *vertex) {
    if (queue->count == 0) {
        return;
    }
    _update(queue, vertex, 0);
}

bool isEmpty(PriorityQueue *queue) {
    return queue->count == 0;
}

