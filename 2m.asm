CALCULATION MACRO
LOCAL OVERFLOW,ERR
MOV CORRECT, 1
ADD NUMBER, 78
JO OVERFLOW
JMP ERR
OVERFLOW:
MOV CORRECT, 0
LEA DX, OFSUM
MOV AH, 9H
INT 21H 
ERR:
ENDM

STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
STARTMESSAGE DB 'HI, INPUT A NUMBER FROM -32768 T0 32767, MAX - 6 SYMBOLS: $'
ERRORMESSAGE DB 'OOOPS, WRONG DATA$'
OFSUM DB 'OVERFLOW WHILE ADDING 78$'

NEGFLAG DB 0
CORRECT DB 0
MINNUM EQU -32768
NUMBER DW 0
DUMP DB 7,?,7 DUP(0AH)
DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
ASSUME CS:CSEG, DS:DSEG, SS:STSEG

MAIN PROC FAR

PUSH DS
XOR AX,AX 
PUSH AX
;INITIALIZATION OF DS
MOV AX,DSEG
MOV DS,AX

LEA DX, STARTMESSAGE
MOV AH,9H
INT 21H


;INPUT SYMBOLS
MOV AH, 0AH
LEA DX, DUMP
INT 21H
MOV AL, 0AH
INT 29H

;CONVERT TO NUMBER
LEA SI, DUMP +2
CMP BYTE PTR [SI], "-"
JNZ A1
MOV NEGFLAG,1
INC SI

A1:
XOR AX,AX
MOV BX,10 

A2:
MOV CL, [SI]
CMP CL, 0DH
JZ AEND

CMP CL,'0'
JB ERROR
CMP CL, '9'
JA ERROR

SUB CL, '0'
IMUL BX
JO ERROR
ADD AX, CX
JO MIN
INC SI 
JMP A2

ERROR:
LEA DX, ERRORMESSAGE
MOV AH,9H
INT 21H
JMP ENDL

MIN:
CMP AX, MINNUM
JNE ERROR 
CMP BYTE PTR [DUMP +2], "-"
JNE ERROR 

AEND:
CMP NEGFLAG, 1
JNE A3
NEG AX
JMP A3
A3:
MOV NUMBER,AX 
CALCULATION
CMP CORRECT, 1
JNE ENDL
CALL DIGITOUTPUT
ENDL:
RET
MAIN ENDP



DIGITOUTPUT PROC NEAR
MOV BX, NUMBER
OR BX,BX 
JNS M1
MOV AL, '-'
INT 29H
NEG BX

M1:
MOV AX,BX 
XOR CX, CX 
MOV BX, 10

M2:
XOR DX,DX
DIV BX 
ADD DL, '0'
PUSH DX
INC CX 
TEST AX,AX 
JNZ M2 

M3:
POP AX 
INT 29H
LOOP M3 
RET 
DIGITOUTPUT ENDP


CSEG ENDS
END MAIN