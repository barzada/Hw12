#ifndef FLIGHTS

/*#define DEPARTURES 300
#define FLIGHT_NUMBER 301
#define TIME 302
#define AIRPORT 303
#define CARGO 304
#define FREIGHT 305
#define  TYPE 306*/

union {
  int ival;
  char departures [30];
  char flightNumber [80];
  int etime;
  char time[20];
  char airport[70];
  char type[70];

} yylval;

// yylex returns 0 when EOF is encountered
/*enum token {
     PLAYLIST =1, 
     SEQ_NUM,
     SONG,
     SONG_NAME,
     ARTIST,
     NAME,
     LENGTH, 
     SONG_LENGTH     
};*/

enum token {
     DEPARTURES = 1,
     FLIGHT_NUMBER,
     TIME,
     AIRPORT,
     CARGO,
     FREIGHT, 
     TYPE     
};

char *token_name(enum token token);

extern union _lexVal lexicalValue;// like yylval when we use bison

void errorMsg(const char *s);

#endif
