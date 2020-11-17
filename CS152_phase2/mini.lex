/* Regexes */
%{
	#include "y.tab.h"
	int currLine = 1;
	int currPos = 1;
%}

digit 		[0-9]
alpha 		[a-zA-Z]
iden		[a-zA-Z0-9_]
comment		##[^\n]*\n
whitespace 	[ \r\t]+
newline		\n



%%
				/***** Comments *****/
				/********************/
{comment}			{ ++currLine; currPos = 1; }

				/***** Keywords *****/
				/********************/
function			{currPos += yyleng; return FUNCTION;}
beginparams			{currPos += yyleng; return BEGIN_PARAMS;}
endparams			{currPos += yyleng; return END_PARAMS;  }
beginlocals			{currPos += yyleng; return BEGIN_LOCALS;}
endlocals			{currPos += yyleng; return END_LOCALS;}
beginbody			{currPos += yyleng; return BEGIN_BODY;  }
endbody				{currPos += yyleng; return END_BODY;  }
integer 			{currPos += yyleng; return INTEGER; }
array				{currPos += yyleng; return ARRAY;  }
of					{currPos += yyleng; return OF;  }
if					{currPos += yyleng; return IF;  }
then				{currPos += yyleng; return THEN;  }
endif				{currPos += yyleng; return ENDIF;  }
else				{currPos += yyleng; return ELSE;  }
while				{currPos += yyleng; return WHILE;  }
do					{currPos += yyleng; return DO;  }
for					{currPos += yyleng; return FOR;  }
beginloop	  		{currPos += yyleng; return BEGINLOOP;  }
endloop				{currPos += yyleng; return ENDLOOP;  }
continue			{currPos += yyleng; return CONTINUE;  }
read				{currPos += yyleng; return READ;  }
write				{currPos += yyleng; return WRITE;  }
and					{currPos += yyleng; return AND;  }
or					{currPos += yyleng; return OR;  }
not					{currPos += yyleng; return NOT;  }
true				{currPos += yyleng; return TRUE;  }
false				{currPos += yyleng; return FALSE;  }
return				{currPos += yyleng; return RETURN;  }

				/***** Nums, Identifier Errors, Identifiers *****/
				/************************************************/
{digit}+			{currPos += yyleng; printf("NUMBER %s\n", yytext); }
{digit}+{iden}+			{ printf("Error	at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
_+{iden}+			{ printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
{alpha}+{iden}*_		{ printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
{alpha}+{iden}*			{ printf("IDENT %s\n", yytext); currPos += yyleng; }

				/***** Operators *****/
				/*********************/
-				{ printf("SUB\n"); currPos += yyleng; }
\+				{ printf("ADD\n"); currPos += yyleng; }
\*				{ printf("MULT\n"); currPos += yyleng; }
\/				{ printf("DIV\n"); currPos += yyleng; }
\%				{ printf("MOD\n"); currPos += yyleng; }
\=\=				{ printf("EQ\n"); currPos += yyleng; }
\!\=				{ printf("NEQ\n"); currPos += yyleng; }
\<\=				{ printf("LTE\n"); currPos += yyleng; }
\>\=				{ printf("GTE\n"); currPos += yyleng; }
\<				{ printf("LT\n"); currPos += yyleng; }
\>				{ printf("GT\n"); currPos += yyleng; }

				/***** Special Symbols *****/
				/***************************/
\;				{ printf("SEMICOLON\n"); currPos += yyleng; }
\(				{ printf("L_PAREN\n"); currPos += yyleng; }
\)				{ printf("R_PAREN\n"); currPos += yyleng; }
\[				{ printf("L_SQUARE_BRACKET\n"); currPos += yyleng; }
\]				{ printf("R_SQUARE_BRACKET\n"); currPos += yyleng; }
\:				{ printf("COLON\n"); currPos += yyleng; }
\,				{ printf("COMMA\n"); currPos += yyleng; }
\:=				{ printf("ASSIGN\n"); currPos += yyleng; }
	
				/***** Whitespace *****/
				/**********************/
{whitespace}			{ currPos += yyleng; }
\n				{ ++currLine; currPos = 1; }

				/***** Unexpected Symbols *****/
				/******************************/
.				{ printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); currPos += yyleng;}	

%%

int main(){
	yylex();
}
