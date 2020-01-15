%module example

%begin %{
#ifdef _MSC_VER
#define SWIG_PYTHON_INTERPRETER_NO_DEBUG
#endif
%}

%{
/* Put headers and other declarations here */
extern int    fact(int);
extern int    my_mod(int n, int m);
%}

extern int    fact(int);
extern int    my_mod(int n, int m);