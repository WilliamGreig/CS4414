//William Greig -- wpg6zmk

#include <stdio.h>
#include <stdlib.h>


typedef struct list_item {
struct list_item *pred, *next;
void *datum;
} list_item_t;

typedef struct list {
list_item_t *head, *tail;
unsigned length;
int (*compare)(const void *key, const void *with);
void (*datum_delete)(void *);
} list_t;


void list_init(list_t *l,
int (*compare)(const void *key, const void *with),
void (*datum_delete)(void *datum)) {
    //head and tail should be null by default
    l->head = NULL;
    l->tail = NULL;
    l->length = 0;
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
    // no idea why this isn't working haha...
    // node->datum = malloc(sizeof(v));
    // memcpy(node->datum, v, sizeof(v));
    node->datum = v;
    node->next = NULL;
    if (l->head == NULL) {
        // if list empty, set node as head AND tail
        l->head = node;
        l->tail = node;
    } else {
        //insert as new tail
        l->tail->next = node;
        node->pred = l->tail;
        l->tail = node;
        l->length = l->length + 1;
    }
}

void list_remove_head(list_t *l) {
    if (l->head == NULL) {
        //list is empty; do nothing

    } else {
        list_item_t *node = l->head;
        l->head = node->next;
        l->datum_delete(node->datum);
        free(node);
        l->length = l->length - 1;
    }
}