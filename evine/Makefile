evine : grammar.tab.c lexicalAnalyzer.lex.c  
	gcc -g -Wall -o evine grammar.tab.c lexicalAnalyzer.lex.c -lm -lfl
grammar.tab.c : grammar.y  
	bison -d -W --report=state grammar.y
lexicalAnalyzer.lex.c : lanalyser.l 
	flex -o lexicalAnalyzer.lex.c lanalyser.l
clean:
	rm -f evine grammar.tab.c lexicalAnalyzer.lex.c
