//
//  SkipList.c
//  Sort
//
//  Created by 周登杰 on 2021/6/30.
//

#include "SkipList.h"
#include <stdlib.h>
#include <string.h>

//参考：https://blog.csdn.net/m0_37845735/article/details/103691814

#define SKIP_LIST_MALLOC(size)   malloc(size)
#define SKIP_LIST_CALLOC(n,size) calloc(n,size)
#define SKIP_LIST_FREE(p)        free(p)


int randomLevel(SkipList *skipList);


Node *createNode(int val, int key, int maxLevel){
    Node *node = NULL;
    // 节点空间大小 为节点数据大小+ level层索（指针）引所占用的大小
    node = SKIP_LIST_MALLOC(sizeof(*node) + maxLevel * sizeof(node));
    if (node == NULL) {
        return NULL;
    }
    memset(node, 0, sizeof(*node) + maxLevel * sizeof(node));
    node->key = key;
    node->val = val;
    node->maxLevel = maxLevel;
    return node;
}


SkipList * createSkipList(int maxLevel) {
    SkipList *skipList = NULL;
    skipList = SKIP_LIST_MALLOC(sizeof(*skipList));
    if (skipList == NULL) {
        return NULL;
    }
    skipList->level = maxLevel;
    skipList->num = 0;
    skipList->head = createNode(maxLevel, 0, 0);
    if (skipList->head == NULL) {
        SKIP_LIST_FREE(skipList);
        return NULL;
    }
    return  skipList;
}

int insertSkipList(SkipList *list, int key, int val){
    Node **update = NULL;//指针数组
    Node *cur = NULL;
    Node *prev = NULL;
    Node *insert = NULL;
    
    int i =0, level = 0;
    
    if (list == NULL) {
        return -1;
    }
    
    //申请update空间用于保存每层的索引指针
    update = (Node **)SKIP_LIST_MALLOC(sizeof(list->head->maxLevel * sizeof(Node *)));
    if (update == NULL) {
        return -2;
    }
    
    // 逐层查询，查找插入位置的前驱各层节点索引
    // update[0]存放第一层的插入位置前驱节点，update[0]->forward[0]表示插入位置的前驱节点的下一节点update[0]->forward[0]的第一层索引值
    
    //从第一个节点开始的最上层开始
    prev = list->head;
    i = list->level-1;
    for (; i >= 0; i--) {
        // 各层每个节点的下一个节点不为空 && 下个节点的key小于插入的key
        while (((cur = prev->forward[i]) != NULL) && (cur->key < key)) {
            //向后移动
            prev = cur;
        }
        //各层要插入节点的前驱节点
        update[i] = prev;
    }
    
    // 当前key已存在，返回错误
    if((cur != NULL) && (cur->key == key)){
        return -3;
    }
  
    // 获取插入元素的随机层数，并更新跳表的最大层数
    level = randomLevel(list);
    // 创建当前节点
    insert = createNode(level, key, val);
    
    // 根据最大索引层数，更新插入节点的前驱节点，前面已经更新到[0] - [(list->level-1)]
    if(level > list->level){
        for (i = list->level; i < level; i++) {
            // 多新增的索引层，所以前驱节点默认为头节点
            update[i] = list->head;
        }
        //更新跳表的最大索引层数
        list->level = level;
    }
    
    //逐层更新节点的指针
    for (i = 0; i < level; i++) {
        //插入节点的i索引指向前驱节点的i
        insert->forward[i] = update[i]->forward[i];
        //前驱节点的i索引指向插入节点
        update[i]->forward[i] = insert;
    }
    
    // 节点数量加1
    list->num++;
  
    return 0;
}


int randomLevel(SkipList *skipList){
    int i = 0, level = 1;
    // 从第1层开始，每层有0.5的概率需要插入节点
    for (i = 1;i < skipList->level;i++) {
        if (random() % 2 == 1) {
            level++;
        }
    }
    return level;
}


int delSkipList(SkipList *list, int key){
    // 存放删除位置的前驱
    Node **update = NULL;
    Node *cur = NULL;
    Node *prev = NULL;
    int i = 0;
    
    if(list == NULL && list->num == 0){
        return -1;
    }
    
    update = (Node **)SKIP_LIST_MALLOC(sizeof(list->level * sizeof(Node *)));
    if (update == NULL) {
        return -2;
    }
    
    prev = list->head;
    i = list->level - 1;
    //从顶层开始
    for (; i >= 0; i--) {
        // 往后移动，逐层向下到原始链表
        while (((cur = prev->forward[i]) != NULL) && (cur->key < key)) {
            prev = cur;
        }
        //各层要删除的前驱节点
        update[i] = prev;
    }
    
    //当前key存在
    if (cur != NULL && (cur->key == key)) {
        // 逐层删除
        for (int i = 0; i < list->level; i++) {
            if (update[i]->forward[i] == cur) {
                update[i]->forward[i] = cur->forward[i];
            }
        }
        SKIP_LIST_FREE(cur);
        cur = NULL;
        
        // 更新索引的层数
        for (i = list->level; i >= 0; i--) {
            // 如果删除节点后，某层的头节点后驱节点为空，说明该层无索引指针，索引层数需要减1
            if (list->head->forward[i] == NULL) {
                list->level--;
            } else {
                break;
            }
        }
        //链表节点数减1
        list->num--;
    } else {
        return -3;
    }
    return 0;
}


int modifySkipList(SkipList *list, int key, int val){
    Node *cur = NULL;
    Node *prev = NULL;
    int i = 0;
    
    if (list == NULL && list->num == 0) {
        return -1;
    }
    
    // 逐层查找，查询位置原始链表的节点
    prev = list->head;
    // 从第一个节点开始的最上层开始
    i = list->level - 1;
    for (; i >= 0; i--) {
        // 各层每个节点的下一个节点不为空 && 下个节点的key小于要插入的key
        while (((cur = prev->forward[i]) != NULL) && (cur->key < key)) {
            // 向后移到
            prev = cur;
        }
    }
    
    // 当前key存在
    if ((cur != NULL) && (cur->key == key)) {
        cur->val = val;
    } else {
        return -3;
    }
    return 0;
}

// 查询当前key是否存在跳表中，存在修改key对应的value值
int searchSkipList(SkipList *list, int key, int val){
    Node *cur = NULL;
    Node *prev = NULL;
    int i = 0;
    
    if (list == NULL && list->num == 0) {
        return -1;
    }
    
    prev = list->head;
    i = list->level - 1;
    for (; i >= 0; i--) {
        while (((cur = prev->forward[i]) != NULL) && (cur->key) < key) {
            prev = cur;
        }
    }
    
    // 当前key存在
    if ((cur != NULL) && (cur->key == key)) {
        cur->val = val;
    } else{
        return -3;
    }
    return 0;
}
