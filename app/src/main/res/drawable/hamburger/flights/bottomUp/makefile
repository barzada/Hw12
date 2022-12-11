CC = gcc

OBJECTS = lex.yy.o madonna.tab.o

# 'madonna' is the name of the executable file.
# Use 'madonna.exe'  on Windows
madonna: $(OBJECTS)
	$(CC) $(OBJECTS)  -o madonna


lex.yy.c: madonna.lex
	flex madonna.lex
	
madonna.tab.c madonna.tab.h: madonna.y
	bison -d madonna.y
	
lex.yy.o: lex.yy.c madonna.tab.h

madonna.tab.o: madonna.tab.c
	$(CC) -c madonna.tab.c

clean:
	rm -f madonna madonna.tab.c madonna.tab.h lex.yy.c $(OBJECTS)
	
	