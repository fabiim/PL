
teste_bibBase : include/dictlist.o include/hashing.o include/common.o bibBase.o t_bibBase.o
	gcc -Wall -g  -o teste t_bibBase.o bibBase.o include/dictlist.o include/hashing.o include/common.o 
dictlist.o : include/dictlist.c include/dictlist.h
	cd include ; gcc -Wall  -g -c dictlist.c 
hashing.o : include/hashing.c include/hashing.h
	cd include ; gcc -Wall -g -chashing.c 
common.o : include/common.c include/common.h
	cd include ; gcc -Wall -g -c common.c 
t_bibBase.o: t_bibBase.c 
	gcc -Wall -g -c t_bibBase.c
bibBase.o : bibBase.c bibBase.h
	gcc -Wall -g -c bibBase.c 
clean : 
	rm -rf *.o ; cd include rm -rf *.o ; rm -rf *~; 
