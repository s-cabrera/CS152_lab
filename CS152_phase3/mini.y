%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <list>
 #include <string>
 #include <functions> 
 void yyerror(const char *msg);
 extern int currLine;
 extern int currPos;
 extern const char * yytext;
 FILE * yyin;
%}

%error-verbose
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO FOR BEGINLOOP ENDLOOP CONTINUE 
%token READ WRITE 
%token AND OR NOT TRUE FALSE RETURN
%token NUMBER IDENT
%token SUB ADD MULT DIV MOD EQ NEQ LTE GTE LT GT
%token SEMICOLON L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET COLON COMMA ASSIGN
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
%type <dec_type> declaration-loop declaration
%type <list<string>> ident-loop

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
			$$.code = $1.code + "\n" + $3.code
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
			$$ += $11;
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
				$$.code += ". " + *it;
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
		
stmt-loop: /*epsilon*/ {$$ = "";}
	| statement SEMICOLON stmt-loop {printf("stmt-loop --> statement SEMICOLON stmt-loop\n");}
		;

var-loop: var {printf("var-loop --> var \n");}
	| var COLON var-loop{printf("var-loop --> var COLON var-loop\n");}
	;
		
statement: var ASSIGN expression {printf("statement --> var ASSIGN expression \n");}
	| IF bool-expr THEN stmt-loop ENDIF {printf("statement --> IF bool-expr THEN stmt-loop ENDIF\n");}
	| IF bool-expr THEN stmt-loop ELSE stmt-loop ENDIF {printf("statement --> IF bool-expr THEN stmt-loop ELSE stmt-loop ENDIF\n");}
	| WHILE bool-expr BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP {printf("statement --> WHILE bool-expr BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP\n");}
	| DO BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP WHILE bool-expr {printf("statement --> DO BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP WHILE bool-expr\n");}
	| FOR var ASSIGN NUMBER SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP {printf("FOR var ASSIGN NUMBER SEMICOLON bool-expr SEMICOLON var ASSIGN expression BEGINLOOP statement SEMICOLON stmt-loop ENDLOOP\n");}
	| READ var-loop {printf("statement --> READ var-loop\n");}
	| WRITE var-loop {printf("statement --> WRITE var-loop\n");}
	| CONTINUE {printf("statement --> CONTINUE\n");}
	| RETURN expression {printf("statement --> RETURN expression\n");}
		;

bool-expr:relation-and-expr{printf("bool-expr --> relation-and-expr\n");}
	| bool-expr OR relation-and-expr {printf("bool-expr --> bool-expr OR relation-and-expr\n");}
		;
		
relation-and-expr: relation-expr {printf("relation-and-expr --> relation-expr\n");}
	| relation-and-expr AND relation-expr  {printf("relation-and-expr-loop --> relation-and-expr AND relation-expr\n");}
		;
		
relation-expr: expression comp expression {printf("relation-expr --> expression comp expression\n");}
	| NOT expression comp expression {printf("relation-expr --> NOT expression comp expression\n");}
	| TRUE {printf("relation-expr --> TRUE\n");}
	| NOT TRUE {printf("relation-expr --> NOT TRUE\n");}
	| FALSE {printf("relation-expr --> FALSE\n");}
	| NOT FALSE {printf("relation-expr --> NOT FALSE\n");}
	| L_PAREN bool-expr R_PAREN {printf("relation-expr --> L_PAREN bool-expr R_PAREN\n");}
	| NOT L_PAREN bool-expr R_PAREN {printf("relation-expr --> NOT L_PAREN bool-expr R_PAREN\n");}
		;
		
comp: EQ {printf("comp --> EQ\n");}
	| NEQ {printf("comp --> NEQ\n");}
	| LT {printf("comp --> LT\n");}
	| LTE {printf("comp --> LTE\n");}
	| GT {printf("comp --> GT\n");}
	| GTE {printf("comp --> GTE\n");}
		;
		
expression: mult-expr{printf("expression --> mult-expr\n");}
	| expression ADD mult-expr {printf("expression --> expression PLUS mult-expr \n");}
	| expression SUB mult-expr {printf("expression --> expression SUB mult-expr \n");}
		;


mult-expr:term {printf("mult-expr --> term \n");}
	| mult-expr MULT term {printf("mult-expr --> mult-expr MULT term \n");}
	| mult-expr DIV term {printf("mult-expr --> mult-expr DIV term \n");}
	| mult-expr MOD term {printf("mult-expr --> mult-expr MOD term \n");}
		;
		
term-loop: /*epsilon*/ {$$ = "";}
	| expression {printf("term-loop --> expression\n");}
	| term-loop COMMA expression{printf("term-loop --> term-loop COMMA expression \n");}
		;
		
term: var {printf("term --> var\n");}
	| SUB %prec UMINUS var {printf("term --> UMINUS var \n");}
	| NUMBER {printf("term --> NUMBER \n");}
	| SUB %prec UMINUS NUMBER {printf("term --> UMINUS NUMBER\n");}
	| L_PAREN expression R_PAREN{printf("term --> L_PAREN expression R_PAREN\n");}
	| SUB %prec UMINUS L_PAREN expression R_PAREN {printf("term --> UMINUS L_PAREN expression R_PAREN\n");}
	| ident L_PAREN term-loop R_PAREN {printf("term --> ident L_PAREN expression R_PAREN\n");}
		;
		
var: ident {printf("var --> ident \n");}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var --> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET \n");}
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET {printf("var --> ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET L_SQUARE_BRACKET expression R_SQUARE_BRACKET\n");}
		;
		
ident: IDENT {$$ = $1;}
		;
%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}
