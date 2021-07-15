//
//  Algorithm.h
//  DataStructureAndAlgorithm
//
//  Created by 周登杰 on 2020/7/25.
//  Copyright © 2020 zdj. All rights reserved.
//

#ifndef Algorithm_h
#define Algorithm_h

#include <stdio.h>
#include "LinkList.h"
#include "Array.h"
#include "BTree.h"
#include "Stack.h"

//求最小公倍数(minimum common multiple)
int mcm(int a, int b);


/* ----------剑指offer----------- */
//1、链表逆转
List reverseList(List list);
//2、在一个二维数组中，每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。
int searchTarget(int a[100][100], int rows, int cols, int target);
//3、字符串空格替换
char * stringReplace(char *str0, int len);
//4、输入一个链表，从尾到头打印链表每个节点的值
void printLinkListFromTailToHead(LNode *l);
//5、输入某二叉树的前序遍历和中序遍历的结果，请重建出该二叉树。假设输入的前序遍历和中序遍历的结果中都不含重复的数字。例如输入前序遍历序列{1,2,4,7,3,5,6,8}和中序遍历序列{4,7,2,1,5,3,8,6}，则重建二叉树并返回。
BTree reConstructBTree(int preOrder[], int inOrder[], int len);
//6、用两个栈来实现一个队列，完成队列的Push和Pop操作。 队列中的元素为int类型。

//7、把一个数组最开始的若干个元素搬到数组的末尾，我们称之为数组的旋转。 输入一个非递减排序的数组的一个旋转，输出旋转数组的最小元素。 例如数组{3,4,5,1,2}为{1,2,3,4,5}的一个旋转，该数组的最小值为1。 NOTE：给出的所有元素都大于0，若数组大小为0，请返回0。
int minNumInRotaterArray(int a[], int len);

//8、大家都知道斐波那契数列，现在要求输入一个整数n，请你输出斐波那契数列的第n项。n<=39。
int Fibonacci(int n);

//9、一只青蛙一次可以跳上1级台阶，也可以跳上2级。求该青蛙跳上一个n级的台阶总共有多少种跳法。
int JumpFloor(int steps);

//10、变态跳台阶：一只青蛙一次可以跳上1级台阶，也可以跳上2级……它也可以跳上n级。求该青蛙跳上一个n级的台阶总共有多少种跳法。
int abnormalJumpFloor(int steps);
//11、我们可以用2*1的小矩形横着或者竖着去覆盖更大的矩形。请问用n个2*1的小矩形无重叠地覆盖一个2*n的大矩形，总共有多少种方法？
int tectCover(int n);

//12\输入一个整数，输出该数二进制表示中1的个数。其中负数用补码表示。
int numberOf1(int n);
int numberOf11(int n);

//13\给定一个double类型的浮点数base和int类型的整数exponent。求base的exponent次方。
float power(float base, int exponent);

//14\输入一个整数数组，实现一个函数来调整该数组中数字的顺序，使得所有的奇数位于数组的前半部分，所有的偶数位于位于数组的后半部分，并保证奇数和奇数，偶数和偶数之间的相对位置不变。
void reOrderArray(int a[], int len);

//15\输入一个链表，输出该链表中倒数第k个结点。
LNode* findKthToTail(List list, int k);

//16、输入两个单调递增的链表，输出两个链表合成后的链表，当然我们需要合成后的链表满足单调不减规则。
List mergeList(List list0, List list1);

//17\输入两棵二叉树A，B，判断B是不是A的子结构。（ps：我们约定空树不是任意一个树的子结构）
int hasSubtree(BTree root0, BTree root1);
//18\二叉树的镜像
BTree mirriorTree(BTree root);

//19、输入一个矩阵，按照从外向里以顺时针的顺序依次打印出每一个数字，例如，如果输入如下矩阵： 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 则依次打印出数字1,2,3,4,8,12,16,15,14,13,9,5,6,7,11,10.
int* printMatrix(int **matrix, int cols, int rows);

//20、C语言的文件树结构
//21\定义栈的数据结构，请在该类型中实现一个能够得到栈最小元素的min函数。
int minInStack(int a[], int len);
//22\输入两个整数序列，第一个序列表示栈的压入顺序，请判断第二个序列是否为该栈的弹出顺序。假设压入栈的所有数字均不相等。例如序列1,2,3,4,5是某栈的压入顺序，序列4，5,3,2,1是该压栈序列对应的一个弹出序列，但4,3,5,1,2就不可能是该压栈序列的弹出序列。（注意：这两个序列的长度是相等的）


//21 、计算一个数字的立方根，不使用库函数
//详细描述：
//•接口说明
//原型：
//public static double getCubeRoot(double input)
//输入:double 待求解参数
//返回值:double  输入参数的立方根，保留一位小数
double getCubeRoot_Newton(double input);

//22、字符串反转
char *reverseString(char *a);

////23、输入描述:
//首先输入数字n，表示要输入多少个字符串。连续输入字符串(输出次数为N,字符串长度小于100)。
//输出描述:
//按长度为8拆分每个字符串后输出到新的字符串数组，长度不是8整数倍的字符串请在后面补数字0，空字符串不处理。
void splitStringArrayDividBy8(char (*input)[100], int rows);

//24、如果统计的个数相同，则按照ASCII码由小到大排序输出。如果有其他字符，则对这些字符不用进行统计。
//实现以下接口：
//输入一个字符串，对字符中的各个英文字符，数字，空格进行统计（可反复调用）
//按照统计个数由多到少输出统计结果，如果统计的个数相同，则按照ASCII码由小到大排序输出
//清空目前的统计结果，重新统计
//调用者会保证：
//输入的字符串以‘\0’结尾。

void statisticsChars(char *s);


// 25、排序：iSortFlag 0-升序 1-降序
void sortIntegerArray(int pIntegerArray[], int length, int iSortFlag);

#endif /* Algorithm_h */

