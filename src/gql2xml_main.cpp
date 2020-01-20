/*******************************************
 * solopointer(solopointer1202@gmail.com)
 * 2019.10.13
*******************************************/

#include <string>
#include <iostream>
#include <memory>
#include "config.h"
#include "gql2xml_xml_generator.h"


int main(int argc, char* argv[]) {
    gql2xml g2x;
    std::string file_name;
    if (argc == 2) {
        file_name = argv[1];
    } else {
        std::cout <<argv[0]<<" v"<<DEFINE_VAR1<<"."<<DEFINE_VAR2
        <<" "<<__DATE__<<" "<<__TIME__<< std::endl;
        std::cout << "Usage: " <<argv[0]<<" file.gql"<< std::endl;
        return -1;
    }
    int ret = g2x.load_from_file(file_name);
    std::cout<<"load file ["<<file_name<<"] succee."<<std::endl;
    gql_xml_generator generator(g2x);
    generator.write_to_file((file_name + ".xml").c_str());
    return ret;
}
