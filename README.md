# Multi-Threaded In-Memory Key-Value Store

A thread-safe in-memory hash table that supports concurrent:
reads
writes
deletes
blocking reads (“wait until key exists”)

```
class ConcurrentKVStore {
public:
    void put(std::string key, std::string value);
    bool get(std::string key, std::string& out);
    void erase(std::string key);

    // Blocks until key exists
    std::string wait_and_get(std::string key);
};
```





