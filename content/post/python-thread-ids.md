+++
date = "2016-07-10T20:27:18-05:00"
description = ""
draft = false
tags = []
title = "Python Thread IDs"
topics = ["Python", "threading.Thread"]

+++
## Python `threading` module and thread IDs

In multithreaded Python applications, keeping up with what is happening in each thread can be nonintuitive.

### Context

As a motivating example, consider the benchmark harness [Rally](https://wiki.openstack.org/wiki/Rally).
Rally makes heavy use of parallelism, through both the `multiprocessing` and `threading` Python modules, to provide concurrency for benchmarking.
Consider a simple Rally scenario where the user wants to create a network, subnet, and boot a VM attached to that subnet.  In general, this set of operations would comprise only one iteration.
The scenario would consist of multiple iterations executing concurrently.  Let's assume we want to boot 100 VMs 20 at a time (i.e. "concurrency" in Rally).  Rally will execute iterations 20 at a time until all iterations are consumed from a queue.
To achieve the concurrency, Rally spawns some number of process (8 by default) and multiplexes resource workers threads (equal to the concurrency) on those process with one iteration happening per thread.
Because of the concurrency, the Rally logs are often difficult to decipher when errors come up.
However, if one associates log entries with their thread ID, the logs become easier to to manage.

However, we encountered collisions on the IDs of different threads in the Rally logs.
For example, we noticed log entries from threads in different processes with the same thread IDs.  What remains of this blog is an investigation into that behavior.

### Threads IDs are non-unique

To get thread IDs as part of the log entries in your application, add the [LogRecord attribute](https://docs.python.org/2/library/logging.html#logrecord-attributes) `%(thread)d` to your logHandler's pattern.  This attribute calls [threading.Thread.ident](https://docs.python.org/2/library/threading.html#threading.Thread.ident) to generated the thread ID.
Unfortunately, the Python documentation gives little on implementation details merely stating "Thread identifiers may be recycled when a thread exits and another thread is created."
Immediately, we see that thread IDs may be reused and are therefore non-unique.
Unfortunately, the CPython source for the `threading` module imports the function `get_ident` which generates thread IDs from the module `thread`.
Beyond the additional bit of documentation (e.g. "Its [`thread.get_ident`] value has no direct meaning."), there is very little information available about this function's implementation.
I was unable to find the source code for `thread` anywhere in the CPython source.

In lieu of source code, I decided to write some small examples to corroborate the claims in the documentation and the behavior we experienced in the Rally logs.  In all of the code that follows, we use the following logging shell and `worker` function as a `Thread` target:

```python
import logging

logging.basicConfig(level=logging.DEBUG,
                    format='%(process)d %(thread)d %(levelname)s: %(message)s',
                    )

LOG = logging.getLogger(__name__)

def worker(num):
    time.sleep(0.5)  # ensure first Threads don't die before others spawn
    LOG.info("I'm thread %d" % num)
```

It's important to note the half second sleep in `worker` was necessary to make sure that all threads created "together" had a chance to come up before the first thread exited.

#### Example #1:  One process, threads together

First, we create 5 threads in the `__main__` process all at once.  In this instance, all 5 threads start running before the first thread dies.

```python
### code
from threading import Thread

def simple(n):
    """ Spawn n threads at once and wait for them to finish """
    threads = [Thread(target=worker, args=(ix,)) for ix in range(n)]
    [t.start() for t in threads]
    [t.join() for t in threads]


if __name__ == '__main__':
    LOG.info('Experiment #1')
    simple(5)
```

```
### logs
33018 140735126266624 INFO: Experiment #1
33018 4418879488 INFO: I'm thread 1
33018 4423086080 INFO: I'm thread 2
33018 4414672896 INFO: I'm thread 0
33018 4427292672 INFO: I'm thread 3
33018 4431499264 INFO: I'm thread 4
```

Notice all thread IDs are unique and were spawned by the same process.

#### Example #2:  One process, 10 threads stagered

In this example, we allow 5 threads to come up, run, and exit before starting 5 more threads.

```python
### code
if __name__ == '__main__':
    ...
    LOG.info('Experiment #2')
    simple(5)
    simple(5)
```

```
### logs
33018 140735126266624 INFO: Experiment #2
33018 4418879488 INFO: I'm thread 1
33018 4431499264 INFO: I'm thread 4
33018 4427292672 INFO: I'm thread 3
33018 4414672896 INFO: I'm thread 0
33018 4423086080 INFO: I'm thread 2
33018 4418879488 INFO: I'm thread 1
33018 4414672896 INFO: I'm thread 0
33018 4431499264 INFO: I'm thread 4
33018 4427292672 INFO: I'm thread 3
33018 4423086080 INFO: I'm thread 2
```

Notice again that all threads come from the same process.  However, the second set of threads have the same thread IDs as their counterparts in the first set.  So thread IDs are clearly being recycle, and, moreover, they are being assigned in the same order each time.


#### Example #3:  Multiple processes, threads together

In our final example, we introduce `multiprocessing.Process` to be in line with the motivation example with Rally.
We spawn 3 process and, subsequently, 3 threads in each process.

```python
### code
from multiprocessing import Process

def parallel(m, n):
    """ Spawns m processes with n threads each """
    procs = [Process(target=simple, args=(n,)) for ix in range(m)]
    [p.start() for p in procs]
```

```
### logs
33018 140735126266624 INFO: Experiment #3
33028 4414689280 INFO: I'm thread 0
33028 4423102464 INFO: I'm thread 2
33028 4418895872 INFO: I'm thread 1
33030 4414689280 INFO: I'm thread 0
33029 4418895872 INFO: I'm thread 1
33030 4423102464 INFO: I'm thread 2
33029 4423102464 INFO: I'm thread 2
33029 4414689280 INFO: I'm thread 0
33030 4418895872 INFO: I'm thread 1
```

Here we notice that the same thread IDs are assigned in order to the threads in each process.


### Conclusions

Though we weren't able to see the implementation details from thread IDs in Python's `threading` module, we can draw some conclusions:

* **Thread IDs are recycled.** Example #2 corroborates the documentation's claim that thread IDs are available to be, and *are*, reused when the thread exits.
* **Thread IDs are generated in a cosistent manner.** Example #2 shows that thread IDs are generated in the same order for the second set of thread IDs.
* **Thread ID generation happens indepently of the host process.** Example #3 shows that thread IDs are generated exactly the same regardless of which process they live in.  Moreover, process IDs unique across processes.

However, we can *partially* solve this problem with the following consideration: the uniqueness of *active* thread IDs in a given process, means that Threads are defined uniquely by process ID and thread ID together.
