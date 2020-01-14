%module example

%{
/* Put headers and other declarations here */
extern int    fact(int);
extern int    my_mod(int n, int m);
%}

extern int    fact(int);
extern int    my_mod(int n, int m);