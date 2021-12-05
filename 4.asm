STSEG SEGMENT PARA STACK "STACK"
DB 64 DUP("STACK")
STSEG ENDS

DSEG SEGMENT PARA PUBLIC "DATA"
STARTMESSAGE DB 'HI, INPUT ARRAY SIZE FROM 1 T0 5 $'
ERRORMESSAGE DB 'OOOPS, WRONG DATA$'
MASMESSAGE DB 'YOUR START ARRAY: $'
INPUTMASMESSAGE DB 'INPUT YOUR ELEMENTS WITH PRESSING ENTER: $'
SUMOVERFLOWMESSAGE DB 'OVERFLOW WHILE SUM $'

NUMBERSTR DB 7,?,7 DUP(0AH)

MAS DW 5 DUP(0)

NUMBER DW 0
TEMPCX DW 0 
TEMPSI DW 0
NUMBERELEMENTS DW 0
SUM DW 0 
SUMOVERFLOW DW 0

NUMBERTOPRINT DW 0

CONVERTATIONCORRECT DW 1


MINNUM EQU -32768
TOCOMP EQU 0

DSEG ENDS

CSEG SEGMENT PARA PUBLIC "CODE"
.386

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

;INPUT SIZE
MOV AH, 0AH
LEA DX, NUMBERSTR
INT 21H
CALL PRINTNEWLINE 

CALL CONVERTATION
CMP CONVERTATIONCORRECT, 1
JNE INCORRECT
MOV CX, NUMBER
MOV NUMBERELEMENTS, CX
MOV SI, 0 
CALL INPUTMAS
MOV SI, 0
MOV CX, NUMBERELEMENTS
CALL PRINTMAS
MOV SI, 0
MOV CX, NUMBERELEMENTS
CALL FINDSUM
CMP SUMOVERFLOW, 0
JNE INCORRECT
MOV AX, SUM
MOV NUMBERTOPRINT, AX
CALL PRINTNEWLINE 
CALL PRINTNUMBER
INCORRECT:
RET

MAIN ENDP


INPUTMAS PROC NEAR
LEA DX, INPUTMASMESSAGE
MOV AH, 9H
INT 21H 
CALL PRINTNEWLINE 
INPUTEL:
MOV TEMPCX, CX
MOV AH, 0AH
LEA DX, NUMBERSTR
INT 21H
MOV TEMPSI, SI 
CALL PRINTNEWLINE 
CALL CONVERTATION
MOV SI, TEMPSI
CMP CONVERTATIONCORRECT, 1
JNE INCORRECTINPUT
MOV AX, NUMBER
MOV MAS[SI], AX 
MOV CX, TEMPCX
ADD SI, 2
LOOP INPUTEL
INCORRECTINPUT:
RET
INPUTMAS ENDP 

PRINTMAS PROC NEAR
LEA DX, MASMESSAGE
MOV AH, 9H
INT 21H 
CALL PRINTNEWLINE 
PRINTEL:
MOV TEMPCX, CX
MOV DX, MAS[SI]
MOV NUMBERTOPRINT, DX
CALL PRINTNUMBER
MOV AL, ' '
INT 29H 
ADD SI, 2
MOV CX, TEMPCX
LOOP PRINTEL
RET 
PRINTMAS ENDP


FINDSUM PROC NEAR
SUMMA:
MOV DX, MAS[SI]
ADD SUM, DX 
JO OF 
ADD SI, 2
LOOP SUMMA
RET
OF:
CALL PRINTNEWLINE
LEA DX, SUMOVERFLOWMESSAGE
MOV AH,9H
INT 21H
MOV SUMOVERFLOW, 1
RET 
FINDSUM ENDP


PRINTNEWLINE PROC NEAR
MOV AL, 0AH
INT 29H
MOV AL, 13
INT 29H
RET
PRINTNEWLINE ENDP

PRINTERROR PROC NEAR
LEA DX, ERRORMESSAGE
MOV AH, 9H
INT 21H 
CALL PRINTNEWLINE 
RET 
PRINTERROR ENDP 

CONVERTATION PROC NEAR
;CONVERT TO NUMBER
LEA SI, NUMBERSTR +2
CMP BYTE PTR [SI], "-"
JNE A1
INC SI

A1:
XOR AX,AX
MOV BX,10 

A2:
MOV CL, [SI]
CMP CL, 0DH
JZ NEGATIVE

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
CALL PRINTERROR 
MOV CONVERTATIONCORRECT, 0
RET 
MIN:
CMP AX, MINNUM
JNE ERROR 
CMP BYTE PTR [NUMBERSTR + 2], "-"
JNE ERROR 
NEGATIVE:
CMP BYTE PTR [NUMBERSTR + 2], "-"
JNE A3
NEG AX
A3:
MOV NUMBER,AX 
RET 
CONVERTATION ENDP




PRINTNUMBER PROC NEAR
MOV BX, NUMBERTOPRINT
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
PRINTNUMBER ENDP


CSEG ENDS
END MAIN