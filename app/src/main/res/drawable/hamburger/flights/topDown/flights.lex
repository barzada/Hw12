%{

#include "flights.h"

extern int atoi (const char *);
%}

%option noyywrap

/* exclusive start condition -- deals with C++ style comments */ 
%x COMMENT

%%
"<departures>"     { return DEPARTURES; }

[A-Z][A-Z][0-9]{1,4}   { strcpy (yylval.flightNumber, yytext); return FLIGHT_NUMBER; }
[0-1][0-9]:[0-5][0-9](a\.m\.|p\.m\.)  { strcpy (yylval.time, yytext); return TIME; }
\"[A-Z][a-zA-Z\ ]*\"  { strcpy (yylval.airport, yytext); return AIRPORT; }
"cargo"      { strcpy(yylval.type,yytext) ; return CARGO; }
"freight"        { strcpy(yylval.type,yytext); return FREIGHT; }

[' '\n\t\r ]+ {} /* skip white space */

"//"       { BEGIN (COMMENT); }

<COMMENT>.+ /* skip comment */
<COMMENT>\n {  /* end of comment --> resume normal processing */
                BEGIN (0); }

.          { fprintf (stderr, "unrecognized token %c\n", yytext[0]); }

%%

/*int main (int argc, char **argv)
{
   int token;

   if (argc != 2) {
      fprintf(stderr, "Usage: mylex <input file name>\n %s", argv [0]);
      exit (1);
   }

   yyin = fopen (argv[1], "r");
   printf("TOKEN\t\tLEXME\t\t\tSEMANTIC VALUE\n");

   while ((token = yylex ()) != 0)
     switch (token) {
	 case DEPARTURES: printf("DEPARTURES \t <departures> \n");
	              break;
         case FLIGHT_NUMBER:     printf ("FLIGHT_NUMBER  \t %s\n", yylval.flightNumber);
	              break;
	 case TIME: if( strstr(yylval.time,"a")!=NULL)
                     printf ("TIME\t\t %s\t\t am\n", yylval.time);          
              else
                    printf ("TIME\t\t %s\t\t pm\n", yylval.time);	          
        break;
    case AIRPORT: printf ("AIRPORT\t\t %s\n", yylval.airport);
	              break;
    case FREIGHT: printf ("FREIGHT\t\t type \t\t\t %s\n", yylval.type);
    	           break;
     case CARGO: printf ("CARGO\t\t type \t\t\t %s\n", yylval.type);

	              break;
         default:     fprintf (stderr, "error ... \n"); exit (1);
     } 
   fclose (yyin);
   exit (0);
}*/

