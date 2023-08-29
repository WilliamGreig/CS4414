//William Greig -- wpg6zmk

#include <stdio.h>
#include <stdlib.h>
#include "list.h"

void list_init(list_t *l,
int (*compare)(const void *key, const void *with),
void (*datum_delete)(void *datum)) {
    //head and tail should be null by default
    l->head = NULL;
    l->tail = NULL;
    //comparison + delete function given to list on initialization
    l->compare = compare;
    l->datum_delete = datum_delete;
}

void list_visit_items(list_t *l, void (*visitor)(void *v)) {
    list_item_t *node = l->head;
    while (node != NULL) {
        visitor(node->datum);
        node = node->next;
    }
}

void list_insert_tail(list_t *l, void *v) {
    list_item_t *node = (list_item_t*)malloc(sizeof(list_item_t));
    node->datum = v;
    //if list empty
    if (l->head == NULL) {
        //set both head and tail to null
        l->head = node;
        node->pred = NULL;
        l->tail = node;
    } else { //otherwise append to tail
        l->tail->next = node;
        node->pred = l->tail;
        l->tail = node;
    }
}