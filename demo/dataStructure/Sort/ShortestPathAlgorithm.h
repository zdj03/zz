//
//  ShortestPathAlgorithm.h
//  Sort
//
//  Created by 周登杰 on 2022/7/25.
//

#ifndef ShortestPathAlgorithm_h
#define ShortestPathAlgorithm_h

#include <stdio.h>
#include <stdbool.h>

typedef struct Node {
    int data;
    struct Node *next;
} Node;

typedef struct Vertex {
    int vid;     // 顶点编号
    int dist;   // 从起始顶点到这个顶点到距离
} Vertex;

typedef struct LinkedList {
    int total;
    Node *head;
    Node *tail;
} LinkedList;

typedef struct Graphic {
    int v;
    LinkedList *LinkedList[];
} Graphic;

typedef struct Edge {
    int sid; // 边的起始顶点编号
    int eid; // 边的终止顶点编号
    int w;   // 权重
} Edge;

typedef struct PriorityQueue {
    int count;      // 元素个数
    int capacity;   // 数组容量
    Vertex **nodes;
} PriorityQueue;
PriorityQueue *initQueue(void);
Vertex *polling(PriorityQueue *queue);
void add(PriorityQueue *queue, Vertex *vertex);
void update(PriorityQueue *queue, Vertex *vertex);
bool isEmpty(PriorityQueue *queue);

#endif /* ShortestPathAlgorithm_h */
