#include "pool.h"
#include <iostream>
using namespace std;

Task::Task() {
}

Task::~Task() {

}

// "consume"
void *WorkerFunction(void* ptr) {
    ThreadPool* tp = (ThreadPool*)ptr;

    while (tp->stop != true) {
        // TODO: add stop cond_var
        
        while (tp->taskQueue.empty()) {
            pthread_cond_wait(&(tp->data_ready), &(tp->lock));
            
            if (tp->stop == true) {
                pthread_barrier_wait(&(tp->barrier));
                // cease execution
                return 0;
            }
        }
        Task* t = tp->taskQueue.front();
        tp->taskQueue.pop_front();
        t->Run();
        t->done = true;
        pthread_cond_signal(&(t->taskVar));

    }
    pthread_barrier_wait(&(tp->barrier));
    return 0;
}


ThreadPool::ThreadPool(int num_threads) {
    num_minions = num_threads;
    // initialise mutex / cond vars
    pthread_mutex_init(&lock, NULL);
    pthread_cond_init(&data_ready, NULL);
    pthread_cond_init(&stop_cond, NULL);
    
    stop = false;

    pthread_barrier_init(&barrier, NULL, num_minions);

    threadPool = new pthread_t[num_threads];
    

    for (int i = 0; i < num_threads; i++) {
        // thread_args* t = new thread_args;
        // t->thread_id = i + 1;
        pthread_create(&threadPool[i], nullptr, WorkerFunction, (void *)this);
    }
}

// produce Task
void ThreadPool::SubmitTask(const std::string &name, Task* task) {
    // pthread_mutex_lock(&lock);
    taskQueue.push_back(task);
    task->taskName = name;
    task->done = false;
    // cout << "Task Added: " << name << endl;
    // map: name --> cond var for Task
    task->taskVar = PTHREAD_COND_INITIALIZER;
    taskMap.insert({name, task});
    pthread_cond_signal(&data_ready);
    // pthread_mutex_unlock(&lock);
}

void ThreadPool::WaitForTask(const std::string &name) {
    pthread_mutex_lock(&lock);
    Task* t = taskMap.at(name);
    while (t->done == false) {
        pthread_cond_wait(&(t->taskVar), &lock);
    }
    delete t;
    taskMap.erase(name);
    pthread_mutex_unlock(&lock);
}

void ThreadPool::Stop() {
    stop = true;
    for (int i = 0; i < num_minions; i++) {
        pthread_cond_signal(&data_ready); //deadlocks elsewhere
        // int a = pthread_join(threadPool[i], NULL); //deadlocks in worker thread
    }
        // cout << threadPool[i] << endl;
    // pthread_cond_broadcast(&data_ready);
        // int a = pthread_join(threadPool[i], NULL);
    
    // delete EVERYTHING
    // delete[] taskQueue;
    // cout << "Thread POol Delete" << endl;
    delete[] threadPool;
    // cout << "Finished deleting" << endl;
    // pthread_cond_destroy(&data_ready);
    // pthread_mutex_unlock(&lock);
    
}
