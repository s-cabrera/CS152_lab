parse: mini.lex mini.y
	bison -v -d --file-prefix=y mini.yy
	flex mini.lex
	gcc -o parser y.tab.c lex.yy.c -lfl

clean:
	rm -f lex.yy.c y.tab.* y.output *.o parser