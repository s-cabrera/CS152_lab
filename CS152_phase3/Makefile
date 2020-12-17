parse: mini.lex mini.yy
	bison -v -d --file-prefix=parser mini.yy
	flex mini.lex
	g++ -std=c++11 -o parser parser.tab.cc lex.yy.c -lfl

clean:
	rm -f lex.yy.c parser.tab.* parser.output *.o parser