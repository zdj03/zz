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
