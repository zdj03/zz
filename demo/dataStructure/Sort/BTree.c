//
//  BTree.c
//  Sort
//
//  Created by 周登杰 on 2021/7/12.
//

#include "BTree.h"
#include <stdlib.h>
#include <math.h>
#include "Queue.h"

Node * node(int val){
    Node *node = (Node *)malloc(sizeof(Node));
    node->data = val;
    node->lChild = NULL;
    node->rChild = NULL;
    return node;
}

// 先序遍历
void preorderBTree(Root *root){
    if (root == NULL) {
        return;
    }
    
    printf("%d  ",root->data);
    preorderBTree(root->lChild);
    preorderBTree(root->rChild);
}

void inorderBTree(Root *root){
    if (root == NULL) {
        return;
    }
    
    inorderBTree(root->lChild);
    printf("%d  ",root->data);
    inorderBTree(root->rChild);
}

void postorderBTree(Root *root){
    if (root == NULL) {
        return;
    }
    
    postorderBTree(root->lChild);
    postorderBTree(root->rChild);
    printf("%d  ",root->data);
}

void _traverseBTree(Queue *queue){
    Node *node = dequeue(queue);
    if (node == NULL) {
        return;
    }
    printf("%d  ",node->data);
    if (node->lChild) {
        enqueue(queue, node->lChild);
    }
    if (node->rChild) {
        enqueue(queue, node->rChild);
    }
    _traverseBTree(queue);
}

void traverseBTree(Root *root){
    if (root == NULL) {
        return;
    }
    Queue *queue = createQueue();
    enqueue(queue, root);
    
    _traverseBTree(queue);
}


Root* createBTree(int val){
    return node(val);
}


Node* searchBTree(Root *root, int val){
    if (root == NULL) {
        return NULL;
    }
    if (val == root->data) {
        return root;
    } else if (val < root->data){
        searchBTree(root->lChild, val);
    } else {
        searchBTree(root->rChild, val);
    }
    return NULL;
}


void insertBTree(Root *root, int val){
    if (root == NULL) {
        return;
    }
    
    if (val < root->data) {
        if (root->lChild == NULL) {
            root->lChild = node(val);
            return;
        }
        insertBTree(root->lChild, val);
    } else {
        if (root->rChild == NULL) {
            root->rChild = node(val);
            return;
        }
        insertBTree(root->rChild, val);
    }
}

int delBTree(Root *root, int val){
  
    Node *p = root; // 要删除的节点
    Node *pp = NULL; // p的父节点

    while (p != NULL && p->data != val) {
        pp = p;
        if (val < p->data) {
            p = p->lChild;
        } else {
            p = p->rChild;
        }
    }
    
    // 没有找到
    if(p == NULL) return -1;
    
    // 有左右两个叶子节点，查找右叶子最小节点：为右叶子节点的左子树的叶子节点
    if (p->lChild != NULL && p->rChild != NULL) {
        Node *minP = p->rChild;
        Node *minPP = p;
        while (minP->lChild != NULL) {
            minPP = minP;
            minP = minP->lChild;
        }
        // 将最小节点值替换到p中
        p->data = minP->data;
        
        // 替换后，再删除该叶子节点（此种情况，要删除的节点无叶子节点）
        p = minP;
        pp = minPP;
    }
    
    // 以下是只有一个叶子节点或无叶子节点，找到叶子节点替换掉删除掉节点p即可
    Node *child;
    if(p->lChild != NULL) {
        child = p->lChild;
    } else if(pp->rChild != NULL){
        child = p->rChild;
    } else {
        child = NULL;
    }
    
    // 删除的是根节点
    if (pp == NULL) {
        root = child;
    } else if (pp->lChild == p){
        // 删除的是左子节点
        pp->lChild = child;
    } else {
        // 删除的是右子节点
        pp->rChild = child;
    }
    
    free(p);
    
    return 0;
      
}

Node *maxNodeBTree(Root *root){
    if (root == NULL) {
        return NULL;
    }
    if (root->rChild == NULL) {
        return root;
    } else {
        return maxNodeBTree(root->rChild);
    }
}

Node *minNodeBTree(Root *root){
    if (root == NULL) {
        return NULL;
    }
    if (root->lChild == NULL) {
        return root;
    } else {
        return minNodeBTree(root->lChild);
    }
}

int MAX(int a, int b){
    return a > b ? a : b;
}

int heightRecursionBTree(Root *root) {
    if (root == NULL) {
        return 0;
    }
    int lHeight = heightRecursionBTree(root->lChild);
    int rHeight = heightRecursionBTree(root->rChild);
    return MAX(lHeight, rHeight) + 1;
}

int heightIterationBTree(Root *root){
    if (root == NULL) {
        return 0;
    }
    
    // front:每压栈一次，front+1,
    // rear：每出栈一次，rear+1,
    // last:当前层压栈完毕位置，
    // level:高度
    int front = -1, rear = -1, last = 0, level = 0;
    
    Queue *queue = createQueue();
    enqueue(queue, root);
    front++;
    
    while(rear < front){
        Node *node = dequeue(queue);
        rear++;
        if (node->lChild) {
            enqueue(queue, node->lChild);
            front++;
        }
        if (node->rChild) {
            enqueue(queue, node->rChild);
            front++;
        }
        
        // 上一层元素全部出栈完毕（rear == last），当前层元素也全部压栈完毕（last == front），
        if (rear == last) {
            last = front;
            level++;
        }
    }
    
    return level;
}

