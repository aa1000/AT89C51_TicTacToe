
;====================================================================
;====================================================================
   ;'X' - PLAYER 1, 'O' PLAYER 2
   ;B hold the current player
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
      org   0000h
      jmp   Start
	  ; Interrupt Vector
      org   0003h
      ACALL   ISR0
      RETI
;====================================================================
; CODE SEGMENT
;====================================================================

; interrupt routine

ISR0:	      
			;check which button was pressed (pulled down)

	       JNB P0.0, ONESET
	       JNB P0.1, TWOSET
	       JNB P0.2, THREESET
	       JNB P0.3, FOURSET
	       JNB P0.4, FIVESET
	       JNB P0.5, SIXSET
	       JNB P0.6, SEVENSET
	       JNB P0.7, EIGHTSET
	       JNB P2.7, NINESET
	       JMP BUTTONPRESSDONE
	       
		   ; if the slot is free, play move
	 ONESET: 
	 	 CJNE R0,#00H,BUTTONPRESSDONE
	 	 MOV R0, B
		 JMP MOVEPLAYED
	 	 	 	 	 
	 TWOSET: CJNE R1,#00H,BUTTONPRESSDONE
	 	 MOV R1, B
	 	 JMP MOVEPLAYED
	 	 	 
       THREESET: 
              	 CJNE R2,#00H,BUTTONPRESSDONE
       		 MOV R2, B
		 JMP MOVEPLAYED
		 
	FOURSET: 
	 	 CJNE R3,#00H,BUTTONPRESSDONE
		 MOV R3, B
		 JMP MOVEPLAYED
		 
	FIVESET: 
	 	 CJNE R4,#00H,BUTTONPRESSDONE
		 MOV R4, B
		 JMP MOVEPLAYED
		 
	 SIXSET: 
	  	 CJNE R5,#00H,BUTTONPRESSDONE 
	 	 MOV R5, B
		 JMP MOVEPLAYED
       
       SEVENSET: 
        	 CJNE R6,#00H,BUTTONPRESSDONE
       		 MOV R6, B
		 JMP MOVEPLAYED
		 
       EIGHTSET: 
        	 CJNE R7,#00H,BUTTONPRESSDONE
       		 MOV R7, B
		 JMP MOVEPLAYED
	
	; using the low of the data pointer register as the only free reg
	; for the last playing grid slot
	NINESET: MOV A, DPL
		 CJNE A,#00H,BUTTONPRESSDONE
		 MOV DPL, B
		 JMP MOVEPLAYED

		 
	; if a move was played, switch the player who has the turn
	MOVEPLAYED: 
		MOV A, B
		CJNE A,#'X', OTHERPLYR
		MOV B, #'O'
		SJMP BUTTONPRESSDONE
	OTHERPLYR:MOV B, #'X'
	
	; draw the playing grid and check if anyone win before returning
BUTTONPRESSDONE: ACALL DRAWBOARD
 	ACALL CHECKWIN 	
	        RET

      org   100h

Start:	
      MOV IE, #10000101B
      SETB IT0 ;-ve edge trigger for interrupt0
;     SETB IT1 ;-ve edge trigger for interrupt1

	; setting up ports
      MOV P0,#0FFH
      MOV P1,#00H
      MOV P2,#80H
      MOV P3,#0FFH
      
      ;INIT LCD
      MOV A,#38H ; Use 2 lines and 5x7 matrix
      ACALL CMD
      
      MOV A,#0CH ; LCD ON, cursor OFF
      ACALL CMD	
      	
      ACALL CLRLCD
      ACALL RESETGRID
      
	  ; move the first player in B
      MOV B, #'X'

      ACALL DRAWBOARD
      

      ; loop till we get an interrupt
      JMP EMPTYLOOP

     
     
EMPTYLOOP:
	
	JMP EMPTYLOOP
	  

RESETGRID:     
		
		; make all grid slots empty
	    MOV R0,#00H
	    MOV R1,#00H
	    MOV R2,#00H
	    MOV R3,#00H
	    MOV R4,#00H
	    MOV R5,#00H
	    MOV R6,#00H
	    MOV R7,#00H
	    MOV DPL,#00H
	    RET
	    

CHECKWIN: 	
		; check every row, coloumn and diagonal of the playing grid
		; if they have the same player X or O 
		MOV A,DPL
	       CJNE R0, #'X',DIAGFWRO
	       CJNE R4,#'X',DIAGFWRO
	       CJNE A,#'X',DIAGFWRO
	       MOV A,#'H'
	       ACALL DWR
	       LJMP XWIN
	       
	       
DIAGFWRO: 	CJNE R0,#'O', DIAGBCKX
	       CJNE R4,#'O',DIAGBCKX
	       CJNE A,#'O',DIAGBCKX
	       LJMP OWIN
	       

DIAGBCKX:
	       CJNE R2, #'X',DIAGBCKO
	       CJNE R4,#'X',DIAGBCKO
	       CJNE R6,#'X',DIAGBCKO
	       MOV A,#'H'
	       ACALL DWR
	       LJMP XWIN
	       
	       
DIAGBCKO: 	CJNE R2,#'O', FSTROWX
	       CJNE R4,#'O',FSTROWX
	       CJNE R6,#'O',FSTROWX
	       LJMP OWIN	 
	             	       
FSTROWX:	CJNE R0, #'X', FSTROWO
	       CJNE R1,#'X', FSTROWO
	       CJNE R2,#'X',FSTROWO
	       MOV A,#'H'
	       ACALL DWR
	       LJMP XWIN
	       
FSTROWO: 	CJNE R0,#'O', SECONDROWX
	       CJNE R1,#'O',SECONDROWX
	       CJNE R2,#'O',SECONDROWX
	       LJMP OWIN
	       
	       
	       RET
	       
SECONDROWX:	CJNE R3, #'X', SCDROWO
	       CJNE R4,#'X', SCDROWO
	       CJNE R5,#'X',SCDROWO
	       MOV A,#'H'
	       LJMP XWIN
	       
SCDROWO: 	CJNE R3,#'O', THIRDROWX
	       CJNE R4,#'O',THIRDROWX
	       CJNE R5,#'O',THIRDROWX
	       LJMP OWIN
	       
	       
THIRDROWX:	MOV A,DPL
	       CJNE R6, #'X', THIRDROWO
	       CJNE R7,#'X',THIRDROWO
	       CJNE A,#'X',THIRDROWO
	       LJMP XWIN
	       
	       RET
	       
THIRDROWO: 	CJNE R6,#'O', FSTCOLX
	       CJNE R7,#'O',FSTCOLX
	       CJNE A,#'O',FSTCOLX
	       LJMP OWIN
	       RET


FSTCOLX:
	       CJNE R0, #'X', FSTCOLO
	       CJNE R3,#'X',FSTCOLO
	       CJNE R6,#'X',FSTCOLO
	        LJMP XWIN
	       RET
	       
FSTCOLO: 	CJNE R6,#'O', SNDCOLX
	       CJNE R7,#'O',SNDCOLX
	       CJNE A,#'O',SNDCOLX
		LJMP OWIN
	       RET
	       
SNDCOLX:
	       CJNE R1, #'X', SNDCOLO
	       CJNE R4,#'X',SNDCOLO
	       CJNE R7,#'X',SNDCOLO
	       LJMP XWIN
	        
	       RET
	       
SNDCOLO: 	CJNE R1,#'O', THDCOLX
	       CJNE R4,#'O',THDCOLX
	       CJNE R7,#'O',THDCOLX
	       LJMP OWIN
	       RET
	       
THDCOLX:
		MOV A,DPL
	       CJNE R2, #'X',THDCOLO
	       CJNE R5,#'X',THDCOLO
	       CJNE A,#'X',THDCOLO
	       MOV A,#'H'
	      LJMP XWIN
	       RET
	       
THDCOLO: 	CJNE R2,#'O', CHECKEND
	       CJNE R5,#'O',CHECKEND
	       CJNE A,#'O',CHECKEND
	       LJMP OWIN
	       RET
	       

	; return if no onw won
	CHECKEND:       RET
	  
	  ; write the  winnter to the screen
XWIN:
	ACALL CLRLCD
	MOV A, #80H ;MOV TO LINE1
 	ACALL CMD
 	MOV A, #'X'
 	ACALL DWR
 	ACALL PRINTWINMESS
	RET
OWIN:
	ACALL CLRLCD
	MOV A, #80H ;MOV TO LINE1
 	ACALL CMD
 	MOV A, #'O'
 	ACALL DWR 
 	ACALL PRINTWINMESS
 	RET
	       
PRINTWINMESS:
        MOV A, #' '
 	ACALL DWR 
 	MOV A, #'P'
 	ACALL DWR 
 	MOV A, #'L'
 	ACALL DWR 
 	MOV A, #'A'
 	ACALL DWR 
 	MOV A, #'Y'
 	ACALL DWR 
 	MOV A, #'E'
 	ACALL DWR 
 	MOV A, #'R'
 	ACALL DWR 
 	MOV A, #' '
 	ACALL DWR 
 	MOV A, #'W'
 	ACALL DWR 
 	MOV A, #'O'
 	ACALL DWR 
 	MOV A, #'N'
 	ACALL DWR 
	
	
 INFT: SJMP INFT      
		RET
		
	;	send a write command to the LCD to dispaly a character
DWR:MOV P1, A
      SETB P2.0
      CLR P2.1
      SETB P2.2
      ACALL DELAY
      CLR P2.2
      RET

    ; send a  command to the LCD
  CMD:MOV P1, A
      CLR P2.0
      CLR P2.1
      SETB P2.2
      ACALL DELAY
      CLR P2.2
      RET
      
      
	  ; save the R6 value then use it for a delay loop
 DELAY:MOV DPH, R6 	
 	MOV R6, #250D
   HERE:DJNZ R6, HERE
   	MOV R6, #250D
 HERE2:DJNZ R6, HERE2
 	MOV R6, #250D
 HERE3:DJNZ R6, HERE3
 	MOV R6, #250D
   HERE4:DJNZ R6, HERE4
   	MOV R6, #250D
 HERE5:DJNZ R6, HERE5
 	MOV R6, #250D
   	
	; return r6 to the original value
      MOV R6, DPH
      RET
      
DRAWBOARD:
	   ACALL CLRLCD
	 MOV A, #80H ;MOV TO LINE1
         ACALL CMD
      
	; draw what is in the grid registers line by line

	ACALL DRAW2SPACES
	MOV A,R0
	ACALL DWR

        ACALL DRAWSEPLINE
        MOV A,R1
        ACALL DWR

        ACALL DRAWSEPLINE
        MOV A,R2
        ACALL DWR
      
      MOV A, #0C0H ;MOV TO LINE2
      ACALL CMD
      
      ACALL DRAW2SPACES
      MOV A ,R3
      ACALL DWR
      
      ACALL DRAWSEPLINE
      MOV A ,R4
      ACALL DWR
      
      ACALL DRAWSEPLINE
      MOV A ,R5
      ACALL DWR
      
      ACALL DRAW2SPACES
      
      MOV A, #' '
      ACALL DWR
      MOV A ,R6
      ACALL DWR
      
      ACALL DRAWSEPLINE
      MOV A ,R7
      ACALL DWR
      
      ACALL DRAWSEPLINE
      MOV A , DPL
      ACALL DWR
       
      RET

      DRAW2SPACES:
	MOV A, #' '
      ACALL DWR
      MOV A, #' '
      ACALL DWR
     
      RET
      
DRAWSEPLINE:
	ACALL DRAW2SPACES
	MOV A, #'|'
      ACALL DWR	
      ACALL DRAW2SPACES
      RET
	      
      
CLRLCD:
	MOV A,#01H ;Clear screen
      ACALL CMD
      
      MOV A,#06H ;Increment cursor
      ACALL CMD
      RET
    

;====================================================================
      END
