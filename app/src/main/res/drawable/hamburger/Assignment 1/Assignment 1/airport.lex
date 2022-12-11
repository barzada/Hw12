%{
#define DEPARTURES 1
#define FLIGHT_NUMBER 2
#define TIME 3
#define AIRPORT 4
#define CARGO 5
#define FREIGHT 6


union {
    char departures[13];
    char flightNumber[7];
    char flightTime[10];
    char destination[101];
    char cargo[6];
    char freight[8];
} yylval;

#include <stdio.h>
#include <string.h>

%}

%option noyywrap
%option yylineno

%%

"<departures>"  { strcpy(yylval.departures, yytext); return DEPARTURES; }

[A-Z]{2}[0-9]{1,4}  { strcpy(yylval.flightNumber, yytext); return FLIGHT_NUMBER; }

(0[0-9]|1[0-2]):[0-5][0-9][ap]\.m\. { strcpy(yylval.flightTime, yytext); return TIME; }

\"[A-Z][a-zA-Z\ ]*\"   { strcpy(yylval.destination, yytext); return AIRPORT; }

"cargo" { strcpy(yylval.cargo, yytext); return CARGO; }

"freight" { strcpy(yylval.freight, yytext); return FREIGHT; }

[' '\n\t\r ]+ {} /* skip white space */

.   { fprintf (stderr, "unrecognized token %c\n", yytext[0]); }

%%

int main (int argc, char **argv)
{
    int token;

    if (argc != 2)
    {
      fprintf(stderr, "Usage: airport <input file name>\n", argv[0]);
      exit (1);
    }

   yyin = fopen (argv[1], "r");
   if (yyin == NULL)
   {
     fprintf(stderr, "failed to open file %s\n", argv[1]);
     exit(1);
   }

   printf("TOKEN\t\t\tLEXME\t\t\t\tSEMANTIC VALUE\n");
   printf("----------------------------------------------------------------------\n");

  while ((token = yylex ()) != 0)
     switch (token) {
	 case DEPARTURES: printf("DEPARTURES\t\t\t%s\t\t\tdepartures\n", yylval.departures);
	              break;
   case FLIGHT_NUMBER:     printf ("FLIGHT_NUMBER\t\t\t%s\t\t\t\tflight number\n", yylval.flightNumber);
	              break;
	 case TIME: printf ("TIME\t\t\t\t%s\t\t\ttime\n", yylval.flightTime);
	              break;
   case AIRPORT: printf ("AIRPORT\t\t\t\t%s\t\t\tairport\n", yylval.destination);
	              break;
   case CARGO: printf ("CARGO\t\t\t\t%s\t\t\t\tcargo\n", yylval.cargo);
	              break;
   case FREIGHT: printf ("FREIGHT\t\t\t\t%s\t\t\t\tfreight\n", yylval.freight);
	              break;
         default:     fprintf (stderr, "error ... \n"); exit (1);
     } 
   fclose (yyin);
   exit (0);
}
