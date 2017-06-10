%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <ctype.h> // TODO: Type Checking
extern int yylex(void);
extern void yyerror(char *);
extern FILE * yyin;
#include "ast.h"
%}

%union {
    char *str;
    int ival, bval;
    struct Node *np;
}
%token print_num mod print_bool and or not _if _define fun
%token <ival> number
%token <bval> bool_val
%token <str> id
%type <np> PORGRAM STMT STMTS PRINT_STMT EXPS EXP NUM_OP LOG_OP
%type <np> IF_EXP TEST_EXP THEN_EXP ELSE_EXP
%type <np> DEF_STMT VARIABLE
%type <np> FUN_EXP FUN_IDs FUN_BODY FUN_CALL PARAMS PARAM FUN_NAME VARIABLES
%%
PORGRAM         :   STMTS                                   { root = $1; }
                ;
STMTS           :   STMT STMTS                              { $$ = newNode($1, $2, AST_STMTS); }
                |   STMT                                    { $$ = $1; }
                ;

STMT            :   EXP                                     { $$ = $1; }
                |   PRINT_STMT                              { $$ = $1; }
                |   DEF_STMT                                { $$ = $1; }
                ;

PRINT_STMT      :   '(' print_num EXP ')'                   { $$ = newNode($3, NULL, AST_PRINT_NUM); }
                |   '(' print_bool EXP ')'                  { $$ = newNode($3, NULL, AST_PRINT_BOOL); }
                ;

EXPS            :   EXP EXPS                                { $$ = newNode($1, $2, AST_EXPRS); }
                |   EXP                                     { $$ = $1; }
                ;
EXP             :   number                                  { $$ = newNode(NULL, NULL, AST_NUM); $$->num = $1; }
                |   bool_val                                { $$ = newNode(NULL, NULL, AST_BOOL); $$->num = $1; }
                |   NUM_OP                                  { $$ = $1; }
                |   LOG_OP                                  { $$ = $1; }
                |   IF_EXP                                  { $$ = $1; }
                |   VARIABLE                                { $$ = $1; }
                |   FUN_EXP                                 { $$ = $1; }
                |   FUN_CALL                                { $$ = $1; }
                ;

NUM_OP          :   '(' '+' EXPS ')'                        { $$ = newNode($3, NULL, '+'); }
                |   '(' '-' EXP EXP  ')'                    { $$ = newNode($3, $4, '-'); }
                |   '(' '*' EXPS ')'                        { $$ = newNode($3, NULL, '*'); }
                |   '(' '/' EXP EXP  ')'                    { $$ = newNode($3, $4, '/'); }
                |   '(' mod EXP EXP  ')'                    { $$ = newNode($3, $4, '%'); }
                |   '(' '>' EXP EXP  ')'                    { $$ = newNode($3, $4, '>'); }
                |   '(' '<' EXP EXP  ')'                    { $$ = newNode($3, $4, '<'); }
                |   '(' '=' EXPS ')'                        { $$ = newNode($3, NULL, '='); }
                ;

LOG_OP          :   '(' and EXP EXPS ')'                    { $$ = newNode($3, $4, '&'); }
                |   '(' or EXP EXPS ')'                     { $$ = newNode($3, $4, '|'); }
                |   '(' not EXP ')'                         { $$ = newNode($3, NULL, '~'); }
                ;

DEF_STMT        :   '(' _define VARIABLE EXP ')'            { $$ = newNode($3, $4, AST_DEFINE); }
                ;
VARIABLE        :   id                                      { $$ = newNode(NULL, NULL, AST_VAR); $$->name = $1; }
                ;

IF_EXP          :   '(' _if TEST_EXP THEN_EXP ELSE_EXP ')'  { $$ = newNode($3, $5, '?'); $$->mid = $4; }
                ;
TEST_EXP        :   EXP                                     { $$ = $1; }
                ;
THEN_EXP        :   EXP                                     { $$ = $1; }
                ;
ELSE_EXP        :   EXP                                     { $$ = $1; }
                ;

FUN_EXP         :   '(' fun FUN_IDs FUN_BODY ')'            { $$ = newNode($3, $4, AST_FUN); }
                ;
FUN_IDs         :   '(' VARIABLES ')'                       { $$ = $2; }
                ;
VARIABLES       :   VARIABLES VARIABLE                      { $$ = newNode($1, $2, AST_EXPRS); }
                |   /* empty */                             { $$ = newNode(NULL, NULL, AST_FUN_NULL); }
                ;

FUN_BODY        :   EXP                                     { $$ = $1; }
                ;

FUN_CALL        :   '(' FUN_EXP PARAMS ')'                  { $$ = newNode($2, $3, AST_CALL_ANONYMOUS); }
                |   '(' FUN_NAME PARAMS ')'                 { $$ = newNode($2, $3, AST_CALL_NAMED); }
                ;
PARAMS          :   PARAM PARAMS                            { $$ = newNode($1, $2, AST_EXPRS); }
                |   /* empty */                             { $$ = newNode(NULL, NULL, AST_FUN_NULL); }
                ;
PARAM           :   EXP                                     { $$ = $1; }
                ;
FUN_NAME        :   id                                      { $$ = newNode(NULL, NULL, AST_FUN_NAME); $$->name = $1; }
                ;
%%

int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    int a = yyparse();
    fclose(yyin);

    if(a == 0) {
        // TopDownDebugger(root);
        traverseAST(root);
        printAnswer(root);
        freeAST(root);
    } else {
        /* yyerror() */
    }

    // printf("\nVariables Table:\n");
    // int i;
    // for (i = 0; i < var_table_index; i++) {
    //     printf("%s: %d (in Function: %d)\n", var_table[i].name, var_table[i].value, var_table[i].inFun);
    // }

    return 0;
}
