//
//  BTree.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2020/8/1.
//  Copyright © 2020 zdj. All rights reserved.
//

#include "BTree.h"
#include <stdlib.h>


BTree initBTree(int val){
    BTree t = (BTree)malloc(sizeof(BTree));
    t->lNode = NULL;
    t->rNode = NULL;
    t->val = val;
    return t;
}

TreeNode* initNode(int val){
    TreeNode *node = (TreeNode*)malloc(sizeof(TreeNode));
    node->lNode = NULL;
    node->rNode = NULL;
    node->val = val;
    return  node;
}

void setLNode(BTree bT,TreeNode *l){
    bT->lNode = l;
}

void setRNode(BTree bT,TreeNode *r){
    bT->rNode = r;
}

void printBTreeFirstTraversal(BTree bT){
    if (bT == NULL) {
        return;
    }
    
    printf("val: %d\n", bT->val);
    printBTreeFirstTraversal(bT->lNode);
    printBTreeFirstTraversal(bT->rNode);
}

void printBTreeInOrderTraversal(BTree bT){
    if (bT == NULL) {
        return;
    }
    
    printBTreeInOrderTraversal(bT->lNode);
    printf("val: %d\n", bT->val);

    printBTreeInOrderTraversal(bT->rNode);
}

void printBTreePostOrderTraversal(BTree bT){
    if (bT == NULL) {
        return;
    }
    
    printBTreePostOrderTraversal(bT->lNode);
    printBTreePostOrderTraversal(bT->rNode);
    printf("val: %d\n", bT->val);

}




//MARK: ---二叉搜索树
TreeNode *find(BTree T, int data){
    TreeNode *node = T;
    
    while (node != NULL) {
        if (data < node->val) {
            node = node->lNode;
        } else if (data > node->val){
            node = node->rNode;
        } else {
            return  node;
        }
    }
    return NULL;
}

void insert(BTree T, int data){
    if (T == NULL) {
        T = initBTree(data);
        return;
    }
    
    TreeNode *node = T;
    while (node != NULL) {
        if (data > node->val) {
            if (node->rNode == NULL) {
                node->rNode = initNode(data);
                return;
            }
            node = node->rNode;
        } else {
            if (node->lNode == NULL) {
                node->lNode = initNode(data);
                return;;
            }
            node = node->lNode;
        }
    }
}

void del(BTree T, int data){
    TreeNode *node = T;//node指向要删除的节点，初始化指向根节点
    TreeNode *pNode = NULL;//pNode记录的是node的父节点
    while (node != NULL && node->val != data) {
        pNode = node;
        if (data > node->val) {//data比节点值大，继续做右子树查找
            node = node->rNode;
        } else {//data比节点值小，继续做左子树查找
            node = node->lNode;
        }
    }
    
    if (node == NULL) {//没有找到
        return;
    }
    
    //要删除的节点有两个子节点
    if (node->lNode != NULL && node->rNode != NULL) {
        TreeNode *minNode = node->rNode;
        TreeNode *minPNode = node;//minNode的父节点
        while (minNode->lNode != NULL) {
            minPNode = minNode;
            minNode = minNode->lNode;
        }
        node->val = minNode->val;//将minNode的数据替换到node中
        node = minNode;//下面就变成了删除minNode了
        pNode = minPNode;//干嘛用的？？？？
    }
    
    //删除节点是叶子结点或者仅有一个子节点
    TreeNode *child;//node的子节点
    if (node->lNode != NULL) {
        child = node->lNode;
    } else if (node->rNode != NULL) {
        child = node->rNode;
    }else {
        child = NULL;
    }
    
    if(pNode == NULL) T = child;//删除的是根节点
    else if (pNode->lNode == node) pNode->lNode = child;//如果node是父节点的左子节点，将左子节点赋值给父节点的左子节点
    else pNode->rNode = child;
}
