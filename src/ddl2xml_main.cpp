/*******************************************
 * solopointer(solopointer1202@gmail.com)
 * 2019.10.13
*******************************************/

#include <string>
#include <iostream>
#include <memory>
#include "config.h"
#include "ddl2xml_xml_generator.h"


int main(int argc, char* argv[]) {
    ddl2xml d2x;
    std::string file_name;
    if (argc == 2) {
        file_name = argv[1];
    } else {
        std::cout <<argv[0]<<" v"<<DEFINE_VAR1<<"."<<DEFINE_VAR2<< std::endl;
        std::cout << "Usage: " <<argv[0]<<" file.def"<< std::endl;
        return -1;
    }
    int ret = d2x.load_from_file(file_name);
    std::cout<<"load file ["<<file_name<<"] succee."<<std::endl;
    std::shared_ptr<ddl_xml_generator> generator(new ddl_xml_generator(d2x));
    generator->write_to_file((file_name + ".xml").c_str());
    return ret;
}
