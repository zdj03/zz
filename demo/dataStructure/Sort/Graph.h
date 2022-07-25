//
//  Graph.h
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#ifndef Graph_h
#define Graph_h

#include <stdio.h>
#include <stdbool.h>
#include "LinkedList.h"

// 无向图
typedef struct Graph {
    int v; // 顶点个数
    LinkedList *adj[]; //邻接表，Node->data这里表示节点在图中的顺序下标
} Graph;

/// 生成无向图
Graph *createGraph(int v);
/// 添加s到t的边
void addEdge(Graph *graph, int s, int t);
/// 广度优先搜索 breadth first search，从s到t的最短路径
bool bfs(Graph *graph, int s, int t);
/// 深度优先搜索 Depth first search，从s到t的路径
bool dfs(Graph *graph, int s, int t);
#endif /* Graph_h */
