parse: mini.lex mini.y
	bison -v -d --file-prefix=y mini.y
	flex mini.lex
	gcc -o mini y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o calc