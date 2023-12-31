//William Greig -- wpg6zmk

#include <stdio.h>
#include <string.h>
#include "list.h"


int compare(const void *key, const void *with) {
    return 0;
}

void datum_delete(void *datum) {
    free(datum);
}

void visitor(void *v) {
    printf("%s\n", v);
}


void echo(FILE *file) {
    char line[42];
    int num_lines = 0;
    //40 becuz that's max size of line -- according to instructions
    while (fgets(line, 42, file)) {
        //ignore blank lines
        if (line[0] != '\n') {
            printf("%s", line);
            num_lines++;
        }
    }
    //if empty (no chars)
    if (num_lines == 0) {
        printf("<EMPTY>");
    }
}

void tail(FILE *file, int remove, list_t l) {
    char line[42];
    int num_elements = 0;
    //40 becuz that's max size of line -- according to instructions
    while (fgets(line, 42, file)) {
        //ignore blank lines
        if (line[0] != '\n') {
            //reference for copying string val to void pointer: https://stackoverflow.com/questions/5551427/generic-data-type-in-c-void
            //reference for removing new line from fgets: https://www.geeksforgeeks.org/removing-trailing-newline-character-from-fgets-input/
            line[strcspn(line, "\n")] = '\0';
            char* str_in = strdup(line);
            void* p = str_in;
            list_insert_tail(&l, p);
            num_elements++;
        }
    }
    //if empty (no chars)
    if (num_elements == 0) {
        printf("<EMPTY>");
    }

    if (remove == 0) {
        list_visit_items(&l, visitor);
    }
    
    // tail-remove flag
    if (remove == 1) {
        while (num_elements > 0) {
            int i = 0;
            for (i = 0; i < 3; i = i + 1) {
                list_remove_head(&l);
                num_elements = num_elements - 1;
            }
            list_visit_items(&l, visitor);
            printf("----------\n");
        }
    }
    
}


int main(int argc, char *argv[]) {

    // if (argc < 3 | argc > 3) {
    //     printf("Too many / not enough arguments.");
    //     return 1;

    // }

    FILE *file = fopen(argv[1], "r");
    FILE *file2 = fopen(argv[1], "r");
    //if file not found, throw error and exit
    if (file == NULL) {
        printf("Error opening file %s\n", argv[1]);
        return 1;
    }

    char buf[1024];
    char hello[1024];
    fgets(buf, 6, file);
    fgets(hello, 6, file2);
    printf("%s ", buf);
    printf("%s ", hello);
    
    // list_t l;
    // list_init(&l, compare, datum_delete);

    // if (strcmp(argv[2], "echo") == 0) {
    //     echo(file);
    // } else if (strcmp(argv[2], "tail") == 0) {
    //     tail(file, 0, l);
    // } else if (strcmp(argv[2], "tail-remove") == 0) {
    //     tail(file, 1, l);
    // } else {
    //     printf("Invalid arguments");
    // }

    //close file
    fclose(file);

    return 0;
}