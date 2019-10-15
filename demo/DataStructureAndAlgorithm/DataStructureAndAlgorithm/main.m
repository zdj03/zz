//
//  main.m
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2019/10/14.
//  Copyright © 2019 zdj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkList.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        
        List list = initList();
        insertNode(list, 1, 1);
        insertNode(list, 1, 3);
        insertNode(list, 1, 5);
        insertNode(list, 1, 7);
        insertNode(list, 1, 9);
        
        List revList = reverseList(list);
        printList(revList);
       
        
        List list1 = initList();
        insertNode(list1, 1, 2);
        insertNode(list1, 1, 4);
        insertNode(list1, 1, 6);
        insertNode(list1, 1, 8);
        insertNode(list1, 1, 10);
        
//        merge(list, list1);
//
//        delBackwardNode(list, 3);
//
//        midNode(list1);
//
//
//
//        int a[] = {10,9,5,3,4,7};
//        dual_list dualList = initDual_list(a, 6);
//        printDualList(dualList);
    }
    return 0;
}
