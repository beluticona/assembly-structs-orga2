#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>

#include "matriz_lista_string.h"

void test_lista(FILE *pfile){
	list_t* l;
	integer_t* i;
	fprintf(pfile,"TEST CASO LISTA: Creo y agrego elementos\n");
	l = listNew();
	l = listAdd(l,intSet(intNew(),34),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),42),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),13),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),44),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),58),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),11),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	l = listAdd(l,intSet(intNew(),92),(funcCmp_t*)&intCmp); listPrint(l,pfile); fprintf(pfile,"\n");
	listPrint(l,pfile); fprintf(pfile,"\n");
	fprintf(pfile,"CASO LISTA: Elimino el 13 y 58\n");
	i = intSet(intNew(),13); listRemove(l,(void*)i,(funcCmp_t*)&intCmp); intDelete(i);
	i = intSet(intNew(),58); listRemove(l,(void*)i,(funcCmp_t*)&intCmp); intDelete(i);
	listPrint(l,pfile); fprintf(pfile,"\n");
	listDelete(l);
	fprintf(pfile,"FIN CASO LISTA\n");
}

void test_matrix(FILE *pfile){
	list_t* l; list_t* l2;list_t* l3;list_t* l4;list_t* l5;list_t* l6; list_t* l7; list_t* l8;list_t* l9;list_t* l10;


	matrix_t* m;

	fprintf(pfile,"TEST CASO MATRIZ: Creo y agrego elementos\n");
	m = matrixNew(4,5);

	l = listAddFirst( listAddFirst(listAddFirst(listNew(),intSet(intNew(),3) ), intSet(intNew(),2) ), intSet(intNew(),1) );
	m = matrixAdd(m,1,0, l);

	l2 = listAddFirst(listAddFirst( listAddFirst(listNew(),strSet(strNew(),"SA" )), strSet(strNew(),"RA" ) ), strSet(strNew(),"SA") );
	l3 = listAddFirst(listAddFirst( listAddFirst(listNew(),strSet(strNew(),"SA" )), strSet(strNew(),"RA" ) ), strSet(strNew(),"SA") );
	 m = matrixAdd(m,2,0, l2);
	 m = matrixAdd(m,2,1, l3);

	l4 = listAddFirst( listAddFirst(listAddFirst(listNew(),intSet(intNew(),3)), intSet(intNew(),2) ), listNew());
	m = matrixAdd(m,1,1, l4);

	l5 = listAddFirst( listAddFirst(listAddFirst(listNew(),intSet(intNew(),3)), listNew() ), listNew());
	m = matrixAdd(m,1,2, l5);

	m = matrixAdd(m,3,2, intSet(intNew(),35));

	l6 = listAddFirst( listNew(),listAddFirst( listNew(),strSet(strNew(),"SA")) );
	l6 = listAddFirst( l6, listAddFirst( listNew(),strSet(strNew(),"RA")) );
	l6 = listAddFirst( l6, listAddFirst( listNew(),strSet(strNew(),"SA")) ); 
	 m = matrixAdd(m,2,2, l6);

	l7 = listAddFirst( listNew(),listAddFirst( listNew(),strSet(strNew(),"SA")) );
	l7 = listAddFirst( l7, listAddFirst( listNew(),strSet(strNew(),"RA")) );
	l7 = listAddFirst( l7, listAddFirst( listNew(),strSet(strNew(),"SA")) ); 
	 m = matrixAdd(m,1,3, l7);

	m = matrixAdd(m,3,3, intSet(intNew(),32));

	l8 = listAddFirst( listAddFirst(listAddFirst(listNew(),intSet(intNew(),3) ),  listAddFirst( listNew(),intSet(intNew(),2)) ), intSet(intNew(),1) );
	m = matrixAdd(m,2,3, l8);

	m = matrixAdd(m,3,4, intSet(intNew(),31));
	m = matrixAdd(m,2,4, intSet(intNew(),8));


	l9 = listAddFirst(listAddFirst( listAddFirst(listNew(),intSet(intNew(),33)), strSet(strNew(),"ra" ) ), strSet(strNew(),"ra" ) );

	l10 = listAddFirst(listAddFirst( listAddFirst(listNew(),intSet(intNew(),35)), strSet(strNew(),"ro" ) ), strSet(strNew(),"ro" ) );

	m = matrixAdd(m,1,4, listAddFirst(listAddFirst ( listNew(), l10), l9)   );

	matrixPrint(m,pfile); fprintf(pfile,"\n");
	fprintf(pfile,"FIN CASO MATRIZ\n");
	matrixDelete(m); fprintf(pfile,"\n");



/*
|NULL|[1,2,3]|[SA,RA,SA]|NULL|
|NULL|[[],2,3]|[SA,RA,SA]|NULL|
|NULL|[[],[],3]|[[SA],[RA],[SA]]|35|
|NULL|[[SA],[RA],[SA]]|[1,[2],3]|32|
|NULL|[[ra,ra,33],[ro,ro,35]]|8|31|
}
*/
}
int main (void){
	FILE *pfile = fopen("salida.casos.propios.txt","a");
	test_lista(pfile);
	test_matrix(pfile);
	fclose(pfile);
	return 0;    
}


