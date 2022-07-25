//
//  Graph.c
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#include "Graph.h"
#include <stdlib.h>
#include <string.h>


Graph *createGraph(int v){
    Graph *graph = (Graph *)malloc(sizeof(Graph));
    graph->v = v;
    
    for (int i = 0; i < v; ++i) {
        graph->adj[i] = initLinkedList();
    }
    
    return graph;
}

/// 无向图一条边存2次
void addEdge(Graph *graph, int s, int t) {
    graph->adj[s]->tail = initNode(t);
    graph->adj[t]->tail = initNode(s);
}

void print(int *prev, int s, int t){
    if(prev[t] != -1 && t != s){
        print(prev, s, prev[t]);
    }
    printf("%d ", t);
}

/*------------------- 图广度优先搜索 -------------------*/
bool bfs(Graph *graph, int s, int t){
    if (s == t) {
        return true;
    }
    bool visited[graph->v];
    memset(visited, false, sizeof(visited));
    int pre[graph->v];
    memset(pre, -1, sizeof(pre));
    
    visited[s] = true;
    
    LinkedList *queue = initLinkedList();
    addNode(queue, s);
    
    Node *curNode;
    int prevData, curData, i;
    LinkedList *sLinkList;
    while (queue->sum != 0) {
        prevData = delFirstNode(queue)->data;
        sLinkList = graph->adj[prevData];
        for (i = 0; i < sLinkList->sum; ++i) {
            curNode = nodeOfIndex(sLinkList, i);
            curData = curNode->data;
            if (visited[curData] == false) {
                pre[curData] = prevData;
                visited[curData] = true;
                if (curData == t) {
                    print(pre, s, t);
                    return true;
                }
                addNode(queue, curData);
            }
        }
    }
    return false;
}


/*------------------- 图深度优先搜索 -------------------*/
bool recurDfs(Graph *graph, int s, int t, bool *visited, int *prev){
    visited[s] = true;
    if (s == t) {
        return true;
    }
    LinkedList *linkList = graph->adj[s];
    Node *node;
    int data, j;
    for (j = 0; j < linkList->sum; ++j) {
        node = nodeOfIndex(linkList, j);
        data = node->data;
        if (visited[data] == false) {
            prev[data] = s;
            return recurDfs(graph, data, t, visited, prev);
        }
    }
    return false;
}

bool dfs(Graph *graph, int s, int t){
    bool visited[graph->v];
    memset(visited, false, sizeof(visited));
    int prev[graph->v];
    memset(prev, -1, sizeof(prev));
    bool found = recurDfs(graph, s, t, visited, prev);
    if (found) {
        print(prev, s, t);
    }
    return found;
}


/*--------------------- 拓扑排序 -------------------*/
void topologyByKahn(Graph *graph){
    // 下标为i的节点的入度
    int inDegree[graph->v];
    for (int i = 0; i < graph->v; ++i) {
        for (int j = 0; j < graph->adj[i]->sum; ++j) {
            int w = nodeOfIndex(graph->adj[i], j)->data;
            inDegree[w]++;
        }
    }
    
    // 入度==0的节点在图中的下标
    LinkedList *queue = initLinkedList();
    for (int i = 0; i< graph->v; ++i) {
        if (inDegree[i] == 0) {
            addNode(queue, i);
        }
    }
    while (queue->sum != 0) {
        int i = delFirstNode(queue)->data;
        LinkedList *iLinkList = graph->adj[i];
        for (int j = 0; j < iLinkList->sum; ++j) {
            int k = nodeOfIndex(iLinkList, j)->data;
            inDegree[k]--;
            if (inDegree[k] == 0) {
                addNode(queue, k);
            }
        }
    }
}

void _topologyByDFS(Graph *graph, bool *visited, int m){
    LinkedList *mLinkList = graph->adj[m];
    for (int i = 0; i < mLinkList->sum; ++i) {
        int data = nodeOfIndex(mLinkList, i)->data;
        if (visited[data] == false) {
            visited[data] = true;
            _topologyByDFS(graph, visited, data);
        }
    }
}
    
void topologyByDFS(Graph *graph){
    // 构建逆邻接表
    Graph *inverseGraph = createGraph(graph->v);
    for (int i = 0; i < graph->v; ++i) {
        inverseGraph->adj[i] = initLinkedList();
    }
    
    // 入度（s->t s为顶点）变出度（t为顶点）
    for (int j = 0; j < graph->v; ++j) {
        LinkedList *jLinkList = graph->adj[j];
        for (int k = 0; k < jLinkList->sum; ++k) {
            Node *node = nodeOfIndex(jLinkList, k);
            addNode(inverseGraph->adj[node->data], j);
        }
    }
    
    bool visited[graph->v];
    memset(visited, false, sizeof(visited));
    // 深度遍历
    for (int m = 0; m < graph->v; ++m) {
        if (visited[m] == false) {
            visited[m] = true;
            _topologyByDFS(inverseGraph, visited, m);
        }
    }
}

