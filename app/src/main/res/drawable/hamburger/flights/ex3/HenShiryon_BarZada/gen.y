%code {
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <assert.h>
#include "utilities.h"
#include "symboltable.h"

typedef int TEMP;  /* temporary variable.
                       temporary variables are named t1, t2, ... 
                       in the generated code but
					   inside the compiler they may be represented as
					   integers. For example,  temporary 
					   variable 't3' is represented as 3.
					*/
  
// number of errors found by the compiler 
int errors = 0;					

extern int yylex (void);
void yyerror (const char *s);

static int newtemp(), newlabel();
void emit (const char *format, ...);
void emitlabel (int label);

/* stack of "exit labels".  An "exit label" is the target 
   of a goto used to exit a statement (e.g. a while statement or a 
   switch statement.)
   The stack is used to implement 'break' statements which may appear
   in while statements.
   A stack is needed because such statements may be nested.
   The label at the top of the stack is the "exit label"  for
   the innermost while statement currently being processed.
   
   Labels are represented here by integers. For example,
   L_3 is represented by the integer 3.
*/

typedef intStack labelStack;
labelStack exitLabelsStack;

enum type currentType;  // type specified in current declaration

} // %code

%code requires {
    void errorMsg (const char *format, ...);
    enum {NSIZE = 100}; // max size of variable names
    enum type {_INT, _DOUBLE };
	enum op { PLUS, MINUS, MUL, DIV, PLUS_PLUS, MINUS_MINUS };
	
	typedef int LABEL;  /* symbolic label. Symbolic labels are named
                       L_1, L_2, ... in the generated code 
					   but inside the compiler they may be represented as
					   integers. For example,  symbolic label 'L_3' 
					   is represented as 3.
					 */
    struct exp { /* semantic value for expression */
	    char result[NSIZE]; /* result of expression is stored 
   		   in this variable. If result is a constant number
		   then the number is stored here (as a string) */
	    enum type type;     // type of expression
	};
	
	struct caselist { /* semantic value for 'caselist' */
	    char switch_result[NSIZE]; /* result variable of the switch expression */
        LABEL exitlabel;/* code for each case ends with a jump to exitlabel */				   
    };			   
	
} // code requires

/* this will be the type of all semantic values. 
   yylval will also have this type 
*/
%union {
   char name[NSIZE];
   int ival;
   double dval;
   enum op op;
   struct exp e;
   LABEL label;
   const char *relop;
   enum type type;
   struct caselist cl;
}

%token <ival> INT_NUM
%token <dval> DOUBLE_NUM
%token <relop> RELOP
%token <name> ID
%token <op> ADDOP MULOP INC


%token WHILE IF ELSE DO SWITCH  CASE DEFAULT 
%token BREAK INT DOUBLE INPUT OUTPUT

%nterm <e> expression
%nterm <label> boolexp  start_label exit_label
%nterm <type> type
%nterm <type> list_id
%nterm <cl> caselist

/* this tells bison to generate better error messages
   when syntax errors are encountered (these error messages
   are passed as an argument to yyerror())
*/
%define parse.error verbose

/* if you are using an old version of bison use this instead:
%error-verbose */

/* enable trace option (for debugging). 
   To request trace info: assign non zero value to yydebug */
%define parse.trace
/* formatting semantic values (when tracing): */
%printer {fprintf(yyo, "%s", $$); } ID
%printer {fprintf(yyo, "%d", $$); } INT_NUM
%printer {fprintf(yyo, "%f", $$); } DOUBLE_NUM

%printer {fprintf(yyo, "result=%s, type=%s",
            $$.result, $$.type == _INT ? "int" : "double");} expression


/* token ADDOP has lower precedence than token MULOP.
   Both tokens have left associativity.

   This solves the shift/reduce conflicts in the grammar 
   because of the productions:  
      expression: expression ADDOP expression | expression MULOP expression   
*/
%left ADDOP
%left MULOP

%%
program: declarations { initStack(&exitLabelsStack); } 
         stmtlist;

declarations: declarations decl;

declarations: %empty;

decl:  type { current_type = $1; } list_id ';' ;

type: INT    { $$= _INT;} |
      DOUBLE { $$ = _DOUBLE; };
	  
list_id:  list_id ',' ID {
    struct symbol* id_temp = lookup($3);
    if (id_temp != NULL)
        errorMsg("Error: The sign is %s already taken\n", $3);
     else
       putSymbol($3, current_type);

};

list_id:  ID {
    struct symbol* id_temp = lookup($1);
    if (id_temp != NULL)
        errorMsg("Error: The sign is %s already taken\n", $1);
    else
        putSymbol($1, current_type);

};
			
stmt: assign_stmt  |
      while_stmt   |
	  if_stmt      |
	  do_while_stmt|
	  switch_stmt  |
	  break_stmt   |
	  input_stmt   |
	  output_stmt  |
	  block_stmt
	  ;

assign_stmt:  ID '=' expression ';' {
    struct symbol* id_temp = lookup($1);
    if (id_temp == NULL)
        errorMsg("Error: The sign is %s already taken", $1);

    else {

        if (id_temp->type == _INT && $3.type == _DOUBLE)
            emit("%s = (int)%s\n", $1, $3.result);

        //both same
        else if (id_temp->type == _DOUBLE && $3.type == _INT)
            emit("%s = (double)%s\n", $1, $3.result);

        else
            emit("%s = %s\n", $1, $3.result);

    }
};
				 


expression :  '(' expression ')' { $$ = $2; }
           |  ID {
                struct symbol* id_temp = lookup($1);
                if (id_temp == NULL)
                    errorMsg("Error: The sign %s is not existed\n", $1);


                else {
                    strcpy($$.result, $1);
                    $$.type = id_temp->type;
                }
            }
           |  INT_NUM    { sprintf($$.result, "%d", $1); $$.type = _INT; }
           |  DOUBLE_NUM { sprintf($$.result, "%.2f", $1); $$.type = _DOUBLE; }
           ;

while_stmt: WHILE start_label '('  boolexp { push(&exitLabelsStack, $4); } ')' stmt {
    emit("goto L_%d\n", $2);
    emitlabel($4);
    pop(&exitLabelsStack);
};



expression : expression MULOP expression {
    sprintf($$.result, "t%d", newtemp());
    int temp_number;
    char ch;
    if ($2 == MUL) {
        ch = '*';
    } else {
        ch = '/';
    }

    //int and double
    if ($1.type == _INT && $3.type == _DOUBLE) {
        temp_number = newtemp();
        emit("t%d = (double) %s\n", temp_number, $1.result);
        emit("%s = t%d <%c> %s\n", $$.result, temp_number, c, $3.result);
        $$.type = _DOUBLE;
    }

    //int and double
    else if ($1.type == _DOUBLE && $3.type == _INT) {
        temp_number = newtemp();
        emit("t%d = (double)%s\n", temp_number, $3.result);
        emit("%s = %s <%c> t%d\n", $$.result, $1.result, c, temp_number);
        $$.type = _DOUBLE;
    }

    //only double
    else if ($1.type == _DOUBLE && $3.type == _DOUBLE) {
        emit("%s = %s <%c> %s\n", $$.result, $1.result, c, $3.result);
        $$.type = _DOUBLE;
    }

    //only interger
    else {
        emit("%s = %s %c %s\n", $$.result, $1.result, c, $3.result);
        $$.type = _INT;
    }
};   



expression : expression ADDOP expression {
    sprintf($$.result, "t%d", newtemp());
    int temp_number;
    char ch;

    if ($2 == PLUS)
        ch = '+';

    else
        ch = '-';

    //double and int
    if ($1.type == _INT && $3.type == _DOUBLE) {
        temp_number = newtemp();
        emit("t%d = (double) %s\n", temp_number, $1.result);
        emit("%s = t%d <%c> %s\n", $$.result, temp_number, c, $3.result);
        $$.type = _DOUBLE;
    }

    //double and int
    else if ($1.type == _DOUBLE && $3.type == _INT) {
        temp_number = newtemp();
        emit("t%d = (double) %s\n", temp_number, $3.result);
        emit("%s = %s <%c> t%d\n", $$.result, $1.result, c, temp_number);
        $$.type = _DOUBLE;
    }

    //double only
    else if ($1.type == _DOUBLE && $3.type == _DOUBLE) {
        emit("%s = %s <%c> %s\n", $$.result, $1.result, c, $3.result);
        $$.type = _DOUBLE;
    }

    // integer only
    else {
        emit("%s = %s %c %s\n", $$.result, $1.result, c, $3.result);
        $$.type = _INT;
    }
};


start_label: %empty { $$ = newlabel(); emitlabel($$); };

boolexp:  expression RELOP expression 
             {  $$ = newlabel();
			    emit("ifFalse %s %s %s goto L_%d\n", 
			          $1.result, $2, $3.result, $$);
             };

if_stmt:  IF exit_label '(' boolexp ')' stmt
               { emit("goto L_%d\n", $2);
                 emitlabel($4);
               }				 
          ELSE stmt { emitlabel($2); };
		  
exit_label: %empty { $$ = newlabel(); };

do_while_stmt: DO start_label stmt WHILE '(' boolexp ')' ';' {
    emit("goto L_%d\n", $2);
    emitlabel($6);
};

switch_stmt:  SWITCH  
              caselist
              DEFAULT ':' stmtlist 
			  '}' /* the matching '{' is generated by 'caselist' */
			  {
                emitlabel($2.exitlabel);
              };

caselist: caselist CASE INT_NUM exit_label {
                emit("ifFalse %s == %d goto L_%d\n", $1.switch_result, $3, $4);
            } 
            ':' stmtlist {
                emit("goto L_%d\n", $1.exitlabel);
                emitlabel($4);
            };					  

caselist: '(' expression ')' '{' {
    if ($2.type != _INT) {
        errorMsg("Error: must be from type int\n");
    } else {
        strcpy($$.switch_result, $2.result);
        $$.exitlabel = newlabel(); 
    }
};					                  
 
break_stmt: BREAK ';' {
    if (isEmpty(&exitLabelsStack)) {
        errorMsg("Error: statment outside the loop\n");
    } else {
        emit("goto L_%d\n", peek(&exitLabelsStack));
    }
};

	
input_stmt: INPUT '(' ID ')' ';' {
    struct symbol* id_temp = lookup($3);
    if (id_temp == NULL)
        errorMsg("Error: Can't store input in symbol %s that doesn't exist\n", $3);

    else
        (id->type == _INT) ? emit("read %s\n", $3) : emit("<read> %s\n", $3);

}
             
output_stmt: OUTPUT '(' expression ')' ';' {

    if ($3.type == _INT)
        emit("write %s\n", $3.result);

    else
        emit("<write> %s\n", $3.result);

};
                
block_stmt:   '{'  stmtlist '}';

stmtlist: stmtlist stmt { emit("\n"); }
        | %empty
		;				
					 
%%
int main (int argc, char **argv)
{
  extern FILE *yyin; /* defined by flex */
  extern int yydebug;
  
  if (argc > 2) {
     fprintf (stderr, "Usage: %s [input-file-name]\n", argv[0]);
	 return 1;
  }
  if (argc == 2) {
      yyin = fopen (argv [1], "r");
      if (yyin == NULL) {
          fprintf (stderr, "failed to open %s\n", argv[1]);
	      return 2;
	  }
  } // else: yyin will be the standard input (this is flex's default)
  

  yydebug = 0; //  should be set to 1 to activate the trace

  if (yydebug)
      setbuf(stdout, NULL); // (for debugging) output to stdout will be unbuffered
  
  yyparse();
  
  fclose (yyin);
  return 0;
} /* main */

/* called by yyparse() whenever a syntax error is detected */
void yyerror (const char *s)
{
  extern int yylineno; // defined by flex
  
  fprintf (stderr,"line %d:%s\n", yylineno,s);
}

/* temporary variables are represented by numbers. 
   For example, 3 means t3
*/
static
TEMP newtemp ()
{
   static int counter = 1;
   return counter++;
} 


// labels are represented by numbers. For example, 3 means L_3
static
LABEL newlabel ()
{
   static int counter = 1;
   return counter++;
} 

// emit works just like  printf  --  we use emit 
// to generate code and print it to the standard output.
void emit (const char *format, ...)
{
/*  /* uncomment following line to stop generating code when errors
	   are detected */
    /* if (errors > 0) return; */ 
    printf ("    ");  // this is meant to add a nice indentation.
                      // Use emitlabel() to print a label without the indentation.    
    va_list argptr;
	va_start (argptr, format);
	// all the arguments following 'format' are passed on to vprintf
	vprintf (format, argptr); 
	va_end (argptr);
}

/* use this  to emit a label without any indentation */
void emitlabel(LABEL label) 
{
    /* uncomment following line to stop generating code when errors
	   are detected */
    /* if (errors > 0) return; */ 
	
    printf ("L_%d:\n",  label);
}

/*  Use this to print error messages to standard error.
    The arguments to this function are the same as printf's arguments
*/
void errorMsg(const char *format, ...)
{
    extern int yylineno; // defined by flex
	
	fprintf(stderr, "line %d: ", yylineno);
	
    va_list argptr;
	va_start (argptr, format);
	// all the arguments following 'format' are passed on to vfprintf
	vfprintf (stderr, format, argptr); 
	va_end (argptr);
	
	errors++;
} 
    






