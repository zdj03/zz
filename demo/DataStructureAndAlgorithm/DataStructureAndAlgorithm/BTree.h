//
//  BTree.h
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2020/8/1.
//  Copyright © 2020 zdj. All rights reserved.
//

#ifndef BTree_h
#define BTree_h

#include <stdio.h>

struct TreeNode{
    int val;
    struct TreeNode *lNode;
    struct TreeNode *rNode;
};

typedef struct TreeNode *BTree, TreeNode;

BTree initBTree(int val);
void setLNode(BTree bT, TreeNode *l);
void setRNode(BTree bT, TreeNode *r);
//先序遍历
void printBTreeFirstTraversal(BTree bT);
//中序遍历
void printBTreeInOrderTraversal(BTree bT);
//后序遍历
void printBTreePostOrderTraversal(BTree bT);

#endif /* BTree_h */
