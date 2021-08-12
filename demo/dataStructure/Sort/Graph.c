//
//  Graph.c
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#include "Graph.h"
#include <stdlib.h>
#include <stdbool.h>
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


void bfs(Graph *graph, int s, int t){
    if (s == t) {
        return;
    }
    
    // 将访问过的元素标记为true
    bool *visited = (bool *)malloc(sizeof(bool) * graph->v);
    visited[s] = true;
    
    // 广度遍历队列
    LinkedList *queue = initLinkedList();
    addNode(queue, s);
    
    // 记录遍历路径,数组下标为元素值，存储图的入度的顶点的值
    int *pre = (int *)malloc(sizeof(int) * graph->v);
    memset(pre,-1,graph->v);
    
    while (queue->sum != 0) {
        // 队头元素出栈
        int w = delFirstNode(queue)->data;
        // 遍历对头元素邻接表
        for (int i = 0; i < graph->adj[w]->sum; ++i) {
            int q = nodeOfIndex(graph->adj[w], i)->data;
            if (visited[q] == false) {
                pre[q] = w;
                // 已找到t
                if (q == t) {
                    // 打印路径
                    print(pre, s, t);
                    return;
                }
                visited[q] = true;
                addNode(queue, q);
            }
        }
    }
}


bool found = false;

void recurDfs(Graph *graph, int s, int t, bool *visited, int *prev){
    if (found == true) {
        return;
    }
    
    visited[s] = true;
    if (s == t) {
        found = true;
        return;
    }
    //依次从邻接表的每个元素进行递归深度查找
    for (int i = 0; i < graph->adj[s]->sum; ++i) {
        int q = nodeOfIndex(graph->adj[s], i)->data;
        if (visited[q] == false) {
            prev[q] = s;
            recurDfs(graph, q, t, visited, prev);
        }
    }
}

void dfs(Graph *graph, int s, int t){
    found = false;
    
    bool *visited = (bool *)malloc(sizeof(bool) * graph->v);
    int *prev = (int *)malloc(sizeof(int) * graph->v);
    memset(prev, -1, graph->v);
    recurDfs(graph, s, t, visited, prev);
    print(prev, s, t);
}



//kQueue *initQueue(void){
//    kQueue *q = (kQueue *)malloc(sizeof(kQueue));
//    q->sum = 0;
//    Node *node = (Node *)malloc(sizeof(Node));
//    node->data = -1;
//    node->next = NULL;
//
//    // 初始化，队头队尾指向相同元素
//    q->head = node;
//    q->tail = node;
//
//    return q;
//}
//
//
//void enQueue(kQueue *q, int a){
//    Node *node = initLinkedList(a);
//    q->tail->next = node;
//    q->tail = node;
//    q->sum++;
//}
//
//int dequeue(kQueue *q){
//    if (q->sum == 0) {
//        return -1;
//    }
//    // 获取队头
//    Node *firstNode = q->head->next;
////    队头指向第2个元素
//    q->head = firstNode->next;
//    q->sum--;
//    int ret = firstNode->data;
//    free(firstNode);
//    return ret;
//}
