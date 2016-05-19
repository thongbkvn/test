#!/bin/bash
bison -vd MiniJava.y;
g++ -c MiniJava.tab.c;
flex MiniJava.lex;
g++ -c lex.yy.c;
g++ -c FieldType.h FieldType.cpp;
g++ -c FieldInfo.h FieldInfo.cpp;
g++ -c MethodInfo.h MethodInfo.cpp;
g++ -c ClassInfo.h ClassInfo.cpp;

g++ *.o -o MiniJava;
