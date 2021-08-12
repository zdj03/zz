//
//  Graph.h
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#ifndef Graph_h
#define Graph_h

#include <stdio.h>
#include "LinkedList.h"

// 无向图
typedef struct Graph {
    int v; // 顶点个数
    LinkedList *adj[]; //邻接表
} Graph;

//typedef struct Queue{
//    int sum;     // 队列中元素个数
//    Node *head;  // 队头
//    Node *tail;  // 队尾
//}kQueue;
//
//// 初始化队头为值为-1的元素（作为哨兵），避免进行边界判断
//kQueue *initQueue(void);
//void enQueue(kQueue *q, int a);
//int dequeue(kQueue *q);


/// 生成无向图
Graph *initGraph(int v);
/// 添加s到t的边
void addEdge(Graph *graph, int s, int t);
/// 广度优先搜索 breadth first search，从s到t的最短路径
void bfs(Graph *graph, int s, int t);
/// 深度优先搜索 Depth first search，从s到t的路径
void dfs(Graph *graph, int s, int t);
#endif /* Graph_h */
