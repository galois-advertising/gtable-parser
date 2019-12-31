#include "parser-common.h"
#include <string.h>
#include <assert.h>

int fill_buffer(void * yyscanner, yyinput_func_t yyinput, char * buffer, int buf_len, const char * stop_signs) {
    char ch = 0;
    int idx = 0;
    int stop_signs_num = strlen(stop_signs);
    int i = 0;

    while (true) {
        ch = yyinput(yyscanner);

        for (; i < stop_signs_num; i++) {
            char sign = stop_signs[i];
            if (ch == sign) {
                buffer[idx++] = ch;
                ch = yyinput(yyscanner);
            }
            else {
                break;
            }
        }

        if (i == stop_signs_num) {
            idx -= stop_signs_num;
            buffer[idx] = '\0';
            return 0;
        }

        if (idx == buf_len - 1 - stop_signs_num || ch == EOF) {
            return -1;
        }

        buffer[idx++] = ch;
    }

    return 0;
}

int strip_before(void * yyscanner, yyinput_func_t yyinput, const char * signs) {
    char in_char = 0;
    while (true) {
        in_char = yyinput(yyscanner);
        for (size_t i = 0; i < strlen(signs); i++) {
            char sign = signs[i];
            if (in_char == sign) {
                return 0;
            } 
        }
        
        if (in_char == EOF) {
            return -1;
        }
    }
}

int process_comment(void * yyscanner, yyinput_func_t yyinput)
{
    strip_before(yyscanner, yyinput, "\n");
    return 0;
}

    
Node::Node() : m_data("") {}

Node::Node(const Node & node) : m_data(node.m_data) {}

Node::~Node() {}

void Node::set_data(const char * data) {
    assert(data != nullptr);
    m_data = std::string(data);
}
void Node::set_data(const std::string & data){
    m_data = data;
}

const char * Node::data() const {
    return m_data.c_str();
}

std::string & Node::mutable_data() {
    return m_data;
}
