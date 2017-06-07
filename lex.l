%{
#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
%}

%option noyywrap

separator   [ \t\n\r]
letter      [a-z]
digit       [0-9]
number      0|[1-9]{digit}*|-[1-9]{digit}*
ID          {letter}({letter}|{digit}|'-')*
bool_val    #[t|f]
%%
<<EOF>>         { return 0; }
{separator}*    { /* do nothing */ }
"print-num"     { return print_num; }
"print-bool"    { return print_bool; }
{number}        { yylval.f = atoi(yytext); return number; }
{bool_val}      { yylval.b = (yytext[1] == 't') ? 1 : 0 ; return bool_val; }
[()\+\-*/><=]   { return yytext[0]; }
"mod"           { return mod; }
"and"           { return and; }
"or"            { return or; }
"not"           { return not; }
"if"            { return _if; }
.               { printf("unexpected char: %s\n", yytext); }
%%

void yyerror(char *msg) {
    printf("%s\n", msg);
    // printf("line number: %d, msg: %s, char: %s\n", yylineno, msg, yytext );
}