%module example

%begin %{
#ifdef _MSC_VER
#define SWIG_PYTHON_INTERPRETER_NO_DEBUG
#endif
%}

%include "typemaps.i"
%include "std_vector.i"


%{
/* Put headers and other declarations here */
//extern int    fact(int);
//extern int    my_mod(int n, int m);
#include "example.h"
using namespace Wrapper;

%}

%include "example.h"
//extern int    fact(int);
//extern int    my_mod(int n, int m);