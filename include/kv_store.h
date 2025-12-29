#ifndef KV_STORE
#define KV_STORE

#include <string>

class ConcurrentKVStore {
public:
    void put(std::string key, std::string value);
    bool get(std::string key, std::string& out);
    void erase(std::string key);
    std::string wait_and_get(std::string key);
};



#endif
