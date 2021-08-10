//
//  LinkedList.c
//  Sort
//
//  Created by 周登杰 on 2021/8/10.
//

#include "LinkedList.h"
#include <stdlib.h>

LinkedList *initLinkedList(int data){
    LinkedList *linkedList = (LinkedList *)malloc(sizeof(LinkedList));
    linkedList->data = data;
    linkedList->next = NULL;
    return linkedList;
}
