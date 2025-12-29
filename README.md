# Multi-Threaded In-Memory Key-Value Store

A thread-safe in-memory hash table that supports concurrent:
reads
writes
deletes
blocking reads (“wait until key exists”)

```cpp
class ConcurrentKVStore {
public:
    void put(std::string key, std::string value);
    bool get(std::string key, std::string& out);
    void erase(std::string key);

    // Blocks until key exists
    std::string wait_and_get(std::string key);
};
```

---

## 1. Overview

The goal of this project is to implement a **thread-safe, in-memory key–value store** that supports concurrent access by many threads. The store must allow:

* Concurrent reads and writes
* Safe deletion
* Blocking reads that wait until a key becomes available

The emphasis of this project is **correct synchronization**, **shared-state invariants**, and **clean C++ design**, not performance micro-optimizations or external libraries.

---

## 2. Functional Requirements

Your key–value store maps string keys to string values.

### Required operations

```cpp
class ConcurrentKVStore {
public:
    ConcurrentKVStore(size_t num_buckets);

    void put(const std::string& key, const std::string& value);
    bool get(const std::string& key, std::string& out);
    void erase(const std::string& key);

    // Blocks until the key exists, then returns its value
    std::string wait_and_get(const std::string& key);
};
```

---

## 3. Semantics of Operations

### 3.1 `put(key, value)`

* Inserts the key if it does not exist.
* Overwrites the existing value if the key already exists.
* Wakes up any threads blocked in `wait_and_get(key)`.

### 3.2 `get(key, out)`

* If the key exists:

  * Stores the value in `out`
  * Returns `true`
* If the key does not exist:

  * Leaves `out` unmodified
  * Returns `false`
* Must not block.

### 3.3 `erase(key)`

* Removes the key if it exists.
* Does nothing if the key does not exist.
* Must not deadlock or corrupt internal state.

### 3.4 `wait_and_get(key)`

* If the key exists, returns its value immediately.
* If the key does not exist:

  * Blocks until another thread inserts the key
  * Then returns the value
* Must handle spurious wakeups correctly.

---

## 4. Concurrency Requirements

### 4.1 Thread Safety

* All public methods must be safe to call concurrently.
* Any number of threads may call any combination of methods at any time.

### 4.2 No Busy Waiting

* Blocking must be implemented using **condition variables**, not spin loops or sleeps.

### 4.3 Correct Condition Variable Usage

* All waits must:

  * Occur while holding the appropriate mutex
  * Be guarded by a `while` loop checking a predicate
* No signaling inside a waiting loop.

---

## 5. Data Structure Design Constraints

### 5.1 Bucketing

* The store must be implemented using **N buckets**, where:

  * Each bucket has its own mutex
  * Each bucket stores a subset of keys
* The bucket index is determined by hashing the key.

```cpp
bucket_index = hash(key) % num_buckets;
```

---

### 5.2 Bucket Structure

Each bucket must contain:

* A `std::unordered_map<std::string, std::string>`
* A mutex protecting the map
* A condition variable used to wake waiting threads

You may define a struct such as:

```cpp
struct Bucket {
    mutex m;
    cv cv;
    std::unordered_map<std::string, std::string> data;
};
```

---

## 6. Invariants (You Must Maintain These)

At all times:

1. No two threads may modify the same bucket concurrently.
2. A thread waiting on a key must hold the mutex protecting that key’s bucket.
3. A waiting thread must not miss a wakeup when its key is inserted.
4. No deadlocks, regardless of thread interleaving.
5. No data races or undefined behavior.

Violating any invariant is considered incorrect.

---

## 7. Blocking Semantics (Critical Section)

`wait_and_get` must obey this pattern:

```cpp
lock bucket.m
while key not present:
    bucket.cv.wait(bucket.m)
read value
unlock bucket.m
```

You must reason carefully about **when** to signal or broadcast.

---

## 8. Performance Constraints (Reasonable, Not Extreme)

* Reads to different buckets must proceed in parallel.
* Writes to different buckets must proceed in parallel.
* You may use `signal` or `broadcast`, but you must justify your choice.

---

## 9. Disallowed Techniques

* Busy waiting (`while(true) {}` loops)
* Sleeping to avoid races
* Global locks for all operations
* Using C++ standard threading primitives
* Assuming scheduling order

---

## 10. Testing Requirements

You must write a test driver that:

* Spawns multiple threads performing random operations
* Includes:

  * Concurrent puts to same and different keys
  * Concurrent erases
  * Threads blocking on `wait_and_get`
* Verifies:

  * No deadlocks
  * No missed wakeups
  * Correct values returned

At least one test must intentionally:

* Start `wait_and_get` **before** the key is inserted
* Insert the key from another thread later

---

## 11. Debugging & Validation

You are strongly encouraged to:

* Compile with:

  ```bash
  -fsanitize=thread,address,undefined
  ```
* Use assertions to enforce invariants.
* Log thread actions (with proper synchronization).

