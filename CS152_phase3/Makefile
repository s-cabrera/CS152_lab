parse: mini.lex mini.y
	bison -v -d --file-prefix=parser mini.y
	flex mini.lex
	g++ -std=c++11 -o parser parser.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c parser.tab.* parser.output *.o parser