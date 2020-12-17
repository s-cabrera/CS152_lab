%{
#include <iostream>
#define YY_DECL yy::parser::symbol_type yylex()
#include "parser.tab.hh"
#include <math.h>

int currLine = 0;
int currPos = 1;
static yy::location loc;
%}

%option noyywrap 

%{
#define YY_USER_ACTION loc.columns(yyleng);
%}

	/* your definitions here */
	digit 		[0-9]
	alpha 		[a-zA-Z]
	iden		[a-zA-Z0-9_]
	comment		##[^\n]*\n
	whitespace 	[ \r\t]+
	newline		\n
	/* your definitions end */

%%

%{
loc.step(); 
%}

	/* your rules here */
					/***** Comments *****/
				/********************/
{comment}			{ ++currLine; currPos = 1; }

				/***** Keywords *****/
				/********************/
function       		{currPos += yyleng; return yy::parser::make_FUNCTION(loc);}
beginparams			{currPos += yyleng; return yy::parser::make_BEGIN_PARAMS(loc);}
endparams			{currPos += yyleng; return yy::parser::make_END_PARAMS(loc);  }
beginlocals			{currPos += yyleng; return yy::parser::make_BEGIN_LOCALS(loc);}
endlocals			{currPos += yyleng; return yy::parser::make_END_LOCALS(loc);}
beginbody			{currPos += yyleng; return yy::parser::make_BEGIN_BODY(loc);  }
endbody				{currPos += yyleng; return yy::parser::make_END_BODY(loc);  }
integer 			{currPos += yyleng; return yy::parser::make_INTEGER(loc); }
array				{currPos += yyleng; return yy::parser::make_ARRAY(loc);  }
of					{currPos += yyleng; return yy::parser::make_OF(loc);  }
if					{currPos += yyleng; return yy::parser::make_IF(loc);  }
then				{currPos += yyleng; return yy::parser::make_THEN(loc);  }
endif				{currPos += yyleng; return yy::parser::make_ENDIF(loc);  }
else				{currPos += yyleng; return yy::parser::make_ELSE(loc);  }
while				{currPos += yyleng; return yy::parser::make_WHILE(loc);  }
do					{currPos += yyleng; return yy::parser::make_DO(loc);  }
for					{currPos += yyleng; return yy::parser::make_FOR(loc);  }
beginloop	  		{currPos += yyleng; return yy::parser::make_BEGINLOOP(loc);  }
endloop				{currPos += yyleng; return yy::parser::make_ENDLOOP(loc);  }
continue			{currPos += yyleng; return yy::parser::make_CONTINUE(loc);  }
read				{currPos += yyleng; return yy::parser::make_READ(loc);  }
write				{currPos += yyleng; return yy::parser::make_WRITE(loc);  }
and					{currPos += yyleng; return yy::parser::make_AND(loc);  }
or					{currPos += yyleng; return yy::parser::make_OR(loc);  }
not					{currPos += yyleng; return yy::parser::make_NOT(loc);  }
true				{currPos += yyleng; return yy::parser::make_TRUE(loc);  }
false				{currPos += yyleng; return yy::parser::make_FALSE(loc);  }
return				{currPos += yyleng; return yy::parser::make_RETURN(loc);  }

				/***** Nums, Identifier Errors, Identifiers *****/
				/************************************************/
{digit}+			{currPos += yyleng; return yy::parser::make_NUMBER(loc, yytext); }
{digit}+{iden}+	    { printf("Error	at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
_+{iden}+			{ printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
{alpha}+{iden}*_	{ printf("Error at line %d, column %d: identifier \"%s\" cannot end with an underscore\n", currLine, currPos, yytext); currPos += yyleng; exit(1);}
{alpha}+{iden}*		{currPos += yyleng; return yy::parser::make_IDENT(loc,yytext); }

				/***** Operators *****/
				/*********************/
-				{currPos += yyleng; return yy::parser::make_SUB(loc); }
\+				{currPos += yyleng; return yy::parser::make_ADD(loc); }
\*				{currPos += yyleng; return yy::parser::make_MULT(loc); }
\/				{currPos += yyleng; return yy::parser::make_DIV(loc); }
\%				{currPos += yyleng; return yy::parser::make_MOD(loc); }
\=\=			{currPos += yyleng; return yy::parser::make_EQ(loc); }
\!\=			{currPos += yyleng; return yy::parser::make_NEQ(loc); }
\<\=			{currPos += yyleng; return yy::parser::make_LTE(loc); }
\>\=			{currPos += yyleng; return yy::parser::make_GTE(loc); }
\<				{currPos += yyleng; return yy::parser::make_LT(loc); }
\>				{currPos += yyleng; return yy::parser::make_GT(loc); }

				/***** Special Symbols *****/
				/***************************/
\;				{currPos += yyleng; return yy::parser::make_SEMICOLON(loc);}
\(				{currPos += yyleng; return yy::parser::make_L_PAREN(loc);  }
\)				{currPos += yyleng; return yy::parser::make_R_PAREN(loc);  }
\[				{currPos += yyleng; return yy::parser::make_L_SQUARE_BRACKET(loc);  }
\]				{currPos += yyleng; return yy::parser::make_R_SQUARE_BRACKET(loc);  }
\:				{currPos += yyleng; return yy::parser::make_COLON(loc);  }
\,				{currPos += yyleng; return yy::parser::make_COMMA(loc);  }
\:=				{currPos += yyleng; return yy::parser::make_ASSIGN(loc);  }
	
				/***** Whitespace *****/
				/**********************/
{whitespace}			{ currPos += yyleng; }
\n				{ ++currLine; currPos = 1; }

				/***** Unexpected Symbols *****/
				/******************************/
.				{ printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); currPos += yyleng;}	

	/* use this structure to pass the Token :
	 * return yy::parser::make_TokenName(loc)
	 * if the token has a type you can pass it's value
	 * as the first argument. as an example we put
	 * the rule to return token function.
	 */



 <<EOF>>	{return yy::parser::make_END(loc);}
	/* your rules end */

%%

