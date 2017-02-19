NAME	TRYING......

; create file
; append data to the end of file
; create txt file
; the transfer part (but : 1. the picture is reversed by upside to downside; 2. the picture is not well matched by its gray value and the ASCII code..)
; the corresponding ASCII code for different gray value class is done
; upside the .txt picture down
; command line included !
; which means basically finished 

; operating !

; adding the loading screen
; ......

.386
STACK	SEGMENT	USE16 STACK
	DB	200	DUP(0)
STACK	ENDS
DATA	SEGMENT	USE16
	CMDLINE	DB	80
			DB	?
			DB	80 DUP(0)
	
	NAMEF	DB	30 DUP(0) ; THE NAME OF FILE TO BE CREATED
	HANDLE1	DW 	? ; THE CODE OF TXT FILE
	FNAME	DB	30 DUP(0) ; the image to be transferd
	HANDLE2	DW	? ; THE CODE OF IMAGE FILE
	
	ASCIICODE	DB '@', '#', '&', 'K', '?', '+', ';', '.', ' ', 00H
	GRAYCLASSDIV	DB	36 ; 0 - 255 gray value is divided into 8 classes, 36 pieces per class
		
	ROW		DD 0
	ROWCOUNT	DD 0
	COL		DD 0
	COLCOUNT	DD 0
	PIXELCOUNT	DD 0
	
	BF_SIZE		DD	1 ; bfSize, double word, the length of file
	BIWIDTH		DD	0 ; biWidth, double word, the width of image
	BIHEIGHT	DD 	0 ; biHeight, double word, the height of image
	BISIZEIMG	DD	0 ; biSizeImage, double word, the data length of image part
	BIXPER		DD	0 ; biXPerlsPerMeter, double word, the X resolution
	BIYPER		DD	0 ; biYPerlsPerMeter, double word, the Y resolution
	B			DB	0 ; the pixel of blue component
	G			DB	0 ; the pixel of green component
	R			DB	0 ; the pixel of red component
	GRAY		DB	0 ; the pixel transformation result
	TMP			DW	0
	LASTGRAY	DW	0 ; the last place of insert in BUF3
	
	; the footprint of cursor in image file on its waying picking data from image file into area BUF2
	WORD3A	DW 0 ; the low 16bit of answer
	WORD3B	DW 0 ; the low 16bit of answer
	WORD1A	DW ? ; the low 16bit
	WORD1B	DW ? ; the heigh 16bit
	WORD2A	DW ? ; the low 16bit
	WORD2B	DW ? ; the heigh 16bit
	
	ONEPICKO	DW	0 ; THE BYTES TO BE PICKED IN A ROW LOOP, positive number
	ONEPICKN	DW	0 ; the negative number
	LINEALLIG	DW	4 ; the number of data bytes should be divided by 4 without remain
	ACTWRITTEN	DW	0 ; the actual length of one bunch data to be wrote equals BIWIDTH and 2 (refers to 0dh, 0ah in order to start another line for data)
	
	; to get image file's head information
	BUF		DB	54 DUP(0)
	; to save data for temprorily
	BUF2	DB	24000 DUP(0)
	; noted that 0dh, 0ah occupy 2 bits of memory to be write
	; example: if the string to be wrote contains 10 charactors
	;		   then in order to write this string, the rigester CX shoud be 10+2 = 12
	BUF3	DB	0dh, 0ah, 24002 DUP(0) ; BUF ZONE TO BE WROTE INTO THE FILE, 5kb
	
	ERMSG1	DB	'CREATE FILE ERROR! $'
	ERMSG2	DB	'OPEN FILE ERROR! $'
	ERMSG3	DB	'WRITE FILE ERROR! $'
	ERMSG4	DB	'THE SPACE IS NOT ENOUGH! $'
	ERMSG5	DB	'POINT FAILED! $'
	ERMSG6	DB	'CLOSE FILE ERROR! $'
	ERMSG7	DB	'READ FILE ERROR! $'
	ERMSG8	DB	'COMMAND INPUT ERROR! $'
	ERMSG9	DB	'IMAGE MUST BE *.bmp $'
	ERMSG10	DB	'OUTPUT FILE MUST BE *.txt $'
	CRLF	DB	0DH, 0AH, '$'
	
	MSG0	DB  '------------------------------------------------------------', 0DH, 0AH, '$'
	MSG1	DB	'WELCOME TO MY FIRST ASSEMLELY SOFT ', 0DH, 0AH, 0DH, 0AH, '$'
	MSG2	DB	'TO COVERT YOUR *.BMP FILE INTO *.TXT FILE: ', 0DH, 0AH, '$'
	MSG3	DB	'  1. PUT *.BMP FILE INTO THE DOCUMENT WHERE THIS PROGRAM LIES ', 0DH, 0AH, '$'
	MSG4	DB	'  2. USE DOS RUNNING THIS PROGRAM ', 0DH, 0AH, '$'
	MSG5	DB	'  3. COMMAND: bmp2txt *.bmp *.txt ', 0DH, 0AH, '$'
	MSG6	DB	0DH, 0AH, 'NOTICE: no anyother extra character is allowed! ', 0DH, 0AH, '$'
	MSG7	DB	'COMMAND: $'
	
	MSG8	DB	0DH, 0AH, 'XXXXXX        XXXXXX          PPPPPPPPPPPPPPPPPPPP', 0DH, 0AH, '$'
    MSG9	DB	' XXXXXX      XXXXXX          PPPPPPPPPPPPPPPPPPPP', 0DH, 0AH, '$'
    MSG10	DB	'  XXXXXX    XXXXXX          PPPPPP        PPPPPP', 0DH, 0AH, '$'
    MSG11	DB	'   XXXXXX  XXXXXX          PPPPPP        PPPPPP', 0DH, 0AH, '$'
    MSG12	DB	'    XXXXXXXXXXXX          PPPPPPPPPPPPPPPPPPPP', 0DH, 0AH, '$'
    MSG13	DB	'   XXXXXX  XXXXXX        PPPPPP', 0DH, 0AH, '$'
	MSG14	DB	'  XXXXXX    XXXXXX      PPPPPP', 0DH, 0AH, '$'
    MSG15	DB	' XXXXXX      XXXXXX    PPPPPP', 0DH, 0AH, '$'
	MSG16	DB	'XXXXXX        XXXXXX  PPPPPP               CS1004', 0DH, 0AH, 0DH, 0AH, '$'
	MSG17	DB	'            CONGRADULATIONS !', 0DH, 0AH, '$'
	
DATA	ENDS
CODE	SEGMENT	USE16
	ASSUME	CS: CODE, DS: DATA, SS: STACK

;....................................................
MAIN	PROC	FAR
	MOV		AX, DATA
	MOV		DS, AX
	
	CALL	NOTICE
	CALL	CMD
	
	; create the target .txt file
	XOR		AX, AX
	MOV		AH, 3CH ; create txt file
	LEA		DX, NAMEF
	MOV		CX, 00
	INT		21H
	JC		SHOWERMSG1
	MOV		HANDLE1, AX
	XOR		AX, AX
	MOV		AH, 3EH ; CLOSE TXT FILE
	MOV		BX, HANDLE1
	INT 	21H
	JC		SHOWERMSG6
	
	CALL		SHOWPROCESS1
	XOR		AX, AX
	LEA		DX, FNAME ; OPEN THE IMAGE
	MOV		AH, 3DH
	MOV		AL, 02H
	INT 	21H
	JC		SHOWERMSG2
	MOV		HANDLE2, AX
	
	MOV		BX, HANDLE2 ; READ 54 BYTES' DATA FROM IMAGE
	MOV		AH, 3FH
	MOV		CX, 54 ; the 54bits from the beginning contains basic discribtion of the image
	MOV		DX, OFFSET BUF
	INT		21H
	MOV		AH, 3EH ; CLOSE IMAGE FILE
	INT 	21H
	
	; PICK USEFUL DATA INTO ITS VARIABLE
	MOV		EAX, DWORD PTR BUF[2H]
	MOV		BF_SIZE, EAX ; move data bfSize from file to variable BF_SIZE
	MOV		EAX, DWORD PTR BUF[12H]
	MOV		BIWIDTH, EAX ; move data biWidth from file to variable BIWIDTH
	MOV		EAX, DWORD PTR BUF[16H]
	MOV		BIHEIGHT, EAX; move data biHeight from file to variable BIHEIGHT
	MOV		EAX, DWORD PTR BUF[22H]
	MOV		BISIZEIMG, EAX; move data biSizeImage from file to variable BISIZEIMG
	MOV		EAX, DWORD PTR BUF[26H]
	MOV		BIXPER, EAX; move data biXPerlsPerMeter from file to variable BIXPER
	MOV		EAX, DWORD PTR BUF[2AH]
	MOV		BIYPER, EAX ; move data biYPerlsPerMeter from file to variable BIYPER

	; calculate the real number of bits to be written into target file for each time
	MOV		CX, WORD PTR BIWIDTH
	ADD		CX, 2 ; the actual length of one bunch data to be wrote equals BIWIDTH and 2 (refers to 0dh, 0ah in order to start another line for data)
	MOV		ACTWRITTEN, CX
	
	; calculate the number of bytes pick for one row
	MOV		AX, 3
	MUL		BIWIDTH ; EAX * OPS => EDX(HIGHT PART), EAX(LOW PART)
	MOV		ONEPICKO, AX
	
	; the number of data bytes should be divided by 4 without remain
MODIFY:
	XOR		EDX, EDX
	DIV		LINEALLIG
	CMP		EDX, 0
	JE		NEXT
	INC		ONEPICKO
	MOV		AX, ONEPICKO
	JMP		MODIFY
;....................................................
; transfer part
NEXT:
	; initial the row loop variabels
	;		value of row, rowcount, WORD1A, WORD1B, WORD2A, WORD2B
	; calculate the opsite number of ONEPICK got above
	CALL	SHOWPROCESS2
	MOV		AX, ONEPICKO
	NOT		AX
	ADD		AX, 1
	MOV		ONEPICKN, AX ; in order to move the file pointer from the end of .txt file to the beginning
	
	MOV		EAX, BIHEIGHT
	MOV		ROW, EAX
	XOR		EAX, EAX
	MOV		ROWCOUNT, EAX

	XOR		AX, AX
	MOV		WORD1A, AX
	MOV		WORD1B, AX
	MOV		WORD2B, AX
	MOV		AX, ONEPICKO
	MOV		WORD2A, AX

ROWLOOP:
	; start row loop with condition judgements
	;		if row != rowcount, then continue this loop, else, get out of this loop
	MOV		EAX, ROWCOUNT
	CMP		EAX, ROW
	JE		TOEND
	; deal with cursor's beginning place
	; 		WORD3B(high 16bits),WORD3A(low 16bits) contains it and, WORD3B = WORD2B + WORD1B, WORD3A = WORD2A + WORD1A;
	CALL	ADDBIG
	
	; open the image file
	XOR		AX, AX
	MOV		AH, 3DH
	MOV		AL, 00H ; read only
	LEA		DX, FNAME
	INT		21H
	JC		SHOWERMSG2
	MOV		HANDLE2, AX
	; move image file's pointer to the place where last loop stop
	XOR		AX, AX
	MOV		AH, 42H
	MOV		AL, 02h ; 00 moves from the very beginning to the end of the file, 2 moves from the end of the file to the beginning
	MOV		BX, HANDLE2
	MOV		CX, WORD3B
	MOV		DX, WORD3A
	INT		21H
	JC		SHOWERMSG5
	; pick onepick number's data into BUF2 area
	XOR		AX, AX
	MOV		AH, 3FH
	MOV		BX, HANDLE2
	MOV		CX, ONEPICKO
	LEA		DX, BUF2
	INT		21H
	JC		SHOWERMSG7
	; close image file
	XOR		AX, AX
	MOV		AH, 3EH
	MOV		BX, HANDLE2
	INT		21H
	JC		SHOWERMSG6
	; save cursor's current position
	MOV		AX, WORD3A
	MOV		WORD2A, AX
	MOV		AX, WORD3B
	MOV		WORD2B, AX
	MOV		AX, ONEPICKN
	MOV		WORD1A, AX
	CWD
	MOV		WORD1B, DX
	
	; initial the col loop variables
	;		value of col, colcount, pointer in area BUF2 picking data(which is colcount), pointer in BUF3 saving data(SI)
	MOV		EAX, BIWIDTH
	MOV		COL, EAX
	XOR		EAX, EAX
	MOV		COLCOUNT, EAX
	MOV		PIXELCOUNT, EAX
	MOV		LASTGRAY, 2
COLLOOP:
	; start col loop with condition judgements
	;		if col != colcount, then continue this loop, else, get out of this loop
	MOV		EAX, COL
	CMP		EAX, COLCOUNT
	JE		TOROWLOOP
	; pick 3bits data from BUF2 area to calculate its gray value for each time
	MOV		EDI, PIXELCOUNT
	MOV		AL, BUF2[EDI] ; pick blue pixel data into variable B
	MOV		B, AL
	INC		EDI
	MOV		AL, BUF2[EDI] ; pick green pixel data into variable G
	MOV		G, AL
	INC		EDI
	MOV		AL, BUF2[EDI] ; pick red pixel data into variable R
	MOV		R, AL
	INC		EDI
	MOV		PIXELCOUNT, EDI
	
	MOV		TMP, WORD PTR 32H ; 50
	MOV		AL, B
	MOV		CL, 11
	MUL		CL
	ADD		TMP, AX	; 50 + B * 11
	MOV		AL, G
	MOV		CL, 59
	MUL		CL
	ADD		TMP, AX ; 50 + B * 11 + G * 59
	MOV		AL, R
	MOV		CL, 30
	MUL		CL
	ADD		TMP, AX ; 50 + B * 11 + G * 59 + R * 30
	MOV		AX, TMP
	MOV		CL, 100
	DIV		CL
	CALL	TOCODE ; to transfer the gray value to its proper corresponding ASCII code
	MOV		GRAY, AL ; GRAY = (50 + B * 11 + G * 59 + R * 30) / 100
	
	; move BUF3 cursor in order to save gray value(which is SI)
	MOV		SI, LASTGRAY
	MOV		BUF3[SI], AL
	INC		SI
	MOV		LASTGRAY, SI
	
	; col loop's relative variable changes
	MOV		EAX, COLCOUNT
	INC		EAX
	MOV		COLCOUNT, EAX
	; back to col loop
	JMP		COLLOOP

TOROWLOOP:
	; call APPENDDATA to append data in area BUF3 into the end of it with the number of BIWIDTH+2
	CALL	APPENDDATA
	; back to row loop
	MOV		EAX, ROWCOUNT
	INC		EAX
	MOV		ROWCOUNT, EAX
	JMP		ROWLOOP
;....................................................
SHOWERMSG1:
	LEA		DX, ERMSG1
	CALL	DISP
	JMP		EXIT
SHOWERMSG2:
	LEA		DX, ERMSG2
	CALL	DISP
	JMP		EXIT
SHOWERMSG3:
	LEA		DX, ERMSG3
	CALL	DISP
	JMP		EXIT
SHOWERMSG4:
	LEA		DX, ERMSG4
	CALL	DISP
	JMP		EXIT
SHOWERMSG5:
	LEA		DX, ERMSG5
	CALL	DISP
	JMP		EXIT
SHOWERMSG6:
	LEA		DX, ERMSG6
	CALL	DISP
	JMP		EXIT
SHOWERMSG7:
	LEA		DX, ERMSG7
	CALL	DISP
	JMP		EXIT
SHOWERMSG8:
	LEA		DX, ERMSG8
	CALL	DISP
	JMP		EXIT
SHOWERMSG9:
	LEA		DX, ERMSG8
	CALL	DISP
	JMP		EXIT
SHOWERMSG10:
	LEA		DX, ERMSG8
	CALL	DISP
	JMP		EXIT
	


TOEND:
	CALL	SHOWPROCESS3
	
EXIT:
	MOV		AH, 4CH
	INT		21H	
MAIN	ENDP
;....................................................

;....................................................
; transfer gray value to its corresponding ASCII code
; ASCII code is saved in AL
TOCODE	PROC	NEAR
	XOR		EBX, EBX
	MOV		BX, OFFSET	ASCIICODE
	MOV		AH, 0
	DIV		GRAYCLASSDIV
	XLAT
	RET
TOCODE	ENDP
;....................................................

;....................................................
; answer of the high 16bit lie in WORD3B, the low 16bit lie in WORD3A
ADDBIG	PROC	NEAR
	MOV		AX, WORD1A
	ADD		AX, WORD2A
	MOV		WORD3A, AX
	MOV		AX, WORD1B
	ADC		AX, WORD2B
	MOV		WORD3B, AX
	RET
ADDBIG	ENDP
;....................................................

;....................................................
DISP	PROC	NEAR
	MOV		AH, 09H
	INT		21H
	RET
DISP	ENDP
;....................................................

;....................................................
NOTICE	PROC	NEAR
	LEA		DX, CRLF
	CALL	DISP
	LEA		DX, CRLF
	CALL	DISP
	LEA		DX, CRLF
	CALL	DISP
	LEA		DX, MSG0
	CALL	DISP
	LEA		DX, MSG1
	CALL	DISP
	LEA		DX, MSG2
	CALL	DISP
	LEA		DX, MSG3
	CALL	DISP
	LEA		DX, MSG4
	CALL	DISP
	LEA		DX, MSG5
	CALL	DISP
	LEA		DX, MSG6
	CALL	DISP
	LEA		DX, MSG0
	CALL	DISP
	LEA		DX, MSG7
	CALL	DISP
	RET
NOTICE	ENDP
;....................................................

SHOWPROCESS1	PROC	NEAR
	LEA		DX, MSG8
	CALL	DISP
	RET
SHOWPROCESS1 ENDP

SHOWPROCESS2	PROC	NEAR
	LEA		DX, MSG9
	CALL	DISP
	LEA		DX, MSG10
	CALL	DISP
	LEA		DX, MSG11
	CALL	DISP
	RET
SHOWPROCESS2 ENDP
	
SHOWPROCESS3	PROC	NEAR
	LEA		DX, MSG12
	CALL	DISP
	LEA		DX, MSG13
	CALL	DISP
	LEA		DX, MSG14
	CALL	DISP
	LEA		DX, MSG15
	CALL	DISP
	LEA		DX, MSG16
	CALL	DISP
	LEA		DX, MSG17
	CALL	DISP
	RET
SHOWPROCESS3 ENDP

;....................................................
; append data to the end of file (data comes from BUF3)
APPENDDATA	PROC	FAR
	XOR		AX, AX
	LEA		DX, NAMEF
	MOV		AH, 3DH ; open the file
	MOV		AL, 02H
	INT		21H
	
	JNC		POINTERTOEND
	JMP		SHOWERMSG2

POINTERTOEND:
	MOV		HANDLE1, AX ; save the file's code
	MOV		AH, 42H
	MOV		AL, 02H ; move file's point to the end of it
	MOV		DX, 0
	MOV		CX, 0
	MOV		BX, HANDLE1
	INT 	21H
	JNC		WRITEDATA
	JMP		SHOWERMSG5 ; if pointer's movement failed

WRITEDATA:	
	MOV		AH, 40H ; WRITE DATA INTO FILE
	MOV		BX, HANDLE1
	MOV		CX, ACTWRITTEN ; THE PLANNED BYTE NUMBER OF DATA TO BE WROTE
	LEA		DX, BUF3
	INT		21H
	
	JNC		JUDGEDATANUMBER
	JMP		SHOWERMSG3
	
JUDGEDATANUMBER:
	CMP		AX, CX ; COMPARE THE ACTUAL NUMBER AND PLANNED NUMBER OF DATA WRITTEN, TO JUDGE WHETHER WRITTING SUCCEED OR NOTS
	JE		RETMAIN
	JMP		SHOWERMSG4
	
RETMAIN:
	MOV		AH, 3EH ; close file
	MOV		BX, HANDLE1
	INT		21H
	RET
	
APPENDDATA	ENDP
;....................................................

;....................................................
; read command line
CMD	PROC	NEAR
	; get input into CMDLINE
	XOR		AX, AX
	LEA		DX, CMDLINE
	MOV		AH, 0AH
	INT 	21H
	LEA		DX, CRLF
	MOV		AH, 9
	INT 	21H
	MOV		BL, CMDLINE+1
	MOV		BH, 0
	MOV		BYTE PTR CMDLINE+2[BX], '$'
	
	; judge the bmp2txt command
	MOV		BX, 2
	CMP		CMDLINE[BX], 'b'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], 'm'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], 'p'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], '2'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], 't'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], 'x'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], 't'
	JNE		SHOWERMSG8
	INC		BX
	CMP		CMDLINE[BX], ' '
	JNE		SHOWERMSG8
	
	; move image file name into variable FNAME
	MOV		SI, 0
loop0:
	INC		BX
	MOV		DL, CMDLINE[BX]
	MOV		BYTE PTR FNAME[SI], DL
	CMP		DL, ' '
	JE		p0
	INC		SI
	JMP		loop0
p0:
	MOV		FNAME[SI], 00H
	
	; move target .txt file name into variable NAMEF
	MOV		SI, 0
loop1:
	INC		BX
	MOV		DL, CMDLINE[BX]
	MOV		BYTE PTR NAMEF[SI], DL
	CMP		DL, '$'
	JE		p1
	INC		SI
	JMP		loop1
p1:
	MOV		NAMEF[SI], 00H
	RET
CMD	ENDP
;....................................................
	CODE	ENDS
END	MAIN