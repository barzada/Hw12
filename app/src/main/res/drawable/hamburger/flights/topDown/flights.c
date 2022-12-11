/* 
    This is an example of a recursive descent parser.
    
This  program reads a list  of songs  from its input.
It prints the length (in minutes and seconds) of the shortest song
   that satisfies the following conditions:
     (1)  Its length is at least 4:02  (4 minutes and 2 seconds)
     (2)  The artist is known by one name only (for example
          Madonna  but not Joe Cocker)
          
For an example of an input, see file madonna.txt 

To prepare the program, issue the following commands from
  The command line:
  
  flex madonna.lex    (This will generate a file called lex.yy.c)
    
  compile the program using a C compiler
  for example: 
       gcc lex.yy.c madonna.c -o madonna.exe
       
  (note that file madonna.h is part of the program (it's included in
     other files)
       
  The input file for the program should be supplied as a command line argument
  for example:
      madonna.exe  madonna.txt
      
      
  Here is a grammar describing the input
  (tokens are written using uppercase letters):
    start -> PLAYLIST songlist 
    songlist -> songlist song | epsilon
    song -> SEQ_NUM  SONG SONG_NAME  ARTIST artist_name LENGTH SONG_LENGTH
    artist_name -> NAME | NAME NAME
    
    Note that this grammar is not LL(1) because of the left recursion
    in the production for songlist and because of the productions
    for artist_name. It is not hard to find an equivalent LL(1) grammar
    but this was not necessary. See the functions songlist()
    and artist_name().

*/
#include <stdio.h>
#include <stdlib.h>  /* for exit() */
#include <string.h>
#include "flights.h"
 
extern enum token yylex (void);
enum token lookahead;

// the recursive descent parser
void start();
void flights();
void flight();

int am_cnt = 0;
int pm_cnt = 0;

void match(int expectedToken)
{
    if (lookahead == expectedToken)
        lookahead = yylex();
    else {
        char e[100]; 
        sprintf(e, "error: expected token %s, found token %s", 
                token_name(expectedToken), token_name(lookahead));
        errorMsg(e);
        exit(1);
    }
}

void parse()
{
    lookahead = yylex();
    start();
    if (lookahead != 0) {  // 0 means EOF
        errorMsg("EOF expected");
        exit(1);
    }
}

void 
start()
{
    match(DEPARTURES);
    flights();
}
   
void
flights()
{
    while (lookahead == FLIGHT_NUMBER) {
        flight();
    }
}

void 
flight() 
{
    match(TIME);
    match(AIRPORT);
    match(TYPE);

    if(strcmp(yylval.type, "cargo") == 0)
        return;

    if( strstr(yylval.time,"a")!=NULL)
            am_cnt++;     
    else
            pm_cnt++;     
}

int
main (int argc, char **argv)
{
    extern FILE *yyin;
    if (argc != 2) {
       fprintf (stderr, "Usage: %s <input-file-name>\n", argv[0]);
	   return 1;
    }
    yyin = fopen (argv [1], "r");
    if (yyin == NULL) {
       fprintf (stderr, "failed to open %s\n", argv[1]);
	   return 2;
    }
  
    parse();

    if(am_cnt < pm_cnt)
        printf("There were more flights after noon.\n");
    else
        printf("There were more flights before noon.\n");
  
    fclose (yyin);
    return 0;
}

void errorMsg(const char *s)
{
  extern int yylineno;
  fprintf (stderr, "line %d: %s\n", yylineno, s);
}


