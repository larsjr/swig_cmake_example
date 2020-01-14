#pragma once

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


CPPEX_API int fact(int n);

CPPEX_API int my_mod(int n, int m);