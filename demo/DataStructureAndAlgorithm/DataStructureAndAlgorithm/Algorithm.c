//
//  Algorithm.c
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2020/7/25.
//  Copyright © 2020 zdj. All rights reserved.
//

#include "Algorithm.h"
#include <stdlib.h>
#include <string.h>

int gcd(int, int);
int gcd1(int, int);

static int loop = 0;

//二者乘积/最大公约数
int mcm(int a, int b){
    int _gcd = gcd1(a, b);
    printf("loop: %d",loop);
    return a*b/_gcd;
}

//求最大公约数：1:相除法 2:相减法
//相除效率 > 相减

//1:相除法
int gcd(int a, int b){
    
    loop++;
//    while (a%b) {
//        int tmp = a;
//        a = b;
//        b = tmp%b;
//        printf("a: %d, b: %d\n",a,b);
//    }
//    return b;
    return a%b == 0 ? b : gcd(b, a%b);
}

//2:相减法
int gcd1(int a, int b){
    while (a != b) {
        loop++;
        if (a < b) {
            a = a ^ b;
            b = a ^ b;
            a = a ^ b;
        }
        a = a - b;
    }
    
    return a;
}

/*-------------------------------------------------------------------*/

char* reverseStr(char *c){
//    char *head = c;
//    char *tail = &c[strlen(c)-1];
//
//
//    char t;
//    while (head != tail) {
//        t = *head;
//        *head = *tail;
//        *tail = t;
//        head++;
//        tail--;
//    }
//
//    return c;
    
    int len = strlen(c),i = 0;
    char *ret = malloc(sizeof(char)*len);
    ret[0] = "a";

//    while (len >= 0) {
//        ret[i++] = "a";
//        printf("ret:%s\n",ret);
//    }
    return ret;
}



char * stringReplace(char *str0, int len){
    
    //统计空格个数
    int spaceNum = 0;
    int i = 0;
    for (i = 0; i < len; i++) {
        if (str0[i] == ' ') {
            spaceNum++;
        }
    }
    
    //新字符串的长度
    int index = len + spaceNum * 2;
    char *ret = malloc(sizeof(char) * index);
    
    //从后往前遍历，提高效率：每次只需移动一个字符。从前往后，需要处理字符位置重叠的问题
    for (i = len; i >= 0; i--) {
        if (str0[i] == ' ') {
            ret[index--] = '0';
            ret[index--] = '2';
            ret[index--] = '%';
        } else {
            ret[index--] = str0[i];
        }
    }
    return ret;
}


void printLinkListFromTailToHead(LNode *l){
    if (!l) {
        return;
    }
    
    if (l->next != NULL) {
        printLinkListFromTailToHead(l->next);
    }
    
    printf("val: %d\n", l->val);
}


//在C中，数组参数会被当做pointers指针来对待，所以表达式sizeof(arr)/sizeof(arr[0])，会变成sizeof(int *)/sizeof(int)，导致计算结果不正确
BTree reConstructBTree(int preOrder[], int inOrder[], int len){
    BTree root = initBTree(preOrder[0]);
    
    if (len == 1) {
        setLNode(root, NULL);
        setRNode(root, NULL);
        return root;
    }
    
    //找到中序中的根的位置
    int rootVal = root->val, i;
    for (i = 0; i < len; i++) {
        if (rootVal == inOrder[i]) {
            break;
        }
    }
    
    //创建左子树
    if(i > 0){
        int pre[i];
        int ino[i];
        for (int j = 0; j < i; j++) {
            pre[j] = preOrder[j+1];
            ino[j] = inOrder[j];
        }
        root->lNode = reConstructBTree(pre, ino, i);
    } else {
        root->lNode = NULL;
    }
    
    //创建右子树
    if(len - i -1 > 0){
        int pre[len - i - 1];
        int ino[len - i - 1];
        for (int j = i + 1; j < len; j++) {
            pre[j - i - 1] = preOrder[j];
            ino[j - i - 1] = inOrder[j];
        }
        root->rNode = reConstructBTree(pre, ino, len - i - 1);
    } else {
        root->rNode = NULL;
    }
    
    return root;
}


int minNumInRotaterArray(int a[], int len){
    if (len == 0) {
        return 0;
    }
    int min = a[0];
    
    for (int i = 0;i < len-1;i++) {
        if (a[i] > a[i+1]) {
            min = a[i+1];
        }
    }
    return min;
}


int Fibonacci(int n){
    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }
    return Fibonacci(n-1) + Fibonacci(n-2);
}


int JumpFloor(int steps){
    if (steps <= 0) {
        return -1;
    }
    if (steps == 1) {
        return 1;
    }
    if (steps == 2) {
        return 2;
    }
    return JumpFloor(steps - 1) + JumpFloor(steps - 2);
}


int abnormalJumpFloor(int steps){
    if (steps < 0) {
        return -1;
    }
    if (steps == 1 || steps == 0) {
        return 1;
    }
    return abnormalJumpFloor(steps - 1) * 2;
}


/*
 如果第一步选择竖方向填充，则剩下的填充规模缩小为n-1；

如果第一步选择横方向填充，则剩下的填充规模缩小为n-2，因为第一排确定后，第二排也就确定了。

 因此，递归式为：

 tectCover(n)= tectCover(n-1)+ tectCover(n-2)；

 边界条件为：

 当n=0时， 总共有0种方法；

 当n=1时， 总共有1种方法；

 当n=2时， 总共有2种方法；
 */
int tectCover(int n){
    if (n == 0) {
        return 0;
    }
    if (n == 1) {
        return 1;
    }
    if (n == 2) {
        return 2;
    }
    
    return tectCover(n - 1) + tectCover(n - 2);
}


//用1（1自身左移运算，其实后来就不是1了）和n的每位进行位与，来判断1的个数
int numberOf1(int n){
    printf("原始数字：%d\n",n);
    int count = 0;
    int flag = 1;
    while (flag != 0) {//左移，高位溢出后，为0
        if ((flag&n) != 0) {
            count++;
        }
        flag = flag<<1;
    }
    return count;
}
//如1100&1011=1000。也就是说，把一个整数减去1，再和原整数做与运算，会把 该整数最右边一个1变成0.那么一个整数的二进制有多少个1，就可以进行多少次这样的操作。
int numberOf11(int n){
    int count = 0;
    while (n != 0) {
        n = n&(n-1);
        count++;
    }
    return count;
}

/*递归计算，降低事件复杂度：O(logn),
当exponent为偶数时，例如求base^10，则result= base^5  *  base^5；
当exponent为奇数数时，例如求base^11，则result= base^5 *  base^5 * base；
接着采用递归的方法，计算base^5 即可。
 */
float power(float base, int exponent){
    float result = 0;
    int n = abs(exponent);
    
    if (n == 0) {
        return 1;
    }
    if (exponent == 1) {
        return base;
    }
    if (exponent == -1) {
        return 1/base;
    }
    
    float half = power(base, n>>1);
    result = half * half;
    if ((n&1)==1) {//判断n的奇偶
        result *= base;
    }
    if (exponent<0) {//倒数
        result = 1/result;
    }
    
    return result;
}


/*
 此题可以用类似冒泡排序的算法来解答。遍历数组，当相邻两个数，前面的数是偶数，后面的数是奇数时，交换两个数。第一轮遍历下来，数组最后面的一个偶数就排好了，接着进行第二轮第三轮，直到所有偶数都排到奇数后面为止。
 */
void reOrderArray(int a[], int len){
    for (int i = 0; i < len - 1; i++) {
        for (int j = 0; j < len - i - 1; j++) {
            //如果相邻连个数分别是偶、奇时，交换位置，将偶数移动到后面，能保证奇偶到稳定性
            if (a[j]%2 == 0 && a[j+1]%2 == 1) {
                int tmp = a[j];
                a[j] = a[j+1];
                a[j+1] = tmp;
            }
        }
    }
}

/*
 两个指针，先让第一个指针和第二个指针都指向头结点，然后再让第一个指正走(k-1)步，到达第k个节点。然后两个指针同时往后移动，当第一个结点到达末尾的时候，第二个结点所在位置就是倒数第k个节点了。
 */
LNode* findKthToTail(List list, int k){
    if (list == NULL || k < 0) {
        return NULL;
    }
    LNode *pre = list;
    LNode *last = list;
    
    //找到第k个节点
    for (int i = k - 1; i > 0; i--) {
        if (last->next != NULL) {
            last = last->next;
        } else {
            return NULL;
        }
    }
    
    //pre跟随last继续走n-k步，即pre还剩k个节点，pre即指向倒数第k个节点
    while (last->next) {
        last = last->next;
        pre = pre->next;
    }
    
    return pre;
}



List mergeList(List list0, List list1){
    if (list0 == NULL) {
        return list1;
    }
    if (list1 == NULL) {
        return list0;
    }

    LNode *head;

    if (list0->val < list1->val) {
        head = list0;
        head->next = mergeList(list0->next, list1);
    } else {
        head = list1;
        head->next = mergeList(list0, list1->next);
    }
    
    return head;
}




int doesTree0HasTree1(BTree tree0, BTree tree1){
    //tree1遍历完成对能对应上，返回1
    if (tree1 == NULL) {
        return 1;
    }
    //tree0比tree1先遍历完成，显然对应不上，返回0
    if (tree0 == NULL) {
        return 0;
    }
    //有一个节点没对应上，返回0
    if (tree0->val != tree1->val) {
        return 0;
    }
    //如果节点值对应上，继续判断两颗树的左右子树
    return doesTree0HasTree1(tree0->lNode, tree1->lNode) && doesTree0HasTree1(tree0->rNode, tree1->rNode) ;
}

int hasSubtree(BTree root0, BTree root1){
    int hasSubtree = 0;
    
    //当两颗树都不为空时才进行比较
    if (root0 != NULL && root1 != NULL) {
        //如果找到了根节点相同
        if (root0->val == root1->val) {
            //以这个根节点为起点判断是否包含tree1
            hasSubtree = doesTree0HasTree1(root0, root1);
        }
        //如果不包含，以root0的左子树进行判断
        if (hasSubtree == 0) {
            hasSubtree = doesTree0HasTree1(root0->lNode, root1);
        }
        //以root0的右子树进行判断
        if (hasSubtree == 0) {
            hasSubtree = doesTree0HasTree1(root0->rNode, root1);
        }
    }
    
    return hasSubtree;
}

BTree mirriorTree(BTree root){
    
    //交换左右子树
    if (root != NULL) {
        BTree tmp = root->lNode;
        root->lNode = root->rNode;
        root->rNode = tmp;
    }
    
    //递归求左右子树的镜像
    if (root->lNode != NULL) {
        mirriorTree(root->lNode);
    }
    if (root->rNode != NULL) {
        mirriorTree(root->rNode);
    }
    
    return root;
}

int* printMatrixInCircle(int **matrix, int cols, int rows, int start){
    int endX = cols - start - 1;
    int endY = rows - start - 1;
    int ret[(endX - start)*2 + (endY - start - 1)*2];
    int m = 0;
    //打印行上
    for (int i = start; i < endX; ++i) {
        ret[m++] = matrix[start][i];
    }
    //打印列右
    for (int j = start+1; j < endY; ++j) {
        ret[m++] = matrix[j][endY];
    }
    //打印行下
    for (int k = endX-1; k >= start; --k) {
        ret[m++] = matrix[endX][k];
    }
    //打印列左
    for (int l = endY-1; l > start; ++l) {
        ret[m++] = matrix[l][start];
    }
    return ret;
}

int* printMatrix(int **matrix, int cols, int rows){
    int result[cols * rows];
    int start = 0;//定义打印矩阵元素的初始序号
    
    while (cols > 2*start && rows > start*2) {
        int *arr = printMatrixInCircle(matrix, cols, rows, start);
        
        start++;
    }
    
    return result;
}


/* ----------------------------------------------------------------*/
typedef struct TreeeNode *PtrToNode;
typedef PtrToNode Tree;

//文件或文件夹节点结构体
struct TreeeNode {
    char *name;//存储目录或文件名称
    Tree parent;//上一级目录
    Tree firstChild;//第一个子目录或自文件
    Tree nextSibling;//下一个弟兄目录或文件
};

//释放内存
void makeEmpty(Tree T){
    if (T->firstChild != NULL) {
        Tree t = T->firstChild->nextSibling;
        makeEmpty(T->firstChild);
        
        Tree tmp = NULL;
        while (t != NULL) {
            tmp = t;
            t = t->nextSibling;
            makeEmpty(tmp);
        }
    }
    free(T);
}

//删除文件/文件夹
void delete(Tree T){
    Tree tmp = NULL;
    if (T->parent != NULL && T->parent->firstChild != T) {//T不为空，且不是其父节点的第一子节点
       //将其他兄弟节点左移，即：1->2->3->4->5,假如删除3，则将3以后的节点左移成为2的兄弟节点
        tmp = T->parent->firstChild;
        //获取3前一个兄弟节点，即2
        while (tmp->nextSibling != T) {
            tmp = tmp->nextSibling;
        }
        //将4作为2的兄弟节点
        tmp->nextSibling = T->nextSibling;
        makeEmpty(T);
    } else if (T->parent != NULL && T->parent->firstChild == T){//T不为空，且T时其父节点的第一个字节点
        //将T的兄弟节点作为其父节点的第一个字节点
        T->parent->firstChild = T->nextSibling;
        makeEmpty(T);
    } else {//T是一个单独的节点
        makeEmpty(T);
    }
}

//获取根目录
Tree getRootDir(Tree T){
    Tree tmp = T;
    while (tmp->parent != NULL) {
        tmp = tmp->parent;
    }
    return tmp;
}

//重命名文件或文件夹
void reName(Tree T, char *newName){
    T->name = newName;
}

//新建一个文件
Tree newFile(char *x){
    Tree T = (Tree)malloc(sizeof(struct TreeeNode));
    T->name = x;
    T->firstChild = T->nextSibling = T->parent = NULL;
    return T;
}

//添加某个文件或目录到指定目录中
Tree insert(Tree des, Tree src){
    //插入到des成为其子节点
    src->parent = des;
    
    if (des->firstChild == NULL) {//成为其第一个字节点
        des->firstChild = src;
    } else {
        //成为最后一个字节点
        Tree tmp = des->firstChild;
        while (tmp->nextSibling != NULL) {
            tmp = tmp->nextSibling;
        }
        tmp->nextSibling = src;
    }
    return des;;
}

//返回节点的深度
int getDepth(Tree T){
    int count = 0;
    Tree tmp = T;
    while (tmp->parent != NULL) {
        count++;
        tmp = tmp->parent;
    }
    return count;
}

//复制文件、符号复制
void copy(Tree file, Tree dir){
    int flag = 1;
    //在dir中查找是否已存在file（以名字是否相同为准）
    if (dir->firstChild != NULL) {
        Tree tmp = dir->firstChild;
        while (tmp != NULL) {
            if (tmp->name != file->name) {
                tmp = tmp->nextSibling;
            } else {
                flag = 0;
                printf("文件已存在，无法复制！\n");
            }
        }
    }
    //不存在，将file插入到dir目录中
    if(flag == 1) {
        dir = insert(dir, file);
    }
}

//前序遍历打印所有文件目录结构
void printWithPreorder(Tree T){
    if (T == NULL) {
        printf("NULL\n");
        return;
    }
    int H = 0;
    if ((H = getDepth(T)) > 0) {
        while (H > 0) {
            printf("\t");
            H--;
        }
        printf("%s\n",T->name);
    } else {
        printf("%s\n",T->name);
    }
    
    Tree tmp = T;
    Tree child = tmp->firstChild;
    while (child != NULL) {
        printWithPreorder(child);
        child = child->nextSibling;
    }
}


/* ----------------------------------------------------------------*/


int minInStack(int a[], int len){
    Stack dataStack = init(len);
    Stack minStack = init(len);
    
    for (int i = 0; i < len; i++) {
        int val = a[i];
        push(dataStack, val);
        if (minStack->elemCount == 0 || peekInStack(minStack)) {
            push(minStack, val);
        } else {
            push(minStack, peekInStack(minStack));
        }
    }
    return peekInStack(minStack);
}
