#include "matriz_lista_string.h"

matrix_t* matrixNew(uint32_t m, uint32_t n){
	matrix_t* new = malloc(sizeof(matrix_t));
	new->dataType = 3;
	new->remove = NULL;	
	new->print = NULL;
	new->m = m;		
	new->n = n;
	new->data = malloc(m*8*n);
	uint32_t tam_fila = m;
	for(uint32_t fila = 0; fila < new->n ; fila++){
		for(uint32_t i = 0; i < new->m ; i++){
			(new->data) [i+fila*tam_fila] = NULL;
		}
	}
	return new;
} 

void matrixPrint(matrix_t* m, FILE *pFile) {
	uint32_t sizeR= (m->m);
	for(uint32_t r = 0; r < m->n; r++ ){
		fprintf(pFile,"|");			
		for(uint32_t c = 0; c < m-> m; c++){
			
			if( (m->data)[c+r*sizeR] == NULL){
				fprintf(pFile,"NULL");
				if(c+1 != m-> m){
					fprintf(pFile,"|");								
				}else{  
					fprintf(pFile,"|\n");							
				}
			}else{
				funcPrint_t* print = (funcPrint_t*)( ((matrix_t *)((m->data)[c+r*sizeR]))->print );
				print (m->data[c+r*sizeR], pFile);

				if(c+1 != m-> m){
					fprintf(pFile,"|");								
				}else{  
					fprintf(pFile,"|\n");					
									
				}
			}
		}
	}
}

