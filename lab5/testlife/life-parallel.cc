
using namespace std;
#include "life.h"
#include <pthread.h>
#include <vector>
#include <iostream>
#include <math.h>

LifeBoard g_state;
LifeBoard g_next_state;

pthread_barrier_t our_barrier;

struct thread_args {
    int x_start;
    int x_end;
    LifeBoard* state;
    LifeBoard* next_state;
    int steps;
    int thread_id;
    int total_threads;
};

// x component
void *thread_do_work(void *ptr) {
    thread_args *args = (thread_args*)ptr;
    int x_start = args->x_start;
    int x_end = args->x_end;

    int steps = args->steps;
    for (int step = 0; step < steps; ++step) {
        for (int y = 1; y < g_state.height() - 1; ++y) {
            for (int x = x_start; x < x_end; ++x) {
                int live_in_window = 0;
                /* For each cell, examine a 3x3 "window" of cells around it,
                * and count the number of live (true) cells in the window. */
                for (int y_offset = -1; y_offset <= 1; ++y_offset) {
                    for (int x_offset = -1; x_offset <= 1; ++x_offset) {
                        if (g_state.at(x + x_offset, y + y_offset)) {
                            ++live_in_window;
                        }
                    }
                }
                /* Cells with 3 live neighbors remain or become live.
                    Live cells with 2 live neighbors remain live. */
                g_next_state.at(x, y) = (
                    live_in_window == 3 /* dead cell with 3 neighbors or live cell with 2 */ ||
                    (live_in_window == 4 && g_state.at(x, y)) /* live cell with 3 neighbors */
                );
            }
        }
        pthread_barrier_wait(&our_barrier);
        if (args->thread_id == args->total_threads) {
            // cout << "Swapping: " << args->thread_id << " at total threads = " << args->total_threads << endl;
            swap(g_state, g_next_state);
            // pthread_barrier_init(&our_barrier, NULL, args->total_threads);
        }
        pthread_barrier_wait(&our_barrier);
    }
    return 0;
}

// horizontal
void *thread_be_grinding(void *ptr) {
    thread_args *args = (thread_args*)ptr;
    int x_start = args->x_start;
    int x_end = args->x_end;

    int steps = args->steps;
    for (int step = 0; step < steps; ++step) {
        for (int y = x_start; y < x_end; ++y) {
            for (int x = 1; x < g_state.width() - 1; ++x) {
                int live_in_window = 0;
                /* For each cell, examine a 3x3 "window" of cells around it,
                * and count the number of live (true) cells in the window. */
                for (int y_offset = -1; y_offset <= 1; ++y_offset) {
                    for (int x_offset = -1; x_offset <= 1; ++x_offset) {
                        if (g_state.at(x + x_offset, y + y_offset)) {
                            ++live_in_window;
                        }
                    }
                }
                /* Cells with 3 live neighbors remain or become live.
                    Live cells with 2 live neighbors remain live. */
                g_next_state.at(x, y) = (
                    live_in_window == 3 /* dead cell with 3 neighbors or live cell with 2 */ ||
                    (live_in_window == 4 && g_state.at(x, y)) /* live cell with 3 neighbors */
                );
            }
        }
        pthread_barrier_wait(&our_barrier);
        if (args->thread_id == args->total_threads) {
            // cout << "Swapping: " << args->thread_id << " at total threads = " << args->total_threads << endl;
            swap(g_state, g_next_state);
            // pthread_barrier_init(&our_barrier, NULL, args->total_threads);
        }
        pthread_barrier_wait(&our_barrier);
    }
    return 0;
}


void simulate_life_parallel(int threads, LifeBoard &state, int steps) {
    LifeBoard next_state{state.width(), state.height()};
    // LifeBoard* board_a = new LifeBoard(state);
    g_state = state;
    g_next_state = next_state;
    // set up thread pool
    // cout << "Address of State: " << &state << endl;
    pthread_t* threadPool = new pthread_t[threads];
    // partition the board by columns by the number of threads
    // 1 thread --> full board; 2 threads --> half-board; etc.,
    int v = 0;
    int axis = 0;
    if (state.width() < state.height()) {
        axis = 1;
        v = state.height();
    } else {
        axis = 0;
        v = state.width();
    }
    int k = (v - 2) / threads;
    int m = (v - 2) % threads;
    int start = 1;
    pthread_barrier_init(&our_barrier, NULL, threads);
    vector<thread_args*> vectorThreads;
    for (int i = 0; i < threads; i++) {
        // https://stackoverflow.com/questions/2130016/splitting-a-list-into-n-parts-of-approximately-equal-length
        int end = (start + k + (i < m ? 1 : 0) );
        thread_args* t = new thread_args;
        t->x_start = start;
        t->x_end = end;
        t->state = &state;
        t->next_state = &next_state;
        t->steps = steps;
        t->thread_id = i + 1;
        t->total_threads = threads;
        if (axis == 0) {
            pthread_create(&threadPool[i], nullptr, &thread_do_work, t);
        } else {
            pthread_create(&threadPool[i], nullptr, &thread_be_grinding, t);
        }
        start = end;
        vectorThreads.push_back(t);
    }
    
    for (int i = 0; i < threads; i++) {
        pthread_join(threadPool[i], NULL);
    }

    swap(state, g_state);
    // delete everthing
    pthread_barrier_destroy(&our_barrier);
    for (int i = 0; i < threads; i++) {
        delete vectorThreads[i];
    }
    delete[] threadPool;
}
