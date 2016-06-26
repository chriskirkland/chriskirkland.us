+++
date = "2016-06-20T09:16:51-05:00"
description = ""
tags = []
title = "Python \"Thread-locality\""
topics = ["Python", "threading.Thread"]

+++
## Python threading module and thread-local objects

The `__init__()` body of Python `threading.Threads` runs in the main thread.
Any Thread-local setup must be done inside of the `threading.Thread.run()` body;
for example, SQLAlchemy`s thread-local [scoped_session](http://docs.sqlalchemy.org/en/latest/orm/contextual.html) must be invoked inside of each thread to avoid conflicts/race conditions/etc.

Here is a simple example:

```python
### threading-example.py (python 2.6+)
from threading import Thread, current_thread

class BadThread(Thread):
    def __init__(self):
        Thread.__init__(self)
        self.current_thread = current_thread()

    def run(self):
        pass

class GoodThread(Thread):
    def __init__(self):
        Thread.__init__(self)

    def run(self):
        self.current_thread = current_thread()

if __name__ == '__main__':
    b1 = BadThread()
    b2 = BadThread()
    b1.start()
    b2.start()
    b1.join()
    b2.join()
    print 'BadThreads are the different : %s' % \
          (b1.current_thread is not b2.current_thread)

    g1 = GoodThread()
    g2 = GoodThread()
    g1.start()
    g2.start()
    g1.join()
    g2.join()
    print 'GoodThreads are the different : %s' % \
          (g1.current_thread is not g2.current_thread)
```

```python
$ python threading-example.py
BadThreads are the different : False
GoodThreads are the different : True
```

