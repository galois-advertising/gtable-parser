#pragma once
#include <string>
// solopointer1202@gmail.com
// 20191208
typedef int (*yyinput_func_t)(void *);
int process_comment(void * yyscanner, yyinput_func_t);
int strip_before(void * yyscanner, yyinput_func_t, const char* signs);
int fill_buffer(void * yyscanner, yyinput_func_t, char * buffer, int buf_size, const char * signs);

class Node {
public:
    Node();
    Node(const Node & node);
    virtual ~Node();
    const char * data() const;
    std::string & mutable_data();
    void set_data(const char * data);
    void set_data(const std::string & data);
private:
    std::string m_data;
};

#define MEMBER_DEF(type, member) \
    public: \
        void set_##member(type * member) { \
            assert(member != nullptr); \
            m_##member = member; \
        } \
        const type & member() const { \
            return *m_##member; \
        } \
        type & member() { \
            return *m_##member; \
        } \
    private: \
        type * m_##member; \

#define LIST_MEMBER_DEF(type, member_name) \
    public: \
        void set_##member_name(type##List *member_name) { \
            assert(member_name); \
            m_##member_name = member_name; \
        } \
        std::list<type*> & mutable_##member_name() { \
            assert(m_##member_name); \
            return *m_##member_name; \
        } \
        void append_##member_name(type * member) { \
            assert(member); \
            m_##member_name->push_back(member); \
        } \
        const std::list<type*> & member_name() const { \
            assert(m_##member_name); \
            return *m_##member_name; \
        } \
        bool has_##member_name() const { \
            return m_##member_name != nullptr; \
        } \
    private: \
        std::list<type*> * m_##member_name; \

#define NODE_MEMBER_DEF(member_name) \
    public: \
        void set_##member_name(Node * member_name) { \
            assert(member_name != nullptr); \
            m_##member_name = member_name; \
        } \
        const char* member_name() const { \
            if (m_##member_name == nullptr) {\
                return nullptr; \
            }\
            return m_##member_name->data(); \
        } \
        const char* member_name##_value() const { \
            assert(m_##member_name); \
            return m_##member_name->data(); \
        } \
        bool has_##member_name() const { \
            return m_##member_name != nullptr; \
        } \
    private: \
        Node * m_##member_name; \

#define FACTORY_WITH_NO_PARAMS(type, name) \
    type * new_##name() { \
        auto tmp = std::make_shared<type>(); \
        this->m_mempool.push_back(std::any(tmp)); \
        return tmp.get(); \
    }

#define FACTORY_WITH_PARAMS(type, name, params_type) \
    type * new_##name(params_type params_name) { \
        auto tmp = std::make_shared<type>(*params_name); \
        this->m_mempool.push_back(std::any(tmp)); \
        return tmp.get(); \
    }
