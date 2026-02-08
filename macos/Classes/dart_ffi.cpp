#include "mecab.h"
#include <vector>
#include <string>
#include <cstring>
#include <cstdio>
#include <cstdlib>
#include <map>
#include <mutex>
#include <iostream> 

// Holds a pointer to the heavyweight Dictionary Model and its active reference count.
struct ModelEntry {
    mecab_model_t* model;
    int refCount;
};

// Maps a unique key ("lib|dict") to a shared ModelEntry.
static std::map<std::string, ModelEntry> model_registry;

// Maps a specific Tagger instance back to its Model key.
// Essential for identifying which Model to decrement when a Tagger is destroyed.
static std::map<void*, std::string> tagger_registry;

static std::mutex registry_mutex;

// Generates the registry key: "libpath|dicdir"
std::string get_registry_key(const char* dicdir, const char* libpath) {
    return std::string(libpath ? libpath : "default") + "|" + std::string(dicdir);
}

// Parses options string. Returns vector<string> by value to ensure 
// string data remains allocated during the scope of initMecab.
std::vector<std::string> generateArgs(const std::string& opt, const std::string& dicdir) {
    std::string rcfile = dicdir + "/mecabrc";
    std::vector<std::string> args = {"mecab", "-d", dicdir, "-r", rcfile};

    std::string token;
    bool inQuotes = false;
    for (char ch : opt) {
        if (ch == '"') { inQuotes = !inQuotes; }
        else if (ch == ' ' && !inQuotes) {
            if (!token.empty()) { args.push_back(token); token.clear(); }
        } else { token += ch; }
    }
    if (!token.empty()) args.push_back(token);
    
    return args;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void* initMecab(const char* opt, const char* dicdir, const char* libpath) {
    std::lock_guard<std::mutex> lock(registry_mutex);
    
    std::string key = get_registry_key(dicdir, libpath);
    mecab_model_t* model = nullptr;

    // Check if a model for this dictionary already exists
    auto it = model_registry.find(key);
    if (it != model_registry.end()) {
        // Reuse existing model, increment ref count
        it->second.refCount++;
        model = it->second.model;
    }
    else {
        // Initialize new model. 
        // stringArgs must be kept alive while argv pointers are being read by mecab_model_new.
        std::vector<std::string> stringArgs = generateArgs(opt ? opt : "", dicdir);
        
        std::vector<char*> argv;
        for (const auto& s : stringArgs) {
            argv.push_back(const_cast<char*>(s.c_str()));
        }

        model = mecab_model_new(argv.size(), argv.data());
        
        if (model) {
            model_registry[key] = { model, 1 };
        } else {
            fprintf(stderr, "[Mecab-Dart] Failed to initialize model. DicDir: %s\n", dicdir);
            return nullptr;
        }
    }

    if (!model) return nullptr;

    // Create a lightweight Tagger linked to the shared Model
    mecab_t* tagger = mecab_model_new_tagger(model);
    
    if (tagger) {
        // Map this Tagger to the Model key for future cleanup
        tagger_registry[(void*)tagger] = key;
    }

    return (void*)tagger;
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
void destroyMecab(void* tagger_ptr) {
    if (!tagger_ptr) return;

    std::lock_guard<std::mutex> lock(registry_mutex);

    // 1. Identify which Model this Tagger is using
    auto tagger_it = tagger_registry.find(tagger_ptr);
    if (tagger_it == tagger_registry.end()) {
        mecab_destroy((mecab_t*)tagger_ptr);
        return;
    }

    std::string key = tagger_it->second;

    // 2. Destroy the Tagger instance
    mecab_destroy((mecab_t*)tagger_ptr);
    tagger_registry.erase(tagger_it);

    // 3. Decrement Model reference count
    auto model_it = model_registry.find(key);
    if (model_it != model_registry.end()) {
        model_it->second.refCount--;
        
        // 4. If count hits 0, free the heavy dictionary memory
        if (model_it->second.refCount <= 0) {
            mecab_model_destroy(model_it->second.model);
            model_registry.erase(model_it);
        }
    }
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
const char* parse(void* tagger_ptr, const char* input) {
    if (!tagger_ptr) return "";
    return mecab_sparse_tostr((mecab_t*)tagger_ptr, input);
}

extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t native_add(int32_t x, int32_t y) {
    return x + y;
}