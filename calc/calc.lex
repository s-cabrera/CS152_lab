/* Mini Calculator */
/* calc.lex */

%{
#include "heading.h"
#include "tok.h"
void yyerror(char *s);

%}

digit		[0-9]
int_const	{digit}+

%%

{int_const}	{ yylval.int_val = atoi(yytext); return INTEGER_LITERAL; }
"+"		{ yylval.op_val = new std::string(yytext); return PLUS; }
"*"		{ yylval.op_val = new std::string(yytext); return MULT; }

[ \t]*		{}
[\n]		{ yylineno++;	}

%%
int main(int argc, char **argv){
	yyparse();
	return 0;
}
void yyerror(char *s){
	printf("error!!!");
}
