#ifndef POOL_H_
#include <string>
#include <pthread.h>
#include <vector>
#include <list>
#include <map>

// struct thread_args {
//     ThreadPool tp;
// };

class Task {
public:
    Task();
    virtual ~Task();
    std::string taskName;
    bool done;
    pthread_cond_t taskVar;
    virtual void Run() = 0;  // implemented by subclass
};

class ThreadPool {
public:
    // std::vector<thread_args*> vectorThreads;
    pthread_t* threadPool;
    int num_minions;

    pthread_mutex_t lock; //= PTHREAD_MUTEX_INITIALIZER;
    pthread_mutex_t stop_cond;
    pthread_cond_t data_ready; // = PTHREAD_COND_INITIALIZER;
    std::list<Task*> taskQueue;
    // std::list<Task*> garbageQueue;
    std::map<std::string, Task*> taskMap;
    bool stop;
    ThreadPool(int num_threads);

    // pthread_barrier_t barrier;

    // void *WorkerFunction(void* args);

    // static void *minion_spawner(void *context) {
    //     return ((ThreadPool *)context)->WorkerFunction(context);
    // }; 

    // Submit a task with a particular name.
    void SubmitTask(const std::string &name, Task *task);
 
    // Wait for a task by name, if it hasn't been waited for yet. Only returns after the task is completed.
    void WaitForTask(const std::string &name);

    // Stop all threads. All tasks must have been waited for before calling this.
    // You may assume that SubmitTask() is not caled after this is called.
    void Stop();
};
#endif
