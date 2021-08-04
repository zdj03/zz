//
//  BTree.h
//  Sort
//
//  Created by 周登杰 on 2021/7/12.
//

#ifndef BTree_h
#define BTree_h

#include <stdio.h>


typedef int bool;
#define true 1
#define false 0

struct BTree {
    int data;
    struct BTree *lChild;
    struct BTree *rChild;
};

typedef struct BTree Root, Node;

Node * node(int val);
Root* createBTree(int val);

//前中后序遍历(递归)
void preorderBTree(Root *root);
void inorderBTree(Root *root);
void postorderBTree(Root *root);

//前中后序遍历(迭代)
int* preorderBTree1(Root *root, int *returnSize);
int* inorderBTree1(Root *root, int *returnSize);
int* postorderBTree1(Root *root, int *returnSize);


//按层次遍历
void traverseBTree(Root *root);

// 二叉查找树
Node* searchBTree(Root *root, int val);
void insertBTree(Root *root, int val);
int delBTree(Root *root, int val);
Node *maxNodeBTree(Root *root);
Node *minNodeBTree(Root *root);

//深度递归法求树高度
int heightRecursionBTree(Root *root);
//层次遍历法求树高
int heightIterationBTree(Root *root);

int** levelOrder(Root* root, int* returnSize, int **returnColumnSize);

// 对称树
bool isSymmetric(struct BTree* root);


#endif /* BTree_h */
