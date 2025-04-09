all:	
	./buildall

steg1:	driver.c parser.c
	gcc -Wall -o parser driver.c parser.c

steg2:	driver.c parser.c keytoktab.c
	gcc -Wall -o parser driver.c parser.c keytoktab.c

steg3:	driver.c parser.c keytoktab.c lexer.c
	gcc -Wall -o parser driver.c parser.c keytoktab.c lexer.c

steg4:	driver.c parser.c keytoktab.c lexer.c symtab.c
	gcc -Wall -o parser driver.c parser.c keytoktab.c lexer.c symtab.c

steg5:	driver.c parser.c keytoktab.c lexer.c symtab.c optab.c
	gcc -Wall -o parser driver.c parser.c keytoktab.c lexer.c symtab.c optab.c

clean:	
	rm -rf parser
	rm -rf *.out
