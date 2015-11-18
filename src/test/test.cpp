#include <iostream>
#include "util/tc_option.h"

using namespace Haf;

int main(int argc, char *argv[])
{
    TC_Option opt;
    opt.decode(argc, argv);
    map<string, string> & mapOption = opt.getMulti();
    vector<string> & vSingle = opt.getSingle();

    map<string, string>::iterator itr = mapOption.begin();
    for (; itr != mapOption.end(); ++itr)
    {
        std::cout << itr->first << ":" << itr->second << endl;
    }

    for (size_t i = 0; i < vSingle.size(); ++i)
    {
        cout << vSingle[i] << endl;
    }

    return 0;
    
}
