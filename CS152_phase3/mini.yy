%{
%}

%skeleton "lalr1.cc"
%require "3.0.4"
%defines
%define api.token.constructor
%define api.value.type variant
%define parse.error verbose
%locations


%code requires
{
	/* you may need these header files 
	 * add more header file if you need more
	 */
#include <list>
#include <string>
#include <functional>
using namespace std;
	/* define the sturctures using as types for non-terminals */
	struct dec_type{
		string code;
		list<string> ids;
	};
	struct stmt_type{
		string code;
		string comp;
		list<string> ids;
	};
	/* end the structures for non-terminal types */
}

%code
{
#include "parser.tab.hh"
struct tests
{
	string name;
	yy :: location loc;
};
	/* you may need these header files 
	 * add more header file if you need more
	 */
#include <sstream>
#include <map>
#include <regex>
#include <set>
yy::parser::symbol_type yylex();
void yyerror(const char *msg);

	/* define your symbol table, global variables,
	 * list of keywords or any function you may need here */
	
	/* end of your code */
}
%token END 0 "end of file";
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE 
%token AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD EQ NEQ LTE GTE LT GT
%token SEMICOLON L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET COLON COMMA ASSIGN
%token <int> NUMBER 
%token <string> IDENT

%right ASSIGN
%left OR
%left AND
%right NOT
%left LT LTE GT GTE EQ NEQ
%left ADD SUB
%left MULT DIV MOD
%right UMINUS
%left L_SQUARE_BRACKET R_SQUARE_BRACKET
%left L_PAREN R_PAREN 

%type <string> program function ident stmt-loop
%type <dec_type> declaration-loop declaration stmt-loop
%type <list<string>> ident-loop var-loop

%start start_prog

%%
start_prog: program {cout << $1 << endl;}

program: program function {$$ = $1 + "\n" + $2;}
		| /*epsilon*/ {$$ = "";}
		;
		
declaration-loop: /*epsilon*/
		{
			$$.code = "";
			$$.ids = list<string>();
		}
	| declaration SEMICOLON declaration-loop
		{
			$$.code = $1.code + $3.code;
			$$.ids = $1.ids;
			for(list<string>::iterator it = $3.ids.begin(); it != $3.ids.end(); it++)
			{
				$$.ids.push_back(*it);
			}
		}
		;
		
function: FUNCTION ident SEMICOLON BEGIN_PARAMS declaration-loop END_PARAMS BEGIN_LOCALS declaration-loop END_LOCALS BEGIN_BODY stmt-loop END_BODY 
		{
			$$ = "funct " + $2 + "\n";
			$$ += $5.code;
			int i = 0;
			for(list<string>::iterator it = $5.ids.begin(); it != $5.ids.end(); it++){
				$$ += *it + " $" + to_string(i) + "\n";
				i++;
			}
			$$ += $8.code;
			$$ += $11.code;
			i = 0;
			for(list<string>::iterator it = $11.ids.begin(); it != $11.ids.end(); it++){
				$$ += *it + " $" + to_string(i) + "\n";
				i++;
			}
			$$ += "endfunc";  
		}
		;
		
ident-loop: ident {$$.push_back($1);}
	| ident COMMA ident-loop 
		{
			$$ = $3; 
			$$.push_front($1);
		}
		; 
		
declaration: ident-loop COLON INTEGER
		{
			for(list<string>::iterator it = $1.begin(); it != $1.end(); it++)
			{
				$$.code += ". " + *it + "\n";
				$$.ids.push_back(*it);
			}
		}
	| ident-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
		{
			for(list<string>::iterator it = $1.begin(); it != $1.end(); it++)
			{
				$$.code += ".[] " + *it + ", " + to_string($5);
				$$.ids.push_back(*it);
			}
		}
	| ident-loop COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
		{
			for(list<string>::iterator it = $1.begin(); it != $1.end(); it++)
			{
				$$.code += ".[] " + *it + ", " + to_string($5*$8);
				$$.ids.push_back(*it);
			}
		}
		;
		
stmt-loop: /*epsilon*/ 
		{
			$$.code = "";
			$$.ids = list<string>();
		}
	| statement SEMICOLON stmt-loop 
		{
			$$.code = $1.code + $3.code;
			$$.ids = $1.ids;
			for(list<string>::iterator it = $3.ids.begin(); it != $3.ids.end(); it++)
			{
				$$.ids.push_back(*it);
			}
		}
		;

var-loop: var 
		{
			for(list<string>::iterator it = $1.begin(); it != $1.end(); it++)
			{
				$$.code += "var = " + *it + "\n";
				$$.ids.push_back(*it);
			}
		}
		| var COLON var-loop
		{	
			for(list<string>::iterator it = $1.begin(); it != $1.end(); it++)
				{
				$$.code += "var = " + *it + "\n";
				$$.ids.push_back(*it);
			}
			for(list<string>::iterator it = $3.begin(); it != $3.end(); it++)
				{
				$$.code += "var = " + *it + "\n";
				$$.ids.push_back(*it);
			}
		}	
		;
		
statement: var ASSIGN expression 
		{/* comp dst(var), src1(expression), src2*/
			$$ = $3.comp + " " + $1.name + " " + $3.code;
			$$ = $1.code;
			for(list<string>::iterator it = $1.ids.begin(); it != $1.ids.end(); it++){
				$$ += *it + " $" + to_string(i) + "\n";
				i++;
			}
			$$ = $3.code;
			for(list<string>::iterator it = $3.ids.begin(); it != $3.ids.end(); it++){
				$$ += *it + " $" + to_string(i) + "\n";
				i++;
			}
		}
	| IF bool-expr THEN stmt-loop ENDIF {}
	| IF bool-expr THEN stmt-loop ELSE stmt-loop ENDIF {}
	| WHILE bool-expr BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP {}
	| DO BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP WHILE bool-expr {}
	| FOR var ASSIGN NUMBER SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP {}
	| READ var-loop {$$ = "." + $2;}
	| WRITE var-loop {$$ = "." + $2;}
	| CONTINUE {printf("stmt-> continue my misery + "\n");}
	| RETURN expression {$$ = "ret" + $2;}
		;

bool-expr:relation-and-expr{$$ = $1;}
	| bool-expr OR relation-and-expr {$$ = "|| " + $1 + ", " + $3;}
		;
		
relation-and-expr: relation-expr {$$ = $1;}
	| relation-and-expr AND relation-expr  {$$ = "&& " + $1 + ", " + $3 ;}
		;
		
relation-expr: expression comp expression {$$ = $2 + $1 + $3;}
	| NOT expression comp expression {$$ = $3 + $$ + + "\n" "!" + $3+ "\n";}
	| TRUE {$$ = "true";}
	| NOT TRUE {$$ = "false";}
	| FALSE {$$ = "false";}
	| NOT FALSE {$$ = "true";}
	| L_PAREN bool-expr R_PAREN {$$ = $2;}
	| NOT L_PAREN bool-expr R_PAREN {$$ = "! " + $$ + ", " + $2;}
		;
		
comp: EQ {$$ = "==";}
	| NEQ {$$ = "!=";}
	| LT {$$ = "<";}
	| LTE {$$ = "<=";}
	| GT {$$ = ">";}
	| GTE {$$ = ">=";}
		;
		
expression: mult-expr{$$ = }
	| expression ADD mult-expr {$$ = "+" + $1 + $3;}
	| expression SUB mult-expr {$$ = "-" + $1 + $3;}
		;


mult-expr:term {$$ = $1;}
	| mult-expr MULT term {$$ = "*" + $1 + $3;}
	| mult-expr DIV term {$$ = "/" + $1 + $3;}
	| mult-expr MOD term {$$ = "%" + $1 + $3;}
		;
		
term-loop: /*epsilon*/ {$$ = "";}
	| expression {$$ = $1;}
	| term-loop COMMA expression{printf($$ = $1 + ", " + $3;}
		;
		
term: var {$$ = $1}
	| SUB %prec UMINUS var {$$ = "-" + $4;}
	| NUMBER {$$ = to_string($1);}
	| SUB %prec UMINUS NUMBER {$$ = "-" + to_string($4);}
	| L_PAREN expression R_PAREN{$$ = $2;}
	| SUB %prec UMINUS L_PAREN expression R_PAREN {$$ = "+" + $5;}
	| ident L_PAREN term-loop R_PAREN {
		$$.push_front($1);
		$$ = $3;
		
		}
		;
		
var: ident {$$.push_back($1);}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET 
		{
			$$ = $3;
			$$.push_front($1);
			
		}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET
		{
			$$ = $3 + $6;
			$$.push_front($1);
		}
		;
		
ident: IDENT {$$ = $1;}
		;
%%

int main(int argc, char *argv[])
{
	yy::parser p;
	return p.parse();
}

void yy::parser::error(const yy::location& l, const std::string& m)
{
	std::cerr << l << ": " << m << std::endl;
}