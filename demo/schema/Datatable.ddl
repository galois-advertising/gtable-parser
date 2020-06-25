{$
#include <iostream>
#include <vector>
$}

handlername = demo;
namespace = galois::user;

create datasource Empty1
{
};

create datasource Empty2
{
    property {
    };
};

create datasource UserSource
{
    property {
        type = databus;
        protourl = ssh://git@github.com/galois-advertising/common/master/databus.proto:90000;
    };
};

create dataview EmptyUserView on UserSource::UserTable {
};

// dataview
create dataview UserView on UserSource::UserTable {
    property {
        udf = UserViewUDF;
    };
    user_id : uint64;
    adx_id : uint64;
    wise_vectors : array char[Constant::MAX_BUF_LEN], opt;
    pc_vectors : array char[Constant::MAX_BUF_LEN], opt;

    derivative {
        usr_id_2 : uint32, from(user_id, adx_id), del;
        black_wd : array uint64[Constant::MAX_BLACK_WORD_NUM], from(adx_id);
    };
};

create datatable UserTableEmpty1 {
};

create datatable UserTableEmpty2 {
    property {
    };
};

create datatable UserTableEmpty3 {
    property {
        type = HashTable;
    };
};

create datatable UserTable4 {
    property {
        type = HashTable;
    };
    usr_id_1 : uint8, opt;
};

create datatable UserTable5 {
    property {
        type = HashTable;
    };
    usr_id_1 : uint8, opt;
    (usr_id_10,usr_id_9) : uint64key, primary_key;
};

// UserTable
create datatable UserTable6 {
    property {
        type = HashTable;
        hash_ratio = 0.5; //asdfasdf
        //asdfasdfasdf
    };

    usr_id_1 : uint8, range(1,2,3,4,5), opt;
    usr_id_2 : uint16, opt;
    usr_id_3 : uint32, del;
    usr_id_4 : array uint64 [10u];
    usr_id_5 : array bool[MAX_LEN];
    usr_id_6 : array char[12u];
    usr_id_7 : int, default(11);
    usr_id_8 : long, as(uid8);
    usr_id_9 : float, custom;
    usr_id_10 : binary;
    (usr_id_10,usr_id_9) : uint64key, primary_key;
    @Galois Advertising Framework; 
    @solopointer;
};

create default dataupdator UserView -> UserTable {};

create default indexupdator UserTable -> UserIndex {};
