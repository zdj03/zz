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

void dp(void) {    
    int a[3][3] = {{17,2,17},{16,16,5},{14,3,19}};
    int *p[3] = {a[0],a[1],a[2]};
    int colSize[3] = {3,3,3};
    printf("\n%d\n", paintHouse(p, 3, colSize));
}

int paintHouse(int **costs, int costsSize, int* costsColSize){
    int colors = costsColSize[0];
    int f[costsSize+1][colors];
    int i,j,k;
    for(i = 0; i < costsSize+1;++i) {
        for(j = 0; j < colors;++j) {
            if(i == 0) f[i][j] = 0;
            else {
                f[i][j] = INT_MAX;
                for(k = 0; k< colors; ++k) {
                    if(j != k) {
                        f[i][j] = fmin(f[i][j], f[i-1][k] + costs[i-1][j]);
                    }
                }
            }
        }
    }
    int res = f[costsSize][0];
    for(i = 1;i<colors;++i){
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
