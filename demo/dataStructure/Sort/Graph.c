//
//  Graph.c
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#include "Graph.h"
#include <stdlib.h>


Graph *createGraph(int v){
    Graph *graph = (Graph *)malloc(sizeof(Graph));
    graph->v = v;
    
    for (int i = 0; i < v; ++i) {
        graph->adj[i] = initLinkedList(0);
    }
    
    return graph;
}

/// 无向图一条边存2次
void addEdge(Graph *graph, int s, int t) {
    graph->adj[s]->next = initLinkedList(t);
    graph->adj[t]->next = initLinkedList(s);
}
