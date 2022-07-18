//
//  Backtracking.c
//  Sort
//
//  Created by 周登杰 on 2022/7/13.
//

#include "Backtracking.h"
#include <stdlib.h>
#include <stdbool.h>

int *queens;

void printQueens(void) {
    for (int i = 0; i < 8; ++i) {
        for (int j = 0; j < 8; ++j) {
            if (queens[i] == j) {
                printf("Q ");
            } else {
                printf("* ");
            }
        }
        printf("\n");
    }
    printf("\n");
}

bool isOK(int row, int column) {
    int leftUp = column - 1;
    int rightUp = column + 1;
    for (int i = row - 1; i >= 0; --i) {
        // 此位置被占
        if (queens[i] == column) {
            return false;
        }
        if (leftUp >= 0) {
            if (queens[i] == leftUp) {
                return false;
            }
        }
        if (rightUp < 8) {
            if (queens[i] == rightUp) {
                return false;
            }
        }
        // 往左上走
        --leftUp;
        // 往右上走
        ++rightUp;
    }
    return true;
}

void cal8Queens(int row) {
    if (row == 8) {
        printQueens();
        return;
    }
    for (int column = 0; column < 8; ++column) {
        if (isOK(row, column)) {
            // 符合条件的棋子放到column列
            queens[row] = column;
            // 继续下一行
            cal8Queens(row+1);
        }
    }
}

void eightQueen(void) {
    queens = (int *)malloc(8 * sizeof(int));
    cal8Queens(0);
}
