#pragma once
#include <vector>
#if defined _WIN32 || defined __CYGWIN__
    #if defined BUILDING_CPPEX
        #define CPPEX_API __declspec(dllexport)
    #else
        #define CPPEX_API __declspec(dllimport)
    #endif

#elif defined(__GNUC__)
    //  GCC
    #define CPPEX_API __attribute__((visibility("default")))
#else
    #define CPPEX_API
    #pragma warning Unknown dynamic link import/export semantics.
#endif

namespace Wrapper {
    CPPEX_API int fact(int n);

    CPPEX_API int my_mod(int n, int m);

    CPPEX_API class mat2d{
        public:
        CPPEX_API mat2d(int h, int w): _height(h), _width(w) {

        }

        CPPEX_API const std::vector<int>& values() const{
            return _values;
        }

        CPPEX_API int height() { return _height;}
        CPPEX_API int width() {return _width;}

        private:
        int _height;
        int _width;
        std::vector<int> _values;
    };
}