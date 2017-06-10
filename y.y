%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
// #include "ast.h"
extern int yylex(void);
extern void yyerror(char *);
extern FILE * yyin;

// global variables
int var_table_index = 0;
struct Table {
    char *type;
    char *name;
    int value;
    int inFun;
} var_table[100];
int searchTable (char* s, int inFun) {
    int i;
    for (i = 0; i < var_table_index; i++) {
        if (var_table[i].inFun == inFun && strcmp(var_table[i].name, s) == 0) {
            return var_table[i].value;
        }
    }
    return -1;
    // printf("Undefined Variable: %s\n", s);
}
int sum = 0;
int equal_number = 0;
struct Node {
    char data; // n: num, b: bool, N: print n, B: print b, A: AST, E: EXPS, D: define, V: VARIABLE
    struct Node *left, *right, *mid;
    int num;
    char* name;
    int inFun;
} *root;
struct Node *newNode(struct Node *npLeft, struct Node *npRight, int num, char d) {
    struct Node *np = (struct Node *) malloc( sizeof(struct Node) );
    np->num = num;
    np->data = d;
    np->left = npLeft;
    np->right = npRight;
    np->name = "";
    np->inFun = 0;
    return np;
}

int adder (struct Node *np) {
    if (np->left != NULL) {
        sum += np->left->num;
        if (np->left->data == 'E' || np->left->data == 'n') {
            adder(np->left);
        }
    }
    if (np->right != NULL) {
        sum += np->right->num;
        if (np->right->data == 'E' || np->right->data == 'n') {
            adder(np->right);
        }
    }
    return sum;
}
int multiplier (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != 'E') {
            sum *= np->left->num;
        }
        if (np->left->data == 'E' || np->left->data == 'n') {
            multiplier(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != 'E') {
            sum *= np->right->num;
        }
        if (np->right->data == 'E' || np->right->data == 'n') {
            multiplier(np->right);
        }
    }
    return sum;
}
void set_equal_number (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != 'E') {
            equal_number = np->left->num;
        } else {
            set_equal_number(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != 'E') {
            equal_number = np->right->num;
        } else {
            set_equal_number(np->right);
        }
    }
}
int equaler (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != 'E') {
            sum = (np->left->num == equal_number) ? sum : 0;
        } else {
            // if (np->left->data == 'E' || np->left->data == 'n')
            equaler(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != 'E') {
            sum = (np->right->num == equal_number) ? sum : 0;
        } else {
            equaler(np->right);
        }
    }
    return sum;
}
int ander (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != 'E') {
            sum = sum & np->left->num;
        }
        if (np->left->data == 'E' || np->left->data == 'b') {
            ander(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != 'E') {
            sum = sum & np->right->num;
        }
        if (np->right->data == 'E' || np->right->data == 'b') {
            ander(np->right);
        }
    }
    return sum;
}
int orer (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != 'E') {
            sum = sum | np->left->num;
        }
        if (np->left->data == 'E' || np->left->data == 'b') {
            orer(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != 'E') {
            sum = sum | np->right->num;
        }
        if (np->right->data == 'E' || np->right->data == 'b') {
            orer(np->right);
        }
    }
    return sum;
}
void debugger (struct Node* np) {
    if (np->left != NULL) {
        printf("-- Left is %c: %d\n", np->left->data, np->left->num);
    }
    if (np->mid != NULL) {
        printf("-- Mid is %c: %d\n", np->mid->data, np->mid->num);
    }
    if (np->right != NULL) {
        printf("-- Right is %c: %d\n", np->right->data, np->right->num);
    }
    if (np->name != NULL && strcmp(np->name, "") != 0) {
        printf("Name is %s, ", np->name);
    }
    printf("Sign: %c (%d)\n", np->data, np->num);
}
int tmpTableIndex = 0;
struct Table tmp_table[100];
void storeParmsToTmpTable (struct Node * np) {
    if (np->left != NULL && np->left->data != 'F') {
        if (np->left->data == 'n') {
            tmp_table[tmpTableIndex++].value = np->left->num;
        }
        storeParmsToTmpTable(np->left);
    }
    if (np->right != NULL && np->right->data != 'F') {
        if (np->right->data == 'n') {
            tmp_table[tmpTableIndex++].value = np->right->num;
        }
        storeParmsToTmpTable(np->right);
    }
}
void bindParams (struct Node * np) {
    if (np->left != NULL) {
        if (np->left->data == 'V') {
            var_table[var_table_index].name = np->left->name;
            var_table[var_table_index].value = tmp_table[tmpTableIndex++].value;
            var_table[var_table_index].inFun = 1;
            // printf("hi? %s: %d\n", var_table[var_table_index].name, var_table[var_table_index].value);
            var_table_index++;
            np->left->inFun = 1;
        }
        bindParams(np->left);
    }
    if (np->right != NULL) {
        if (np->right->data == 'V') {
            var_table[var_table_index].name = np->right->name;
            var_table[var_table_index].value = tmp_table[tmpTableIndex++].value;
            var_table[var_table_index].inFun = 1;
            // printf("hi? %s: %d\n", var_table[var_table_index].name, var_table[var_table_index].value);
            var_table_index++;
            np->right->inFun = 1;
        }
        bindParams(np->right);
    }
}
struct Node *funNodes[100];
int funNodesIndex = 0;
void traverseAST(struct Node *np) {
    if (np == NULL) {
        return;
    }
    switch(np->data) {
        case 'n':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // printf("Integer Number (n): %d\n", np->num);
            break;
        case 'b':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // printf("Bool Number (n): %d\n", np->num);
            break;
        case '+':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            sum = 0;
            np->num = adder(np);
            // printf("+: %d\n", np->num);
            break;
        case '*':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            sum = 1;
            np->num = multiplier(np);
            // printf("*: %d\n", np->num);
            break;
        case '-':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num - np->right->num;
            // printf("-: %d\n", np->num);
            break;
        case '/':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num / np->right->num;
            // printf("/: %d\n", np->num);
            break;
        case '%':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num % np->right->num;
            // printf("%: %d\n", np->num);
            break;
        case '>':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num > np->right->num ? 1 : 0;
            // printf("%: %d\n", np->num);
            break;
        case '<':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num < np->right->num ? 1 : 0;
            // printf("%: %d\n", np->num);
            break;
        case '=':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            sum = 1; // assume all same at begining
            set_equal_number(np);
            np->num = equaler(np);
            // printf("equal_number: %d\n", equal_number);
            // printf("=: %d\n", np->num); 
            break;
        case '&':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            sum = 1;
            np->num = ander(np);
            // printf("&: %d\n", np->num); 
            break;
        case '|':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            sum = 0;
            np->num = orer(np);
            // printf("|: %d\n", np->num);
            break;
        case '~':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = ! np->left->num;
            // printf("~: %d\n", np->num);
            break;
        case 'N':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num;
            // printf("N: %d\n", np->num);
            break;
        case 'B':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num;
            // printf("B: %d\n", np->num);
            break;
        case '?':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            if (np->left->num == 1) {
                np->num = np->mid->num;
            } else {
                np->num = np->right->num;
            }
            // printf("?: %d\n", np->num);
            break;
        case 'D':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // Function but no params
            if (np->right->data == 'F' && np->right->left->data == 'X') {
                var_table[var_table_index].name = np->left->name; // V
                var_table[var_table_index].value = np->right->right->num; // EXP
                var_table_index++;
            } else if (np->right->data == 'F') { // normal function
                funNodes[funNodesIndex++] = np;
                // printf("// Define Function: %s\n", funNodes[funNodesIndex-1]->left->name);
            } else { // normal variable
                // store Table value
                var_table[var_table_index].name = np->left->name;
                var_table[var_table_index].value = np->right->num;
                // printf("//Define: %s is %d;\n", var_table[var_table_index].name, var_table[var_table_index].value);
                var_table_index++;
            }
            break;
        case 'V':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = searchTable(np->name, np->inFun); // get Table value
            // printf("//Var %s: %d\n", np->name, np->num);
            break;
        case 'F':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // params: np->left->name;
            // exprs: np->right;
            break;
        case 'c':
            tmpTableIndex = 0; // init
            storeParmsToTmpTable(np);
            int hoisting = tmpTableIndex;
            tmpTableIndex = 0; // init
            bindParams(np); // bind variables before travel childs
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            var_table_index -= hoisting; // after travel, remove binding prevent hoisting
            if (np->left->right == NULL) {
                printf("GG lemon\n");
            }
            np->num = np->left->right->num;
            break;
        case 'C': {
            // pass function to be a param
            // np->left: f (X,X)
            // np->right: P
            // np->right->left: C // normal is P or n
            // np->right->right: X // normal is P or n
            // np->right->left->left: f
            // np->right->left->right: X
            if (np->right->left->data == 'C') {
                np->right->left->data = 'n'; // Change 'C' to 'n', not Call anymore
                np->right->left->num = searchTable(np->right->left->left->name, 0);
            }
            // ---------------------------------
            // normal pass parms
            int i;
            int tmp = 0;
            for(i = 0; i < funNodesIndex; i++) {
                if (np->left->name == funNodes[i]->name) {
                    tmp = i;
                }
            }
            // printf("// Call Function: %s \n", funNodes[tmp]->left->name);
            tmpTableIndex = 0; // init
            storeParmsToTmpTable(np->right); // P
            int hoisting = tmpTableIndex;
            tmpTableIndex = 0; // init
            bindParams(funNodes[tmp]->right); // bind variables before travel childs
            traverseAST(funNodes[tmp]->left);
            traverseAST(funNodes[tmp]->right);
            var_table_index -= hoisting; // after travel, remove binding prevent hoisting
            np->num = funNodes[tmp]->right->right->num;
            // no need to travel other nodes
            break;
        }
        default: // 'A', 'E'
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // printf("Sign: %c (%d)\n", np->data, np->num);
            break;
    }
    // debugger(np);
}
void freeAST(struct Node* np) { // free with postorder
    if (np != NULL) {
        freeAST(np->left);
        freeAST(np->right);
        free(np);
    }
}
void printAnswer(struct Node *np) {
    if (np == NULL) return;
    switch(np->data) {
        case 'N':
            printAnswer(np->left);
            printAnswer(np->right);
            printf("%d\n", np->num);
            break;
        case 'B':
            printAnswer(np->left);
            printAnswer(np->right);
            if (np->num) {
                printf("#t\n");
            } else {
                printf("#f\n");
            }
            break;
        default:
            printAnswer(np->left);
            printAnswer(np->right);
            break;
    }
}

void TopDownDebugger(struct Node *np) {
    if (np == NULL) {
        return;
    }
    switch(np->data) {
        default:
            //printf("%c, %d\n", np->data, np->num);
            if (np->name != NULL && strcmp(np->name, "") != 0) {
                printf("Name is %s, ", np->name);
            }
            printf("Sign: %c (%d)\n", np->data, np->num);
            if (np->left != NULL) {
                printf("-- Left is %c: %d\n", np->left->data, np->left->num);
            }
            if (np->mid != NULL) {
                printf("-- Mid is %c: %d\n", np->mid->data, np->mid->num);
            }
            if (np->right != NULL) {
                printf("-- Right is %c: %d\n", np->right->data, np->right->num);
            }
            printf("------------\n");
            TopDownDebugger(np->left);
            TopDownDebugger(np->right);
            break;
    }
}
%}
%union {
    char *s;
    int f, b;
    struct Node *np;
}
%token print_num mod print_bool and or not _if _define fun
%token <f> number
%token <b> bool_val
%token <s> id
%type <np> PORGRAM STMT STMTS PRINT_STMT EXPS EXP NUM_OP LOG_OP
%type <np> IF_EXP TEST_EXP THEN_EXP ELSE_EXP
%type <np> DEF_STMT VARIABLE
%type <np> FUN_EXP FUN_IDs FUN_BODY FUN_CALL PARAMS PARAM FUN_NAME VARIABLES
%%


PORGRAM         :   STMTS                                   { root = $1; }
                ;
STMTS           :   STMT STMTS                              { $$ = newNode($1, $2, 0, 'A'); }
                |   STMT                                    { $$ = $1; }
                ;

STMT            :   EXP                                     { $$ = $1; }
                |   PRINT_STMT                              { $$ = $1; }
                |   DEF_STMT                                { $$ = $1; }
                ;

PRINT_STMT      :   '(' print_num EXP ')'                   { $$ = newNode($3, NULL, $3->num, 'N'); }
                |   '(' print_bool EXP ')'                  { $$ = newNode($3, NULL, $3->num, 'B'); }
                ;

EXPS            :   EXP EXPS                                { $$ = newNode($1, $2, 0, 'E'); }
                |   EXP                                     { $$ = $1; }
                ;
EXP             :   number                                  { $$ = newNode(NULL, NULL, $1, 'n'); }
                |   bool_val                                { $$ = newNode(NULL, NULL, $1, 'b'); }
                |   NUM_OP                                  { $$ = $1; }
                |   LOG_OP                                  { $$ = $1; }
                |   IF_EXP                                  { $$ = $1; }
                |   VARIABLE                                { $$ = $1; }
                |   FUN_EXP                                 { $$ = $1; }
                |   FUN_CALL                                { $$ = $1; }
                ;

NUM_OP          :   '(' '+' EXPS ')'                        { $$ = newNode($3, NULL, 0, '+'); }
                |   '(' '-' EXP EXP  ')'                    { $$ = newNode($3, $4, 0, '-'); }
                |   '(' '*' EXPS ')'                        { $$ = newNode($3, NULL, 0, '*'); }
                |   '(' '/' EXP EXP  ')'                    { $$ = newNode($3, $4, 0, '/'); }
                |   '(' mod EXP EXP  ')'                    { $$ = newNode($3, $4, 0, '%'); }
                |   '(' '>' EXP EXP  ')'                    { $$ = newNode($3, $4, 0, '>'); }
                |   '(' '<' EXP EXP  ')'                    { $$ = newNode($3, $4, 0, '<'); }
                |   '(' '=' EXPS ')'                        { $$ = newNode($3, NULL, 0, '='); }
                ;

LOG_OP          :   '(' and EXP EXPS ')'                    { $$ = newNode($3, $4, 0, '&'); }
                |   '(' or EXP EXPS ')'                     { $$ = newNode($3, $4, 0, '|'); }
                |   '(' not EXP ')'                         { $$ = newNode($3, NULL, 0, '~'); }
                ;

DEF_STMT        :   '(' _define VARIABLE EXP ')'            { $$ = newNode($3, $4, 0, 'D'); }
                ;
VARIABLE        :   id                                      { $$ = newNode(NULL, NULL, 0, 'V'); $$->name = $1; }
                ;

IF_EXP          :   '(' _if TEST_EXP THEN_EXP ELSE_EXP ')'  { $$ = newNode($3, $5, 0, '?'); $$->mid = $4; }
                ;
TEST_EXP        :   EXP                                     { $$ = $1; }
                ;
THEN_EXP        :   EXP                                     { $$ = $1; }
                ;
ELSE_EXP        :   EXP                                     { $$ = $1; }
                ;

FUN_EXP         :   '(' fun FUN_IDs FUN_BODY ')'            { $$ = newNode($3, $4, 0, 'F'); }
                ;
FUN_IDs         :   '(' VARIABLES ')'                       { $$ = $2; }
                ;
VARIABLES       :   VARIABLES VARIABLE                      { $$ = newNode($1, $2, 0, 'E'); }
                |   /* empty */                             { $$ = newNode(NULL, NULL, 0, 'X'); }
                ;

FUN_BODY        :   EXP                                     { $$ = $1; }
                ;

FUN_CALL        :   '(' FUN_EXP PARAMS ')'                  { $$ = newNode($2, $3, 0, 'c'); }
                |   '(' FUN_NAME PARAMS ')'                 { $$ = newNode($2, $3, 0, 'C'); }
                ;
PARAMS          :   PARAM PARAMS                            { $$ = newNode($1, $2, 0, 'P'); }
                |   /* empty */                             { $$ = newNode(NULL, NULL, 0, 'X'); }
                ;
PARAM           :   EXP                                     { $$ = $1; }
                ;
FUN_NAME        :   id                                      { $$ = newNode(NULL, NULL, 0, 'f'); $$->name = $1; }
                ;
%%
int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    int a = yyparse();
    fclose(yyin);

    // if(a == 0) {
    // TopDownDebugger(root);
        traverseAST(root);
        printAnswer(root);
        freeAST(root);
    // } else {
    //     /* yyerror() */
    // }

    // printf("\nVariables Table:\n");
    // int i;
    // for (i = 0; i < var_table_index; i++) {
    //     printf("%s: %d (in Function: %d)\n", var_table[i].name, var_table[i].value, var_table[i].inFun);
    // }

    return 0;
}
