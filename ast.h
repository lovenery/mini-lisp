// Nodes
#define AST_STMTS 'A'
#define AST_NUM 'n'
#define AST_BOOL 'b'
#define AST_EXPRS 'E'
#define AST_PRINT_NUM 'N'
#define AST_PRINT_BOOL 'B'
#define AST_DEFINE 'D'
#define AST_VAR 'V'
#define AST_FUN 'F'
#define AST_FUN_NAME 'f'
#define AST_FUN_NULL 'X'
#define AST_CALL_ANONYMOUS 'c'
#define AST_CALL_NAMED 'C'
struct Node {
    char data; // n: num, b: bool, N: print n, B: print b, A: AST, E: EXPS, D: define, V: VARIABLE
    struct Node *left, *right, *mid;
    int num;
    char* name;
    int inFun;
};
struct Node *root;
int funNodesIndex = 0;
struct Node *funNodes[100]; // store functions node
struct Node *newNode(struct Node *npLeft, struct Node *npRight, char d) {
    struct Node *np = (struct Node *) malloc( sizeof(struct Node) );
    np->num = 0;
    np->data = d;
    np->left = npLeft;
    np->right = npRight;
    np->name = "";
    np->inFun = 0;
    return np;
}

// Operations
int sum = 0;
int equal_number = 0;
int adder (struct Node *np) {
    if (np->left != NULL) {
        sum += np->left->num;
        if (np->left->data == AST_EXPRS || np->left->data == AST_NUM) {
            adder(np->left);
        }
    }
    if (np->right != NULL) {
        sum += np->right->num;
        if (np->right->data == AST_EXPRS || np->right->data == AST_NUM) {
            adder(np->right);
        }
    }
    return sum;
}
int multiplier (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != AST_EXPRS) {
            sum *= np->left->num;
        }
        if (np->left->data == AST_EXPRS || np->left->data == AST_NUM) {
            multiplier(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != AST_EXPRS) {
            sum *= np->right->num;
        }
        if (np->right->data == AST_EXPRS || np->right->data == AST_NUM) {
            multiplier(np->right);
        }
    }
    return sum;
}
void set_equal_number (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != AST_EXPRS) {
            equal_number = np->left->num;
        } else {
            set_equal_number(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != AST_EXPRS) {
            equal_number = np->right->num;
        } else {
            set_equal_number(np->right);
        }
    }
}
int equaler (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != AST_EXPRS) {
            sum = (np->left->num == equal_number) ? sum : 0;
        } else {
            // if (np->left->data == AST_EXPRS || np->left->data == AST_NUM)
            equaler(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != AST_EXPRS) {
            sum = (np->right->num == equal_number) ? sum : 0;
        } else {
            equaler(np->right);
        }
    }
    return sum;
}
int ander (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != AST_EXPRS) {
            sum = sum & np->left->num;
        }
        if (np->left->data == AST_EXPRS || np->left->data == AST_BOOL) {
            ander(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != AST_EXPRS) {
            sum = sum & np->right->num;
        }
        if (np->right->data == AST_EXPRS || np->right->data == AST_BOOL) {
            ander(np->right);
        }
    }
    return sum;
}
int orer (struct Node *np) {
    if (np->left != NULL) {
        if (np->left->data != AST_EXPRS) {
            sum = sum | np->left->num;
        }
        if (np->left->data == AST_EXPRS || np->left->data == AST_BOOL) {
            orer(np->left);
        }
    }
    if (np->right != NULL) {
        if (np->right->data != AST_EXPRS) {
            sum = sum | np->right->num;
        }
        if (np->right->data == AST_EXPRS || np->right->data == AST_BOOL) {
            orer(np->right);
        }
    }
    return sum;
}

// Tables
struct Table {
    char *type; // TODO: Type Checking
    char *name;
    int value;
    int inFun;
};
// normal var, no param function
int var_table_index = 0;
struct Table var_table[100];
// function scope variable
int tmpTableIndex = 0;
struct Table tmp_table[100];
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
void storeParmsToTmpTable (struct Node * np) {
    if (np->left != NULL && np->left->data != AST_FUN) {
        if (np->left->data == AST_NUM) {
            tmp_table[tmpTableIndex++].value = np->left->num;
        }
        storeParmsToTmpTable(np->left);
    }
    if (np->right != NULL && np->right->data != AST_FUN) {
        if (np->right->data == AST_NUM) {
            tmp_table[tmpTableIndex++].value = np->right->num;
        }
        storeParmsToTmpTable(np->right);
    }
}
void bindParams (struct Node * np) {
    if (np->left != NULL) {
        if (np->left->data == AST_VAR) {
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
        if (np->right->data == AST_VAR) {
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

// Main
void traverseAST(struct Node *np) {
    if (np == NULL) {
        return;
    }
    switch(np->data) {
        case AST_NUM:
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // printf("Integer Number (n): %d\n", np->num);
            break;
        case AST_BOOL:
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
        case AST_PRINT_NUM:
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = np->left->num;
            // printf("N: %d\n", np->num);
            break;
        case AST_PRINT_BOOL:
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
        case AST_DEFINE:
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // Function but no params
            if (np->right->data == AST_FUN && np->right->left->data == AST_FUN_NULL) {
                var_table[var_table_index].name = np->left->name; // V
                var_table[var_table_index].value = np->right->right->num; // EXP
                var_table[var_table_index].inFun = 0; // case AST_CALL_ANONYMOUS will make inFun=1
                var_table_index++;
            } else if (np->right->data == AST_FUN) { // normal function
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
        case AST_VAR:
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            np->num = searchTable(np->name, np->inFun); // get Table value
            // printf("//Var %s: %d\n", np->name, np->num);
            break;
        case AST_FUN:
            traverseAST(np->left);
            traverseAST(np->mid);
            traverseAST(np->right);
            // params: np->left->name;
            // exprs: np->right;
            break;
        case AST_CALL_ANONYMOUS:
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
        case AST_CALL_NAMED: {
            // pass function to be a param
            // np->left: f (X,X)
            // np->right: P
            // np->right->left: C // normal is P or n
            // np->right->right: X // normal is P or n
            // np->right->left->left: f
            // np->right->left->right: X
            if (np->right->left->data == AST_CALL_NAMED) {
                np->right->left->data = AST_NUM; // Change AST_CALL_NAMED to AST_NUM, not Call anymore
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
        default: // AST_STMTS, AST_EXPRS
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
        case AST_PRINT_NUM:
            printf("%d\n", np->left->num);
            break;
        case AST_PRINT_BOOL:
            if (np->left->num) {
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

// Debuggers
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