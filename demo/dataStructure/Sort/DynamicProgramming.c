//
//  DynamicProgramming.c
//  Sort
//
//  Created by 周登杰 on 2022/7/17.
//

#include "DynamicProgramming.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <limits.h>
#include <stdbool.h>

// 三种硬币（2元、5元、7元），每种足够多，买一本书需要27元，如何用最少的硬币组合正好付清，不需要对方找钱
int coinChange0(int coinValue[], int n, int sum);
// 给定m行n列的网格，有一个机器人从左上角（0，0）出发，每一步可以向下或者向右走一步，问有多少种不同的方式走到右下角
int uniquePaths(int m, int n);
// 给定m行n列的网格，有一个机器人从左上角（0，0）出发，每一步可以向下或者向右走一步，网格中有些地方有障碍，机器人不能通过障碍格，问有多少种不同的方式走到右下角
int uniquePathsWithObstacles(int m, int n, bool **obstacles);


// 有n块石头分别在x轴的0,1,...n-1的位置，一只青蛙在石头0，想跳到石头n-1，如果青蛙在第i块石头上，它最多可以向右跳距离a[i],问青蛙能否跳到石头n-1
bool jumpGame(int *a, int n);

// 有一排N栋房子，每栋房子要漆成3中颜色中的一种：红蓝绿，任何2栋相邻的房子不能漆成相同的颜色，第i栋房子染成红色、蓝色、绿色的话费分别是cost[i][0]、cost[i][1]、cost[i][2]，问最少需要花多少钱油漆这些房子
int paintHouse(int **costs, int costsSize, int* costsColSize);

// 有一排房子N栋房子（0～N-1），房子i里有A[i]个金币，一个窃贼想选择一些房子偷金币，但是不能偷任何挨着的两家邻居，否则会被警察逮住最多偷多少金币
int hourseRobber1(int *coins, int n);
// 有一圈N栋房子，房子i-1里有A[i]个金币，一个窃贼想选择一些房子偷金币，但是不能偷任何挨着的两家邻居，否则会被警察逮住最多偷多少金币
int hourseRobber2(int *coins, int n);
// 已知后面N天一支股票的每天的价格p0,p1,...pn-1,可以最多买一股卖一股，求最大利润
int stock1(int *a, int n);
// 已知后面N天一支股票的每天的价格p0,p1,...pn-1,可以买卖一股任意多次，但任意时刻手中最多持有一股，求最大利润
int stock2(int *a, int n);
// 给定一个字符串S[0...N-1]，要求将这个字符串划分成若干段，每一段都是一个回文串，求最少划分几次
int palindromePartitioning(char *a);
bool isPalindrome(char *s, int p, int q);


int maxProfit(int k, int* prices, int pricesSize);



void dp(void) {
    char a3[] = "a";
    printf("\n%d\n", palindromePartitioning(a3));
}

bool isPalindrome1(char *s, int p, int q) {
    while (p < q) {
        if (s[p] == s[q]) {
            ++p;
            --q;
        } else {
            return false;
        }
    }
    return true;
}

int palindromePartitioning(char *a){
    int n = (int)strlen(a);
        // i~j是否是回文字符串
        bool palin[n][n];
        memset(palin, false, sizeof(palin));
        int i,j,t;
        for(t=0;t<n;++t){
            i=j=t;
            while(i>=0 && j<n && a[i]==a[j]){
                palin[i][j]=true;
                --i;
                ++j;
            }
            i=t;
            j=t+1;
            while(i>=0 && j<n && a[i]==a[j]){
                palin[i][j]=true;
                --i;
                ++j;
            }
        }
        int f[n+1];
        f[0]=0;
        for (i=1; i<=n; ++i) {
            f[i]=INT_MAX;
            for(j=0;j<i;++j){
                //j~i是回文，+1
                if (palin[j][i-1]) {
                    f[i]=fmin(f[i], f[j]+1);
                }
            }
        }
        return f[n]-1;
}

bool isLowerChar(char ch) {
    return ('a'<=ch && ch<='z');
}

bool isNumChar(char ch) {
    return ('0'<=ch && ch<='9') || ('A'<=ch && ch<='Z') || ('a'<=ch && ch<='z');
}

// A man, a plan, a canal: Panama
bool isPalindrome(char *s, int p, int q) {
    while (p < q) {
        while (!isNumChar(s[p]) && p<q) {
            ++p;
        }
        while (!isNumChar(s[q]) && p<q) {
            --q;
        }
        if (isLowerChar(s[p])) {
            s[p] -= 32;
        }
        if (isLowerChar(s[q])) {
            s[q] -= 32;
        }
        if (s[p] == s[q]) {
            ++p;
            --q;
        } else {
            return false;
        }
    }
    return true;
}

int maxProfit(int k, int* prices, int pricesSize){
    if (pricesSize==0) {
        return 0;
    }
    int f[pricesSize+1][k+1];
    memset(f, 0, sizeof(f));
    int i, j;
    f[0][1]=0;
    f[0][2]=f[0][3]=f[0][4]=f[0][5]=INT_MIN;
    for (i = 1; i < pricesSize+1; ++i) {
        for (j=1; j<=5; j += 2) {
            f[i][j] = f[i-1][j];
            if (j>1 && i>1 && f[i-1][j-1] != INT_MAX) {
                f[i][j] = fmax(f[i-1][j-1]+prices[i-1]-prices[i-2], f[i][j]);
            }
        }
        for (j=2; j<=5; j += 2) {
            f[i][j]=f[i-1][j-1];
            if (i>1 && f[i-1][j] != INT_MIN) {
                f[i][j] = fmax(f[i][j], f[i-1][j]+prices[i-1]-prices[i-2]);
            }
            if (j!=2 && i > 1 && f[i-1][j-2] != INT_MIN) {
                f[i][j] = fmax(f[i][j], f[i-1][j]+prices[i-1]-prices[i-2]);
            }
        }
    }
    
    return fmax(f[pricesSize][1], fmax(f[pricesSize][3], f[pricesSize][5]));
}


int stock2(int *a, int n) {
   // 最优策略：价格上升的区间：昨天买入，今天卖出
    int res=0;
    for (int i=0; i<n-1; ++i) {
        if (a[i]<a[i+1]) {
            res+=a[i+1]-a[i];
        }
    }
    return res;
}


int stock1(int *a, int n) {
    //  当前时刻之前，买入的最低价格，当前卖出即最大
    if (n==0) return 0;
    int max=0;
    int min=a[0];
    int i;
    for (i = 1; i < n; ++i) {
        if (a[i-1]<min) {
            min=a[i-1];
        }
        max=fmax(max,a[i]-min);
    }
    return max;
}

int hourseRobber2(int *nums, int numsSize) {
    if(numsSize == 0) return 0;
    if(numsSize == 1) return nums[0];
    if(numsSize == 2) return fmax(nums[0],nums[1]);
    int f[numsSize+1];
    f[0]=0;
    f[1]=0;
    f[2]=nums[1];
    // 不偷房子1
    for (int i = 3;i < numsSize+1;++i) {
        f[i] = fmax(f[i-1], f[i-2] + nums[i-1]);
    }
    // 不偷房子n
    f[1]=nums[0];
    f[2]=0;
    for (int i = 2;i < numsSize; ++i) {
        f[i] = fmax(f[i-1], f[i-2] + nums[i-1]);
    }
    return fmax(f[numsSize], f[numsSize-1]);
}


int hourseRobber1(int *coins, int n) {
    if (n==0) {
        return 0;
    }
    int f[n+1];
    memset(f, 0, sizeof(f));
    f[0] = 0;
    f[1] = coins[0];
    
    int i = 2;
    for (; i < n+1; ++i) {
        //         fmax(不偷第i栋房子 ， 偷第i栋房子)
        f[i] = fmax(f[i-1], f[i-2]+coins[i-1]);
    }
    return f[n];
}

int paintHouse(int **costs, int costsSize, int* costsColSize){
    int colors = costsColSize[0];
    int f[costsSize+1][colors];
    int i,j,k;
    
    // 第i-1栋房子染色的最小值、次小值的颜色坐标
    int j1 = 0, j2 = 0;
    // 第i-1栋房子染色的最小值、次小值
    int min1, min2;
    
    for (j = 0; j < colors; ++j) {
        f[0][j] = 0;
    }
    for(i = 1; i < costsSize+1;++i) {
        min1 = min2 = INT_MAX;
        for(j = 0; j < colors;++j) {
            if (f[i-1][j] < min1) {
                min2 = min1;
                j2 = j1;
                min1 = f[i-1][j];
                j1 = j;
            } else {
                if (f[i-1][j] < min2) {
                    min2 = f[i-1][j];
                    j2 = j;
                }
            }
            for(k = 0; k< colors; ++k) {
                // 不为最小值，+次小值
                if(j != j1) {
                    f[i][j] = f[i-1][j1] + costs[i-1][j];
                } else {
                    // 最小值，+最小值
                    f[i][j] = f[i-1][j2] + costs[i-1][j];
                }
            }
        }
    }
    int res = INT_MAX;
    for(i = 0;i<colors;++i){
        res = fmin(res,f[costsSize][i]);
    }
    return res;
}


int uniquePathsWithObstacles(int m, int n, bool **obstacles) {
    int f[m][n];
    memset(f, 0, sizeof(f));
    f[0][0] = 1;
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            if (!obstacles[i][j]) {
                if (i == 0 || j == 0) {
                    f[i][j] = 1;
                } else {
                    f[i][j] = f[i-1][j] + f[i][j-1];
                }
            }
        }
    }
    return f[m-1][n-1];
}


bool jumpGame(int *a, int n) {
    bool f[n];
    memset(f, false, n);
    f[0] = true;
    for (int i = 1; i < n; ++i) {
        for (int j = 0; j < i; ++j) {
            if (f[j] && j + a[j] >= i) {
                f[i] = true;
                break;
            }
        }
    }
    return f[n-1];
}

int uniquePaths(int m, int n) {
    int grid[m][n];
    memset(grid, 0, sizeof(grid));
    grid[0][0] = 1;
    int i = 0, j = 0;
    for (i = 0; i < m; ++i) {
        for (j = 0; j < n; ++j) {
            if (i == 0 || j == 0) {
                grid[i][j] = 1;
            } else {
                grid[i][j] = grid[i-1][j] + grid[i][j-1];
            }
        }
    }
    return grid[m-1][n-1];
}


int coinChange0(int coinValue[], int n, int sum) {
    int f[sum];
    memset(f, 0, sizeof(f));
    f[0] = 0;
    int i, j, k;
    for (i = 1; i <= sum; ++i) {
        f[i] = INT_MAX;
        k = 0;
        for (j = 0; j < n; ++j) {
            if (i >= coinValue[j] && f[i - coinValue[j]] != INT_MAX) {
                if (f[i - coinValue[j]] + 1 < f[i]) {
                    f[i] = f[i - coinValue[j]] + 1;
                }
            }
        }
    }
    if (f[sum] == INT_MAX) {
        return -1;
    }
    return f[sum];
}

// coinChange1(x)表示最少用多少枚硬币拼出x
int coinChange1(int x) {
    if (x == 0) {
        return 0;
    }
    int res = INT_MAX;
    int tmp = res;
    if (x >= 2) {
        tmp = coinChange1(x-2);
        if (tmp < res) {
            res = fmin(tmp + 1, res);
        }
    }
    if (x >= 5) {
        tmp = coinChange1(x-5);
        if (tmp < res) {
            res = fmin(tmp + 1, res);
        }
    }
    if (x >= 7) {
        tmp = coinChange1(x-7);
        if (tmp < res) {
            res = fmin(tmp + 1, res);
        }
    }
    return res;
}
