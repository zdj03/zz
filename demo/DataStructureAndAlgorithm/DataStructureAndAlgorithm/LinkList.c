//
//  LinkList.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/15.
//  Copyright © 2019 zdj. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include "LinkList.h"



//创建单链表,表头元素设置为e
List initList(void){
    List list = (List)malloc(sizeof(LNode));
    list->val = -1;
    return list;
}

//创建双向链表，初始值为数组中的元素
dual_list initDual_list(int *a, int length){
    
    dual_list list = (dual_list)malloc(sizeof(dual_node));
    list->val = -1;
    dual_node *tmp = list;
    tmp->next = NULL;
    tmp->pre = NULL;
    
    for (int i = 0; i<length; ++i) {
        dual_node *node = (dual_node*)malloc(sizeof(dual_node));
        node->val = a[i];
        node->pre = tmp;
        node->next = NULL;
        tmp->next = node;
        tmp=tmp->next;
    }
    return list;
}

void printDualList(dual_list list) {
    if (!list) {
           printf("list do not exist!");
           return;
       }

       while (list) {
           printf("val:%d\n",list->val);
           list = list->next;
       }
}

void printList(List list) {
    if (!list) {
        printf("list do not exist!");
        return;
    }
    
    while (list) {
        printf("val:%d\n",list->val);
        list = list->next;
    }
}


//在单链表list的第i个位置插入元素e
void insertNode(List list, int i, int e) {
    List tmp = list;
    int j = 0;
    while (tmp && j < i-1) {
        tmp = tmp->next;
        j++;
    }
    
    if (!tmp || j > i - 1) {
        return;
    }
    
    LNode *node = (LNode *)malloc(sizeof(LNode));
    node->val = e;
    
    node->next = tmp->next;
    tmp->next = node;
}


//删除第i个位置的元素
void delNode(List list, int i){
    List tmp = list;
    
    int j = 0;
    while (tmp->next && j < i-1) {
        tmp = tmp->next;
        ++j;
    }
    
    if (!tmp->next || j > i - 1) {
        return;
    }
    
    LNode *q = tmp->next;
    tmp->next = q->next;
    free(q);
    printf("delNode:%d\n",q->val);
}


//单链表反转
List reverseList(List list) {
    LNode *tmp = list;
    
    LNode *pre =  NULL;
    LNode *next = NULL;

    while (tmp) {
        next = tmp->next;
        tmp->next = pre;
        pre = tmp;
        tmp = next;
    }
    
    //此时tmp是一个空指针，pre才是反转后的头结点
    tmp = pre;
    
    return tmp;
}


//链表中环的检测:如有返回1，无则返回0
int list_is_cycle(List list) {
    if (!list) {
        return 0;
    }
    
    LNode *fast, *slow;
    fast = slow = list;
    
    while (fast && slow) {
        fast = fast->next ? fast->next->next : fast->next;
        slow = slow->next;
        
        if (fast == slow) {
            return 1;
        }
    }
    return 0;
}


//两个有序链表合并
List merge(List list0, List list1) {
    List retList = initList();
    
    LNode *p = list0->next, *q = list1->next, *tmp = retList;
    
    while (p && q) {
      
        if (p->val >= q->val) {
            tmp->next = p;
            p=p->next;

        } else {
            tmp->next = q;
            q=q->next;
        }
        tmp = tmp->next;
    }
    
    //如果有剩余元素未合并，则直接追加到链表尾部
    tmp->next = p ? p : q;

    return retList;
}


//删除链表倒数第n个节点
void delBackwardNode(List list, int i){
    LNode *fast, *slow;
    fast = slow = list->next;
    int j=0;
    
    //fast指针先走i+1步
    while (++j < i+1) {
        fast = fast->next;
    }
    
    //fast、slow一起往前走，直到fast走到表尾，此时slow就是倒数第i+1个节点
    while (fast->next) {
        fast = fast->next;
        slow = slow->next;
    }
    
    //此时p就是要删除的倒数第i个节点
    LNode *p = slow->next;
    slow->next = p->next;
    free(p);
    
    printList(list);
}


//求链表的中间节点
LNode* midNode(List list) {
    if (!list) {
           return NULL;
       }
       
    LNode *fast, *slow;
    fast = slow = list;
    
    while (fast && slow) {
        fast = fast->next ? fast->next->next : fast->next;
        slow = slow->next;
    }
    
    return slow;
}



void LRU(List list, LNode *node) {
    
    LNode *p = list;
    
    //如果node中的元素值之前已经缓存过，则先删除，再将node插入到表头
    while (p->next) {
        LNode *next = p->next;
        if (next->val == node->val) {
            p->next = next->next;
            free(next);

            goto insert;
            
            break;
        }
        p = p->next;
    }
    
      // if (缓存未满){
    //        goto insert;
    //        break;
    //        }

    //        if (缓存已满) {
    //            删除表尾元素
    //            goto insert;
    //        }
            
    
    
insert: {
    node->next = list->next;
    list->next = node;
}
    
    
}
