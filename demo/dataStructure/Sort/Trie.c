//
//  Trie.c
//  Sort
//
//  Created by 周登杰 on 2021/9/30.
//

#include "Trie.h"
#include <string.h>

TrieNode *createTrie(char ch){
    TrieNode *root = (TrieNode *)malloc(sizeof(TrieNode));
    root->data = ch;
    root->isEndingChar = true;
    for (int i = 0; i < 26; i++) {
        root->children[i] = NULL;
    }
    return root;
}

void insertString(TrieNode *trie, char *str){
    unsigned long len = strlen(str);
    if (!trie || len == 0) return;
    
    TrieNode *p = trie;
    for (int i = 0; i < len; i++) {
        char ch = str[i];
        int index = ch - 'a';
        if (p->children[index] == NULL) {
            p->children[index] = createTrie(ch);
        }
        p = p->children[index];
    }
    p->isEndingChar = true;
}

bool find(TrieNode *trie, char *string){
    TrieNode *p = trie;
    for (int i = 0; i < strlen(string); i++) {
        int index = string[i] - 'a';
        if (p->children[index] == NULL) {
            return false;
        }
        p = p->children[i];
    }
    //是否是尾节点:是尾节点，说明完全匹配；非，说明是前缀
    return p->isEndingChar;
}
