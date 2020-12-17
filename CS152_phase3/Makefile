parse: mini.lex mini.y
	bison -v -d --file-prefix=parser mini.y
	flex mini.lex
	gcc -o parser parser.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser