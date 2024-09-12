/****************************************************/
/* File: cminus.l                                   */
/* Lex specification for C-                         */
/* Adapted for new definitions                      */
/****************************************************/

%option noyywrap 

%{
#include "globals.h"
#include "util.h"
#include "scan.h"
char tokenString[MAXTOKENLEN+1];
char currentLine[256];
extern FILE* redundant_source;
int printLine1 = 1;
%}

digit       [0-9]
number      {digit}+
letter      [a-zA-Z]
identifier  {letter}+
newline     \n|(\r\n)
whitespace  [ \t]+

%%

"if"            {return IF;}
"else"          {return ELSE;}
"int"           {return INT;}
"return"        {return RETURN;}
"void"          {return VOID;}
"while"         {return WHILE;}

"+"             {return PLUS;}
"-"             {return MINUS;}
"*"             {return TIMES;}
"/"             {return OVER;}
"<"             {return LT;}
"<="            {return LE;}
">"             {return GT;}
">="            {return GE;}
"=="            {return EQ;}
"!="            {return NE;}
"="             {return ASSIGN;}
";"             {return SEMI;}
","             {return COMMA;}
"("             {return LPAREN;}
")"             {return RPAREN;}
"["             {return LBRACKET;}
"]"             {return RBRACKET;}
"{"             {return LCURLY;}
"}"             {return RCURLY;}

"/*"            { char c;
                  do
                  { c = input();
                    if (c == EOF) break;
                    if (c == '\n'){
                      lineno++;
                      printLine(redundant_source); 
                    }
                  } while (!(c == '*' && input() == '/'));
                }

{identifier}    {return ID;}
{number}        {return NUM;}

{whitespace}   { /* Não imprime nada, apenas ignora espaços em branco */ }

{newline}       { 
                  lineno++; 
                  printLine(redundant_source);  
                }

.               {return ERROR;}

%%

TokenType getToken(void)
{ static int firstTime = TRUE;
  TokenType currentToken;
  if (firstTime)
  { firstTime = FALSE;
    lineno++;
    yyin = source;
    yyout = listing;
  }

  if (printLine1 == 1){
    printLine(redundant_source);
    printLine1 = 0;
  }

  currentToken = yylex();
  strncpy(tokenString, yytext, MAXTOKENLEN);

  if (TraceScan) {
    pc("\t%d: ", lineno);
    printToken(currentToken, tokenString);
  }

  return currentToken;
}