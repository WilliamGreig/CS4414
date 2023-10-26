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

    // pthread_mutex_lock(&(tp->lock));
    while (true) {
        // pthread_mutex_unlock(&(tp->lock));
        // TODO: add stop cond_var
        pthread_mutex_lock(&(tp->lock));
        while (tp->taskQueue.empty()) {
            if (tp->stop == true) {
                // cout << "EXITING!!" << endl;
                pthread_mutex_unlock(&(tp->lock));
                return 0;
            }
            pthread_cond_wait(&(tp->data_ready), &(tp->lock));
            
            if (tp->stop == true) {
                // cout << "EXITING!!" << endl;
                pthread_mutex_unlock(&(tp->lock));
                return 0;
            }
        }
        // pthread_mutex_lock(&(tp->lock));
        Task* t = tp->taskQueue.front();
        tp->taskQueue.pop_front();
        pthread_mutex_unlock(&(tp->lock));

        // cout << "Running task: " << t->taskName << endl;
        t->Run();


        pthread_mutex_lock(&(tp->lock));
        t->done = true;
        pthread_cond_signal(&(t->taskVar));
        pthread_mutex_unlock(&(tp->lock));
    }

    // cout << "Thread exited normally" << endl;
    return 0;
}


ThreadPool::ThreadPool(int num_threads) {
    num_minions = num_threads;
    // initialise mutex / cond vars
    pthread_mutex_init(&lock, NULL);
    pthread_cond_init(&data_ready, NULL);
    
    stop = false;


    threadPool = new pthread_t[num_threads];
    
    for (int i = 0; i < num_threads; i++) {
        pthread_create(&threadPool[i], nullptr, WorkerFunction, (void *)this);
    }
}

// produce Task
void ThreadPool::SubmitTask(const std::string &name, Task* task) {
    pthread_mutex_lock(&lock);
    taskQueue.push_back(task);
    task->taskName = name;
    task->done = false;
    // map: name --> cond var for Task
    task->taskVar = PTHREAD_COND_INITIALIZER;
    taskMap.insert({name, task});
    pthread_cond_broadcast(&data_ready);
    pthread_mutex_unlock(&lock);
}

void ThreadPool::WaitForTask(const std::string &name) {
    // cout << "waiting for task" << name << endl;
    pthread_mutex_lock(&lock);
    Task* t = taskMap.at(name);
    while (t->done == false) {
        // cout << "Waiting for task to complete" << endl;
        pthread_cond_wait(&(t->taskVar), &lock);
    }
    // cout << "Done waiting on task: " << name << endl;
    delete t;
    taskMap.erase(name);
    pthread_mutex_unlock(&lock);
}

void ThreadPool::Stop() {
    // cout << "Stop called: " << endl;

    pthread_mutex_lock(&lock);
    stop = true;

    pthread_cond_broadcast(&data_ready);
    
    pthread_mutex_unlock(&lock);
    
    // pthread_mutex_lock(&lock);
    for (int i = 0; i < num_minions; i++) { //deadlocks elsewhere
        // pthread_cond_broadcast(&data_ready);       
        pthread_join(threadPool[i], NULL); //deadlocks in worker thread
        // cout << "Thread " << i << " exited" << endl;
    }
    
    // delete EVERYTHING
    delete[] threadPool;
    // cout << "Finished deleting" << endl;
    pthread_cond_destroy(&data_ready);
    pthread_mutex_destroy(&lock);
    
}
