
using namespace std;
#include "life.h"
#include <pthread.h>
#include <vector>
#include <iostream>
#include <math.h>
/*

PSEUDOCODE:
set up the thread pool via partitioning scheme
for i in iterations:
    



*/
pthread_barrier_t our_barrier;

struct thread_args {
    int x_start;
    int x_end;
    LifeBoard state;
    LifeBoard next_state;
};


void *thread_do_work(void *ptr) {
    thread_args *args = (thread_args*)ptr;
    
    int x_start = args->x_start;
    int x_end = args->x_end;
    LifeBoard state = args->state;
    LifeBoard next_state = args->next_state;
    for (int y = 1; y < state.height() - 1; ++y) {
        for (int x = x_start; x < x_end; ++x) {
            int live_in_window = 0;
            /* For each cell, examine a 3x3 "window" of cells around it,
             * and count the number of live (true) cells in the window. */
            for (int y_offset = -1; y_offset <= 1; ++y_offset) {
                for (int x_offset = -1; x_offset <= 1; ++x_offset) {
                    if (state.at(x + x_offset, y + y_offset)) {
                        ++live_in_window;
                    }
                }
            }
            /* Cells with 3 live neighbors remain or become live.
                Live cells with 2 live neighbors remain live. */
            next_state.at(x, y) = (
                live_in_window == 3 /* dead cell with 3 neighbors or live cell with 2 */ ||
                (live_in_window == 4 && state.at(x, y)) /* live cell with 3 neighbors */
            );
        }
    }
    pthread_barrier_wait(&our_barrier);
    return 0;
}


void simulate_life_parallel(int threads, LifeBoard &state, int steps) {
    LifeBoard next_state{state.width(), state.height()};
    // set up thread pool
    pthread_t* threadPool = new pthread_t[threads];
    // partition the board by columns by the number of threads
    // 1 thread --> full board; 2 threads --> half-board; etc.,
    cout << "Thread Num: " << threads << endl;

    int k = (state.width() - 2) / threads;
    int m = (state.width() - 2) % threads;
    int start = 1;
    pthread_barrier_init(&our_barrier, NULL, threads);
    for (int i = 0; i < threads; i++) {
        int end = (start + k + (i < m ? 1 : 0) );
        // starting x value, end x value, state, next_state
        cout << "x start for thread " << i << ": " << start << endl;
        cout << "x end for thread " << i << ": " << end << endl;
        thread_args t;
        t.x_start = start;
        t.x_end = end;
        t.state = state;
        t.next_state = next_state;
        pthread_create(&threadPool[i], nullptr, &thread_do_work, &t);
        start = end;
    }
    
    for (int i = 0; i < threads; i++) {
        pthread_join(threadPool[i], NULL);
    }

    for (int step = 0; step < steps; ++step) {
        

        /* now that we computed next_state, make it the current state */
        swap(state, next_state);
    }
    pthread_barrier_destroy(&our_barrier);
}
