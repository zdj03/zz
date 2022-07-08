//
//  Trie.h
//  Sort
//
//  Created by 周登杰 on 2021/9/30.
//

#ifndef Trie_h
#define Trie_h

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

struct TrieNode{
    // 节点存储的字符
    char data;
    // 是否是尾节点
    bool isEndingChar;
    // 子节点(字符集只包含a～z)
    struct TrieNode *children[26];
};

typedef struct TrieNode TrieNode;

//  创建trie树
TrieNode *createTrie(char ch);
// 插入字符串
void insertString(TrieNode *trie, char *str);
// 查找字符串
bool find(TrieNode *trie, char *string);

#endif /* Trie_h */
