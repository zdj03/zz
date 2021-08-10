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
    LinkedList *adj[]; //领接表
} Graph;


/// 生成无向图
Graph *initGraph(int v);
/// 添加s到t的边
void addEdge(Graph *graph, int s, int t);
#endif /* Graph_h */
