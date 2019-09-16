; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf

section .data

	format_integer: DB '%d', 0
	format_string: DB '%s', 0
	msg_NULL: DB 'NULL', 0
	msg_closed_bracket: DB ']', 0
	msg_coma: DB ',', 0
	msg_opened_bracket: DB '[', 0 


section .text

; MATRIX
	global matrixAdd
	global matrixRemove
	global matrixDelete

; LIST
	global listNew
	global listAddFirst
	global listAddLast
	global listAdd
	global listRemove
	global listRemoveFirst
	global listRemoveLast
	global listDelete
	global listPrint

; STRING
	global strNew
	global strSet
	global strAddRight
	global strAddLeft
	global strRemove
	global strDelete
	global strCmp
	global strPrint

; INTEGER
	global intNew
	global intSet
	global intRemove
	global intDelete
	global intCmp
	global intPrint

; AUXILIARES
	global str_len
	global str_copy
	global str_cmp
	global str_concat
	global newNode
	global deleteNode
	global findPositionInMatrix

; DEFINES

	%define offset_dataType 0
	%define offset_remove 8
	%define offset_print 16
	%define offset_data 24

	%define size_integer 32
	%define size_string 32
	%define size_list 32
	%define size_node 16
	%define offset_first 24
	
	%define offset_node_data 0
	%define offset_node_next 8

	%define offset_matrix_col 24
	%define offset_matrix_row 28
	%define offset_matrix_data 32

	%define NULL 0
	%define qword_size 8
	%define TRUE 1
	%define EQUAL 0
	%define matriz_data_size 8
	
;/***************************************** FUNCTIONS: MATRIX ***********************************************/


	; matrix_t* matrixAdd(matrix_t* m, uint32_t x, uint32_t y, void* data);
	matrixAdd:
		; RDI<-matrix ESI <-x EDX<-y RCX<-data
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		PUSH R12
		PUSH R13
		SUB RSP, qword_size		
	
		MOV R12, RCX
		MOV RBX, RDI
		CALL findPositionInMatrix			; RAX<-matrix[y][x]

		; RAX has the position where the data will be saved
		MOV R13, RAX

		CMP QWORD[R13], NULL
		JE .writeData
		; overwriting
		MOV RDI, [RAX]
		MOV R8, QWORD[RDI+offset_remove]	; set remove function to call
		CALL R8	
	
	.writeData:	
		MOV [R13], R12			; save the data

			
		MOV RAX, RBX			; return matrix struct
		ADD RSP, qword_size
		POP R13
		POP R12
		POP RBX
		POP RBP	
		RET
	
	
	; matrix_t* matrixRemove(matrix_t* m, uint32_t x, uint32_t y);
	matrixRemove:
		; RDI<-matrix ESI <-x EDX<-y 
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI

		CALL findPositionInMatrix

		; RAX has the position of the struct to delete
		CMP QWORD[RAX], NULL
		JE .nothingToRemove

		MOV RDI, [RAX]
		MOV QWORD[RAX], NULL			; set NULL in its matrix position

		MOV R8, QWORD[RDI+offset_remove]	; set remove function to call
		CALL R8

	.nothingToRemove:
		MOV RAX, RBX				; return matrix struct

		ADD RSP, qword_size
		POP RBX
		POP RBP	
		RET
	
	; void matrixDelete(matrix_t* m);
	matrixDelete:
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		PUSH R12
		PUSH R13	
		SUB RSP, qword_size	

		MOV RBX, RDI
		
		XOR R12, R12
		XOR R13, R13
		; explore matrix (1,1)(1,0)(0,1)(0,0)
		MOV R12d, DWORD[RBX+offset_matrix_col]			
		MOV R13d, DWORD[RBX+offset_matrix_row]	
		DEC R12						; R12 <-matrixCol-1
		DEC R13						; R13 <-matrixRow-1
		
		; CALL matrixRemove RDI<-matrix ESI <-x EDX<-y 
	.continueRemoving:	
		MOV RDI, RBX
		MOV ESI, R12d
		MOV EDX, R13d
		CALL matrixRemove
		
		CMP R12d, 0					; if(x==0)
		JE .colZero
		DEC R12						; x--
		JMP .continueRemoving

	.colZero:
		CMP R13d, 0					; removed the first position (0,0)
		JE .deleteMatrixStruct
		MOV R12d, [RBX+offset_matrix_col]		
		DEC R12						; reset R12<-matrixCol-1
		DEC R13						; y--		
		JMP .continueRemoving		
		
	.deleteMatrixStruct:
		MOV RDI, [RBX+offset_matrix_data]		; free matrix data
		CALL free
		
		MOV RDI, RBX
		CALL free					; delete matrix struct

		ADD RSP, qword_size	
		POP R13
		POP R12
		POP RBX
		POP RBP	
		RET

;/***************************************** FUNCTIONS: LIST ***********************************************/

	; list_t* listNew();
	listNew:
		PUSH RBP
		MOV RBP, RSP
	
		MOV RDI, size_list
		CALL malloc

		MOV DWORD[RAX+offset_dataType], 3
		MOV QWORD[RAX+offset_remove], listDelete
		MOV QWORD[RAX+offset_print], listPrint
		MOV QWORD[RAX+offset_first], NULL  	 

		POP RBP
		RET

	; list_t* listAddFirst(list_t* l, void* data);
	listAddFirst:
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI					; RBX <-list
		MOV RDI, RSI					; RDI <-data set data as input to newNode function call
		CALL newNode					; create a new list node that already has data
		; return in RAX newNode
		MOV R8, QWORD[RBX+offset_first]			; if it was empty, R8 es NULL
		MOV QWORD[RAX+offset_node_next], R8		; RAX has the new node, set the next list elem

		MOV QWORD[RBX+offset_first], RAX		; set the new first element of list
		MOV RAX, RBX					; set changed list as output
		
		ADD RSP, qword_size
		POP RBX
		POP RBP
		RET
			
	; list_t* listAddLast(list_t* l, void* data);
	listAddLast:
		CMP QWORD[RDI+offset_first], NULL
		JE .emptyList
				
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI				; RBX<-list
		MOV RDI, RSI
		CALL newNode
		MOV QWORD[RAX+offset_node_next], NULL	; RAX--NULL
		; RAX<-newNode(data)			
			
		MOV R8, QWORD[RBX+offset_first]		; R8<-firstListElem R8 list_iterator 													
	.cicle:
		CMP QWORD[R8+offset_node_next], NULL	; is R8 the last list element?		
		JE .lastElem		
		MOV R8, [R8+offset_node_next]
		JMP .cicle
 		
	.lastElem:					; list--R8--NULL
		MOV [R8+offset_node_next], RAX		; add next to the last node the new one list--R8--RAX--NULL
		
		MOV RAX, RBX				; return modified list in RAX
		
		ADD RSP, qword_size
		POP RBX
		POP RBP
		RET

	.emptyList:
		CALL listAddFirst
		RET
	
	; list_t* listAdd(list_t* l, void* data, funcCmp_t* f);
	listAdd:
		PUSH RBP
		MOV RBP, RSP
	
		CMP QWORD[RDI+offset_first], NULL
		JE .emptyList
				
		PUSH RBX
		PUSH R12
		PUSH R13
		PUSH R14
		PUSH R15

		MOV RBX, RDI				; need to return the list
		MOV R13, RSI				; save data to compare
		MOV R12, RDX				; save the funcion to be called

		
		MOV R14, [RBX+offset_first]		; list has at least a node

	.cicle:
		MOV RDI, R13				; set our data
		MOV RSI, [R14+offset_node_data]		; set node's datum
		CALL R12				; RAX<- 1 if(data < node) then insert it just before this R14 node
		CMP RAX, TRUE				; 
		JE .insertBefore
		
		CMP QWORD[R14+offset_node_next], NULL	;
		JE .insertLast
		MOV R15, R14				; save pre node
		MOV R14, QWORD[R14+offset_node_next]
		JMP .cicle
	
		
	.insertBefore:
		CMP R14, [RBX+offset_first]
		JE .addFirst
		
		MOV RDI, R13
		CALL newNode		
		
		MOV [R15+offset_node_next], RAX		; insert the new node just before R14, after R15 (pre)
		MOV [RAX+offset_node_next], R14		; list--//-R15--R9(new)--R14--//--NULL where R14>R16

		JMP .exit

	.insertLast:
		MOV RDI, R13
		CALL newNode
		
		MOV QWORD[R14+offset_node_next], RAX	; list--//--R14--NULL
		MOV QWORD[RAX+offset_node_next], NULL	; list--//--R14--RAX--NULL
		
	.exit:  
		MOV RAX, RBX

		POP R15
		POP R14
		POP R13
		POP R12
		POP RBX
		POP RBP
		RET

	.emptyList:
		CALL listAddFirst			; empty list!
		; return in RAX the list
		POP RBP		
		RET

	.addFirst:
		MOV RDI, RBX
		MOV RSI, R13
		CALL listAddFirst 			;(list_t* l, void* data);
		JMP .exit
	
	; list_t* listRemove(list_t* l, void* data, funcCmp_t* f);
	listRemove:
		CMP QWORD[RDI+offset_first], NULL
		JE .emptyList


		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		PUSH R12
		PUSH R13
		PUSH R14
		PUSH R15		


		MOV RBX, RDI				; need to return the list
		MOV R13, RSI				; save data to compare
		MOV R12, RDX				; save the funcion to be called

	.startAgain:
		MOV R14, [RBX+offset_first]		; list has at least a node


	.cicle:
		CMP R14, NULL
		JE .endList
		MOV RDI, R13				; set our data
		MOV RSI, [R14+offset_node_data]		; set node's datum
		CALL R12				; RAX<- 0 if(data == node) then delete R14
		CMP RAX, EQUAL				; 
		JE .deleteThisNode
		MOV R15, R14				; save antecesor list--//--R15-R14--//--NULL
		MOV R14, [R14+offset_node_next]
		JMP .cicle

	.endList:
		MOV RAX, RBX

		POP R15
		POP R14
		POP R13
		POP R12
		POP RBX
		POP RBP
		RET


	.deleteThisNode:
		CMP QWORD[RBX+offset_first], R14		
		JE .deleteFirst
		

		MOV R8, QWORD[R14+offset_node_next]		
		MOV QWORD[R15+offset_node_next], R8

		MOV RDI, R14
		MOV R14, QWORD[R14+offset_node_next]
		CALL deleteNode
		
		MOV R14, QWORD[R15+offset_node_next]
		JMP .cicle


	.deleteFirst:
		MOV RDI, RBX
		CALL listRemoveFirst
		; RAX<-list
		JMP .startAgain



	.emptyList:
		; empty list! nothing to delete
		MOV RAX, RDI					; return in RAX the list
		RET


	
	; list_t* listRemoveFirst(list_t* l);
	listRemoveFirst:
		CMP QWORD[RDI+offset_first], NULL
		JE .exit					; empty list

		PUSH RBP
		MOV RBP, RSP		
	
		PUSH RBX
		PUSH R12

		MOV RBX, RDI					; RBX<-list  
	
		MOV RDI, QWORD[RBX+offset_first]		; RDI<-first to delete
		MOV R12, QWORD[RDI+offset_node_next]		; R12<-second   list--RDI--R12--//--NULL

		CALL deleteNode

		MOV QWORD[RBX+offset_first], R12		; set new first  list--R12--//--NULL

		MOV RAX, RBX					; set list as output	

		POP R12
		POP RBX
		POP RBP
	.exit:	
		RET

	; list_t* listRemoveLast(list_t* l);
	listRemoveLast:
		CMP QWORD[RDI+offset_first], NULL
		JE .exit

		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI				; set list to return
		MOV R9, QWORD[RBX+offset_first]		; R9<-firstListElem R9 list_iterator
		CMP QWORD[R9+offset_node_next], NULL
		JE .oneElement

	.cicle:		
		MOV R8, R9
		MOV R9, QWORD[R8+offset_node_next]	; list--R8--R9-//--NULL
		CMP QWORD[R9+offset_node_next], NULL	; is R9 the last list element?				
		JNE .cicle

		MOV QWORD[R8+offset_node_next], NULL	; set list--R8--NULL
		JMP .delete

	.oneElement:					; list-R9--NULL  --> list--NULL
		MOV QWORD[RBX+offset_first], NULL		
		
	.delete:
		MOV RDI, R9
		CALL deleteNode
		
		MOV RAX, RBX				; return modified list in RAX
		
		ADD RSP, qword_size
		POP RBX
		POP RBP
		RET
	
	.exit:	
		MOV RAX, RDI
		RET
	
	
	; void listDelete(list_t* l);
	listDelete:
		PUSH RBP
		MOV RBP, RSP
		
	.cicle:	
		CMP QWORD[RDI+offset_first], NULL
		JE .deleteStruct 				
		CALL listRemoveFirst
		MOV RDI, RAX
		JMP .cicle

	.deleteStruct:
		
		CALL free
		POP RBP
		RET
	
	; void listPrint(list_t* m, FILE *pFile);
	listPrint:
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		PUSH R12

		MOV RBX, [RDI+offset_first]		; RBX<-first_node
		MOV R12, RSI				; R12<-file

		MOV RDI, R12
		MOV RSI, format_string
		MOV RDX, msg_opened_bracket
		CALL fprintf
		
		CMP RBX, NULL
		JE .end
	.cicle:
		MOV RDI, [RBX+offset_node_data]		; RDI<-data struct
		MOV RSI, R12
		MOV R8, [RDI+offset_print]
		CALL R8					; call print function 
		
		MOV RBX, [RBX+offset_node_next]
		CMP RBX, NULL				; was it the last node?
		JE .end

		MOV RDI, R12
		MOV RSI, format_string			; paso formato string NULL
		MOV RDX, msg_coma			; paso char* msg a imprimir	
		CALL fprintf

		JMP .cicle
		
	.end:
		MOV RDI, R12
		MOV RSI, format_string
		MOV RDX, msg_closed_bracket
		CALL fprintf
			
		POP R12				
		POP RBX
		POP RBP
		RET
	
;/***************************************** FUNCTIONS: STRINGS ***********************************************/

	; string_t* strNew();
	strNew:
		PUSH RBP
		MOV RBP, RSP
	
		MOV RDI, size_string
		CALL malloc

		MOV DWORD[RAX+offset_dataType], 2
		MOV QWORD[RAX+offset_remove], strDelete
		MOV QWORD[RAX+offset_print], strPrint
		MOV QWORD[RAX+offset_data], NULL  	 

		POP RBP
		RET
	
	; string_t* strSet(string_t* s, char* c);
	strSet:
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		
		SUB RSP, qword_size
				
		MOV RBX, RSI				; save char*c
		CALL strRemove				; remove data (RDI already has the struct to be clean) return cleaned struct in RAX
		MOV RDI, RBX				; RDI<-char*c to copy		
		MOV RBX, RAX				; RBX<-struct cleaned
		CALL str_copy				; make a copy of c saved in RAX
		MOV [RBX+offset_data], RAX		; write copy of c in data

		MOV RAX, RBX				; return struct in RAX
		
		ADD RSP, qword_size
		
		POP RBX	
		POP RBP
		RET

	; string_t* strAddRight(string_t* s, string_t* d);
	strAddRight:
		PUSH RBP
		MOV RBP, RSP
		
		PUSH RBX
		PUSH R12
		PUSH R13
		SUB RSP, qword_size

		MOV RBX, RDI			; RBX <-s
		MOV R12, RSI			; R12 <-d
		
		MOV RDI, [RDI+offset_data]
		MOV RSI, [RSI+offset_data]
		
		CALL str_concat
		MOV R13, RAX			; R13 <-s+d
		CMP RBX, R12
		JE .justConcat

		MOV RDI, R12
		CALL strDelete

	.justConcat:
		MOV RDI, RBX
		CALL strRemove
		MOV [RAX+offset_data], R13	; s<-R13
		
		ADD RSP, qword_size
		POP R13
		POP R12
		POP RBX		
		POP RBP
		RET
	
	; string_t* strAddLeft(string_t* s, string_t* d);
	strAddLeft:

		PUSH RBP
		MOV RBP, RSP
		
		PUSH RBX
		PUSH R12
		PUSH R13
		SUB RSP, qword_size

		MOV RBX, RDI			; RBX <-s
		MOV R12, RSI			; R12 <-d

		MOV RSI, [RBX+offset_data]
		MOV RDI, [R12+offset_data]		
		
		CALL str_concat
		MOV R13, RAX			; R13 <-s+d
		CMP RBX, R12
		JE .justConcat

		MOV RDI, R12
		CALL strDelete

	.justConcat:
		MOV RDI, RBX
		CALL strRemove
		MOV [RAX+offset_data], R13			; s<-R13
		; RAX output struct
		ADD RSP, qword_size
		POP R13
		POP R12
		POP RBX		
		POP RBP
		RET
	
	; string_t* strRemove(string_t* s);
	strRemove:
		PUSH RBP
		MOV RBP, RSP
		
		CMP QWORD[RDI+offset_data], NULL	; if char* data isnt null
		MOV RAX, RDI
		JE .exit				; then there is something to remove
							; return struct	
		PUSH R12

		MOV R12, RDI				; save struct to return	

		MOV RDI, [R12+offset_data]		; guardo la dirección del data en RDI
		MOV QWORD[R12+offset_data], NULL	; escribo que char* data ahora es NULL	
		CALL free				; borro estructura del char* data

		MOV RAX, R12				; retorno struct modificado
	
		POP R12
	.exit:	
		POP RBP
		RET
	
	; void strDelete(string_t* s);
	strDelete:
		PUSH RBP
		MOV RBP, RSP

		; RDI tiene el struct que le paso a intRemove
	
		CALL strRemove			; recibo en RAX el struct modificado
		MOV RDI, RAX			; muevo el struct a borrar
		CALL free			; borro struct

		POP RBP
		RET
	
	; int32_t strCmp(string_t* a, string_t* b);
	strCmp:
		PUSH RBP
		MOV RBP, RSP

		MOV RDI, [RDI+offset_data]
		MOV RSI, [RSI+offset_data]
		CALL str_cmp
		; in EAX is the output
		POP RBP
		RET
	
			
	
	; void strPrint(string_t* m, FILE *pFile);
	strPrint:

		PUSH RBP
		MOV RBP, RSP
	
		MOV R8, RDI				; guardo struct m
		MOV RDI, RSI				; guardo file listo para llamar a fprintf
		MOV RSI, format_string
	
		CMP QWORD[R8+offset_data], NULL		; if(noHayStringCargado) en el struct
		JE .printNull				; then print NULL
		; else hay string cargado para imprimir
		MOV RDX, QWORD[R8+offset_data]		; guardo dirección del string data en RDX

		; paso parámetros para imprimir entero fprintf

		; en RDI file listo!
		; en RSI formato listo! 
		JMP .llamarPrint	

	.printNull:
		; paso parámetros para imprimir NULL fprintf
		;RDI ya listo!
		; en RSI formato listo!
		MOV RDX, msg_NULL			; paso char* msg_NULL a imprimir

	.llamarPrint:
		CALL fprintf
		; nada que retornar	
		POP RBP
		RET
	
;/***************************************** FUNCTIONS: INTEGERS ***********************************************/




	; integer_t* intNew();
	intNew:
		PUSH RBP
		MOV RBP, RSP
	
		MOV RDI, size_integer
		CALL malloc

		MOV DWORD[RAX+offset_dataType], 1
		MOV QWORD[RAX+offset_remove], intDelete
		MOV QWORD[RAX+offset_print], intPrint
		MOV QWORD[RAX+offset_data], NULL  	 

		POP RBP
		RET
	
	; integer_t* intSet(integer_t* i, int d);
	intSet:
		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		PUSH R12	

		MOV RBX, RDI				; guardo struct
		MOV R12d, ESI				; guardo int d
		CMP QWORD[RBX+offset_data], NULL	;if (sinDato) then crearlo
		JE .crearDato
		
		MOV R8, QWORD[RBX+offset_data]		; guardo en RBP el puntero a int* data que ya existe
		MOV DWORD[R8], R12d			; escribo en data el int d guardado
	
	.exit:	POP R12
		POP RBX	
		POP RBP
		RET

	.crearDato:	
		MOV RDI, 4				; paso tamaño del int
		CALL malloc				; pido memoria de Dato	
		MOV DWORD[RAX], R12d			; escribo en Dato el int d
		MOV R12, RBX				; guardo dirección del struct para retornar
		MOV [RBX+offset_data], RAX		; corro RBX para escribir en el struct en int* data
	
		MOV RAX, R12				; setteo dirección de retorno del struct
		JMP .exit
	

	; integer_t* intRemove(integer_t* i);
	intRemove:
		PUSH RBP
		MOV RBP, RSP
		
		CMP QWORD[RDI+offset_data], NULL	; if int* data  no es nulo
		JNE  .removerData			; then hay que remover
	
		MOV RAX, RDI		; retorno el struct
	
	.exit:	POP RBP
		RET

	.removerData:
		PUSH RBX
		PUSH R12
		MOV R12, RDI				; guardo struct para retornar 	

		MOV RDI, [R12+offset_data]		; guardo la dirección del data en RDI
		MOV QWORD[R12+offset_data], NULL	; escribo que int*data ahora en NULL	
		CALL free				; borro estructura del int data

		MOV RAX, R12				; retorno struct modificado
	
		POP R12
		POP RBX
		JMP .exit		

	
	; void intDelete(integer_t* i);
	intDelete:
		PUSH RBP
		MOV RBP, RSP

		; RDI tiene el struct que le paso a intRemove
	
		CALL intRemove			; recibo en RAX el struct modificado
		MOV RDI, RAX			; muevo el struct a borrar
		CALL free			; borro struct

		POP RBP
		RET
	
	; int32_t intCmp(integer_t* a, integer_t* b);
	intCmp:
		PUSH RBP
		MOV RBP,RSP
	
		MOV R8, [RDI+offset_data]	; guardo direccion de int A
		MOV R9, [RSI+offset_data]	; guardo direccion de int B

		XOR RAX, RAX			; parámetro a retornar setteo en 0

		MOV R10d, DWORD[R9]		; guardo data del struct B en R13
		CMP DWORD[R8], R10d 		; comparo A vs B
		JL .menor			; a < b devuelve 1
		JG  .mayor			; a > b devuelve -1
		;es equal
		JMP .exit			; retorno RAX con cero
	.menor:
		INC EAX				; retorno eax con 1
		JMP .exit
	.mayor:
		DEC EAX				; retorno eax con -1
	.exit:	
		POP RBP
		RET

	
	; void intPrint(integer_t* m, FILE *pFile);
	intPrint:
		PUSH RBP
		MOV RBP, RSP
	
		MOV R8, RDI				; guardo struct m
		MOV RDI, RSI				; guardo file listo para llamar a fprintf
	
		CMP QWORD[R8+offset_data], NULL		; if(noHayEnteroCargado) en el struct
		JE .printNull				; then print NULL
		; else hay entero cargado para imprimir
		MOV R9, QWORD[R8+offset_data]		; guardo dirección del int data en R9

		; paso parámetros para imprimir entero fprintf

		; en RDI file listo!
		MOV RSI, format_integer			; paso formato
		MOV EDX, DWORD[R9]			; paso int a imprimir
		JMP .llamarPrint	

	.printNull:
		; paso parámetros para imprimir NULL fprintf
		;RDI ya listo!
		MOV RSI, format_string		; paso formato string NULL
		MOV RDX, msg_NULL			; paso char* msg_NULL a imprimir

	.llamarPrint:
		CALL fprintf
		; nada que retornar	
		POP RBP
		RET
		


;/***************************************** OTHER FUNCTIONS ***********************************************/

		

	; uint32_t str_len(char* a)
		; pre: a != NULL
		; post: output>=0
	str_len:
		XOR RAX, RAX 			; set output in zero

	.cicle: CMP byte[RDI], NULL		; empty string: "" size = 0
		JE .end
		INC RDI
		INC EAX				; size uint32 : 4 B 	
		JMP .cicle
	.end:
		RET

	; char* str_copy(char* a)
	str_copy:
		PUSH RBP
		MOV RBP, RSP
		
		PUSH RBX
		PUSH R12
						
		MOV RBX, RDI			; save char* a
		
		CALL str_len			; char* a already in RDI input--return in EAX a's lenght
		
		LEA R12, [RAX+1]		; consider terminating char null-- R12<-lenght(a) save lenght in R12
						; (remember we've cleaned RAX in str_len, it's """easier""" to use RAX rather than EAX)	
		MOV RDI, R12			; input for malloc
		CALL malloc

		XOR R8, R8			; counter i
		XOR R9, R9			; intermediate
	
	.cicle:
		MOV R9b, byte[RBX+R8]		; copy char from input a to R9
		MOV byte[RAX+R8], R9b 		; copy char from R9 to RAX (memory obtained from malloc call)
		INC R8				; i++
		CMP R8,R12			; if(i==lenght(a)) then end
		JE  .end	
		JMP .cicle

	.end:  ; output char* is already in RAX
		POP R12		
		POP RBX
		POP RBP
		RET 
		
	; int32_t str_cmp(char* a, char* b)
	str_cmp:	
		; RDI->a  RSI->b  a<b then 1
	
		XOR RAX, RAX

		CMP RDI, NULL
		JE .minor
		CMP RSI, NULL
		JE .major

	.compare:
		MOV R8b, byte[RDI]
		MOV R9b, byte[RSI]
	
		CMP R8b, R9b
		JL .minor		; a<b return 1
		JG .major		; a>b return -1

		CMP R8b, NULL		; is the terminating null?
		JE .exit		; empty string 
		INC RDI
		INC RSI
		JMP .compare 
	
	.major: DEC EAX
		JMP .exit

	.minor: INC EAX
		JMP .exit
	.exit:
		RET
		

	; char* str_concat(char* s, char* p)
	str_concat:
		PUSH RBP
		MOV RBP, RSP
				
		PUSH RBX
		PUSH R12
		PUSH R13
		PUSH R14

		MOV R13, RDI			; R13<-s
		MOV RBX, RSI			; RBX<-p

		CALL str_len
		MOV R12, RAX			; R12<-len(s)
		MOV RDI, RBX
		CALL str_len			
		MOV R14, RAX    		; R14<-len(p)

		LEA RDI, [R14+R12+1]		; consider terminating NULL char (+1)
		CALL malloc

		XOR R8, R8			; counter = 0
		XOR R9, R9			; inter

	.copyFirst:
		MOV R9b, byte[R13+R8]
		MOV byte[RAX+R8], R9b
		INC R8				; counter++
		CMP R8, R12			; if(len(s)==counter)
		JNE .copyFirst

		XOR R8, R8			; counter = 0
	.copySecond:
		MOV R9b, byte[RBX+R8]
		MOV byte[RAX+R12], R9b		; 				
		INC R8				; counter++
		INC R12
		CMP R8, R14			; if(len(p)==counter) len(p)==0 
		JNE .copySecond

		MOV byte[RAX+R12], NULL		; add null char

		POP R14
		POP R13
		POP R12
		POP RBX		
		POP RBP
		RET

	; listElem_t* newNode(void* data)
	newNode:

		PUSH RBP
		MOV RBP, RSP
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI				; save data
		MOV RDI, 16			
		CALL malloc

		MOV QWORD[RAX+offset_node_data], RBX	; save data inside the new list node
		; return newNode in RAX
		ADD RSP, qword_size
		POP RBX
		POP RBP
		RET
		
	; void deleteNode(void* node)
	deleteNode:
		PUSH RBP
		MOV RBP, RSP
		
		PUSH RBX
		SUB RSP, qword_size

		MOV RBX, RDI					
		MOV RDI, [RBX+offset_node_data]				; set data to delete as input
		MOV R8, [RDI+offset_remove]				; set remove function of datatype to call
		CALL R8							; call remove with data as input

		MOV RDI, RBX						; set node structure as input to delete
		CALL free

		ADD RSP, qword_size
		POP RBX
		POP RBP
		RET

	; void* findPositionInMatrix(matrix_t*, uint32_t x, uint32_t y)
	findPositionInMatrix:
		; RDI<-matrix ESI <-x EDX<-y 
		PUSH RBP
		MOV RBP, RSP


		XOR R8, R8
		MOV R8d, DWORD[RDI+offset_matrix_col]
		LEA R8, [R8*8]						; R8 <-rowSize

		MOV R10, QWORD[RDI+offset_matrix_data]			; start of matrix's data

	.findRow:
		CMP EDX, 0						; if(y==0)
		JE .rowZero
		LEA R10, [R10+R8]					
		DEC EDX
		JMP .findRow					
		; R10 = matrix_start + rowSize*y

	.rowZero:
		CMP ESI, 0 						; if(x==0)
		JE .colZero
		XOR R9, R9
		MOV R9d, ESI
		LEA R9, [R9*8]						; x*8
		
		LEA R10, [R10+R9]					; 
		; R10 = matrix_start + rowSize*y + data_size * x 
	
	.colZero:
		MOV RAX, R10						; return position
		
		POP RBP
		RET







































