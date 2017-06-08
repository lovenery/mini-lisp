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
int table_index = 0;
struct table {
    char *type;
    char *name;
    int value;
} table[100];
int searchTable (char* s) {
    int i;
    for (i = 0; i < table_index; i++) {
        if (strcmp(table[i].name, s) == 0) {
            return table[i].value;
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
} *root;
struct Node *newNode(struct Node *npLeft, struct Node *npRight, int num, char d) {
    struct Node *np = (struct Node *) malloc( sizeof(struct Node) );
    np->num = num;
    np->data = d;
    np->left = npLeft;
    np->right = npRight;
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
    if (np->right != NULL) {
        printf("Right is %c: %d\n", np->right->data, np->right->num);
    }
    if (np->mid != NULL) {
        printf("Mid is %c: %d\n", np->mid->data, np->mid->num);
    }
    if (np->left != NULL) {
        printf("Left is %c: %d\n", np->left->data, np->left->num);
    }
    printf("Sign: %c (%d)\n", np->data, np->num);
}
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
            // store Table value
            table[table_index].name = np->left->name;
            table[table_index].value = np->right->num;
            // printf("//Define: %s is %d;\n", table[table_index].name, table[table_index].value);
            table_index++;
            break;
        case 'V':
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = searchTable(np->name); // get Table value
            // printf("//Var %s: %d\n", np->name, np->num);
            break;
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
%}
%union {
    char *s;
    int f, b;
    struct Node *np;
}
%token print_num mod print_bool and or not _if _define
%token <f> number
%token <b> bool_val
%token <s> id
%type <np> PORGRAM STMT STMTS PRINT_STMT EXPS EXP NUM_OP LOG_OP
%type <np> IF_EXP TEST_EXP THEN_EXP ELSE_EXP
%type <np> DEF_STMT VARIABLE
%%


PORGRAM         :   STMTS                   { root = $1; }
STMTS           :   STMT STMTS              { $$ = newNode($1, $2, 0, 'A'); }
                |   STMT                    { $$ = $1; }
                ;

STMT            :   EXP                     { $$ = $1; }
                |   PRINT_STMT              { $$ = $1; }
                |   DEF_STMT                { $$ = $1; }
                ;

PRINT_STMT      :   '(' print_num EXP ')'   { $$ = newNode($3, NULL, $3->num, 'N'); }
                |   '(' print_bool EXP ')'  { $$ = newNode($3, NULL, $3->num, 'B'); }
                ;

EXPS            :   EXP EXPS                { $$ = newNode($1, $2, 0, 'E'); }
                |   EXP                     { $$ = $1; }
                ;

EXP             :   number                  { $$ = newNode(NULL, NULL, $1, 'n'); }
                |   bool_val                { $$ = newNode(NULL, NULL, $1, 'b'); }
                |   NUM_OP                  { $$ = $1; }
                |   LOG_OP                  { $$ = $1; }
                |   IF_EXP                  { $$ = $1; }
                |   VARIABLE                { $$ = $1; }
                ;

NUM_OP          :   '(' '+' EXPS ')'        { $$ = newNode($3, NULL, 0, '+'); }
                |   '(' '-' EXP EXP  ')'    { $$ = newNode($3, $4, 0, '-'); }
                |   '(' '*' EXPS ')'        { $$ = newNode($3, NULL, 0, '*'); }
                |   '(' '/' EXP EXP  ')'    { $$ = newNode($3, $4, 0, '/'); }
                |   '(' mod EXP EXP  ')'    { $$ = newNode($3, $4, 0, '%'); }
                |   '(' '>' EXP EXP  ')'    { $$ = newNode($3, $4, 0, '>'); }
                |   '(' '<' EXP EXP  ')'    { $$ = newNode($3, $4, 0, '<'); }
                |   '(' '=' EXPS ')'        { $$ = newNode($3, NULL, 0, '='); }
                ;

LOG_OP          :   '(' and EXP EXPS ')'    { $$ = newNode($3, $4, 0, '&'); }
                |   '(' or EXP EXPS ')'     { $$ = newNode($3, $4, 0, '|'); }
                |   '(' not EXP ')'         { $$ = newNode($3, NULL, 0, '~'); }
                ;

DEF_STMT        :   '(' _define VARIABLE EXP ')'    { $$ = newNode($3, $4, 0, 'D'); }
                ;
VARIABLE        :   id                              { $$ = newNode(NULL, NULL, 0, 'V'); $$->name = $1; }
                ;

IF_EXP          :   '(' _if TEST_EXP THEN_EXP ELSE_EXP ')' { $$ = newNode($3, $5, 0, '?'); $$->mid = $4; }
                ;
TEST_EXP        :   EXP                     { $$ = $1; }
                ;
THEN_EXP        :   EXP                     { $$ = $1; }
                ;
ELSE_EXP        :   EXP                     { $$ = $1; }
                ;


%%
int main(int argc, char *argv[]) {
    yyin = fopen(argv[1], "r");
    int a = yyparse();
    fclose(yyin);

    // if(a == 0) {
        traverseAST(root);
        printAnswer(root);
        freeAST(root);
        // printf("???????\n");
    // } else {
    //     /* yyerror() */
    // }

    return 0;
}
