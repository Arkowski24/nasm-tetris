;Frame parametres
frameHeight equ 8 * 20
frameWidth equ 8 * 10
frameBorderWidth equ 5
frameBeginningX equ 50
frameBeginningY equ 10

nextPieceFrameHeight equ 8 * 5
nextPieceFrameWidth equ 8 * 5
nextPieceFrameBorderWidth equ 5
nextPieceFrameBeginningX equ 155
nextPieceFrameBeginningY equ 10

boardColor equ 0
pieceSize equ 8

segment data
        videoMode: resw 1
    	boardState: resb 20 * 10
    	
    	nextPieceType: resb 1
    	pieceType: resb 1
    	pieceCol: resb 1
    	piecePos: resb 4
    	piecePivotPos: resb 1
    	
    	temporaryPiecePos: resb 4
    	
    	waitTime: resb 1
    	
    	score: resw 1
    	scoreAsString: resb 5
    	gameOver: db "GAME OVER"
    	scoreString: db "SCORE" 	
segment text
..start:
        ;Initialization
        mov AX, data 
        mov DS, AX  
        mov AX, stack 
        mov SS, AX 
        mov SP, stacktop
        
        ;Saving current video mode
        mov AX, 0x0F00
        int 0x10
        mov word[videoMode], AX        

        ;Switch to  graphics mode - 320x200 256
        xor AX, AX
        mov AL, 0x13
        int 0x10
        
        ;Adding offset to the video card to ES
        mov AX, 0xA000 ; The offset to video memory
	    mov ES, AX ; We load it to ES through AX, becouse immediate operation is not allowed on ES
        
        call drawFrame
        call drawNextPieceFrame
        jmp gameInProgres
        
endOfGame:        
        call delayForLongWhile
        call displayGameOver
        call delayForLongWhile
        
        ;Return to previous video mode
        mov AX, word[videoMode]  
        xor AH, AH
        int 0x10
        
        ;Finish program
        mov AX, 0x4C00 
        int 0x21  
        
;/////DRAWING FUNCTIONS////
;////////////////////////////////////////////////////////////        
;Draw Rectangle, AX - begin point, CX - Height, BX - Width, DL - color
drawRect:
	
loop1_drawRect:
		dec CX
		add AX, 320
		mov DI, AX
		
		push CX
		mov CX, BX
	
loop2_drawRect:	
			mov [ES:DI], DL
			inc DI
			
			loop  loop2_drawRect
	
		pop CX
		cmp CX, 0
		jne loop1_drawRect
	
	ret	
;////////////////////////////////////////////////////////////	
drawFrame:
	mov DL, 7
	
	;Gora
	mov AX, frameBeginningY * 320 + frameBeginningX
    mov CX, frameBorderWidth 
    mov BX, frameWidth + 2 * frameBorderWidth
    call drawRect
	
	;Lewa
	mov AX, (frameBeginningY + frameBorderWidth) * 320 + frameBeginningX
	mov CX, frameHeight
	mov BX, frameBorderWidth
	call drawRect
	
	;Prawa
	mov AX, (frameBeginningY + frameBorderWidth) * 320 + frameBeginningX + frameWidth + frameBorderWidth
	mov CX, frameHeight
	mov BX, frameBorderWidth
	call drawRect
	
	;Dol
	mov AX, (frameBeginningY + frameHeight + frameBorderWidth) * 320 + frameBeginningX
    mov CX, frameBorderWidth
    mov BX, frameWidth + 2 * frameBorderWidth
    call drawRect
        
    ret
;////////////////////////////////////////////////////////////        
drawNextPieceFrame:
	mov DL, 7
	
	;Gora
	mov AX, nextPieceFrameBeginningY * 320 + nextPieceFrameBeginningX
    mov CX, nextPieceFrameBorderWidth 
    mov BX, nextPieceFrameWidth + 2 * nextPieceFrameBorderWidth
    call drawRect
	
	;Lewa
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth) * 320 + nextPieceFrameBeginningX
	mov CX, nextPieceFrameHeight
	mov BX, nextPieceFrameBorderWidth
	call drawRect
	
	;Prawa
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth) * 320 + nextPieceFrameBeginningX + nextPieceFrameWidth + nextPieceFrameBorderWidth
	mov CX, nextPieceFrameHeight
	mov BX, nextPieceFrameBorderWidth
	call drawRect
	
	;Dol
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameHeight + nextPieceFrameBorderWidth) * 320 + nextPieceFrameBeginningX
    mov CX, nextPieceFrameBorderWidth
    mov BX, nextPieceFrameWidth + 2 * nextPieceFrameBorderWidth
    call drawRect
        
    ret
;////////////////////////////////////////////////////////////
drawBoardState:
    mov BX, 200
    
drawBoardStateLoop1:
        dec BX    
        push BX
        
        mov DL, byte[boardState + BX]
        mov AX, BX
        
        call drawOneSquare
        
        pop BX
        cmp BX, 0
    jne drawBoardStateLoop1
    
    ret
;////////////////////////////////////////////////////////////
clearBoard:
    mov AX, (frameBeginningY + frameBorderWidth) * 320 + frameBeginningX + frameBorderWidth
	mov CX, frameHeight
	mov BX, frameWidth
	mov DL, boardColor
	call drawRect
	
	ret
;////////////////////////////////////////////////////////////
drawTetromino:
    
    xor AX, AX
    mov AL, byte[piecePos]
    mov DL, byte[pieceCol]
    call drawOneSquare
    xor AX, AX
    mov AL, byte[piecePos + 1]
    mov DL, byte[pieceCol]
    call drawOneSquare
    xor AX, AX
    mov AL, byte[piecePos + 2]
    mov DL, byte[pieceCol]
    call drawOneSquare
    xor AX, AX
    mov AL, byte[piecePos + 3]
    mov DL, byte[pieceCol]
    call drawOneSquare
    
    ret
;////////////////////////////////////////////////////////////
;AX - PieceNumber, DL - color
drawOneSquare:
    
    ;Save color
    push DX    
    
    mov BL, 10
    div BL
    
    ;AH - X, AL - Y
    mov CX, AX
    
    ;Calculate Y offset
    mov AL, CL
    xor AH, AH
    mov BX, 320 * pieceSize
    mul BX
    
    push AX
    ;Calculate X offset
    mov AL, CH
    xor AH, AH 
    mov BX, pieceSize
    mul BX
    
    pop DX
    
    ;Move to fit frame
    add AX, DX
    add AX, (frameBeginningY + frameBorderWidth) * 320 + frameBeginningX + frameBorderWidth
    
    ;Restore color
    pop DX 
    mov BX, pieceSize
    mov CX, pieceSize
    
    jmp drawRect
;/////GAME FUNCTIONS////
;////////////////////////////////////////////////////////////
gameInProgres: ;-TO DO
    mov byte[waitTime], 40
    call generateNextPieceNumber
placeNext:
    call updateBoard
    
    call generateNextPiece
    call generateNextPieceNumber    
    call setNewDelay
    call writeScore
    
    jmp checkIfNotEnd
    
pieceInProgress:   
        call clearBoard
        call drawBoardState
        call drawTetromino
        
        call scoreToString
        
        call getPlayerInput
        cmp AX, 0x0F0F      
        
        ;AX = FFFF - Place Next Piece        
        cmp AX, 0xFFFF
        je placeNext 
          
        call moveOneDown
        cmp AX, 0xFFFF
        je placeNext
    
    jmp pieceInProgress
    
;---------
checkIfNotEnd:
    xor BX, BX
    mov BL, byte[piecePos]
    mov AL, byte[boardState + BX]
    cmp AL, boardColor
    jne endOfGame
    
    mov BL, byte[piecePos + 1]
    mov AL, byte[boardState + BX]
    cmp AL, boardColor
    jne endOfGame
    
    mov BL, byte[piecePos + 2]
    mov AL, byte[boardState + BX]
    cmp AL, boardColor
    jne endOfGame
    
    mov BL, byte[piecePos + 3]
    mov AL, byte[boardState + BX]
    cmp AL, boardColor
    jne endOfGame
    
    jmp pieceInProgress
;////////////////////////////////////////////////////////////
getPlayerInput:      
    xor CX, CX 
    mov CL, byte[waitTime]  
waitForKey:   
        dec CX
        cmp CX, 0
        je noInput
                
        mov AH, 0x01
        int 0x16            
        jnz gotKey        
        
        push CX
        call delayForWhile
        pop CX
        
        jmp waitForKey    
gotKey:
    xor AH, AH
    int 0x16
    
    cmp AH, 0x1E
    je moveOneLeft
    cmp AH, 0x1F
    je downKey
    cmp AH, 0x20
    je moveOneRight
    cmp AH, 0x10
    je rotateCounterClockwise
    cmp AH, 0x12
    je rotateClockwise
    cmp AH, 0x01
    je endOfGame
    
    jmp noInput    
noInput:
    xor AX, AX  
    ret
    
downKey:
    inc word[score]
    jmp moveOneDown
;////////////////////////////////////////////////////////////
generateNextPieceNumber:
    mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth
    mov CX, nextPieceFrameHeight
    mov BX, nextPieceFrameWidth
    mov DL, boardColor
    call drawRect

    mov AH, 0x2C
	int 0x21
	
	xor AX, AX
	mov AL, DL
	add AL, DH
	
	mov CL, 7
	div CL
	mov byte[nextPieceType], AH	
	
	
genFirstPiece:	;I
    cmp AH, 0
	jne genSecondPiece
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + 4
    mov CX, pieceSize 
    mov BX, 4 * pieceSize
    mov DL, 52
    call drawRect	
	
	ret
genSecondPiece:	;J
	cmp AH, 1
	jne genThirdPiece
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, 3 * pieceSize
    mov DL, 32
    call drawRect
    
    mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + 3 * pieceSize
    mov CX, pieceSize 
    mov BX, pieceSize
    mov DL, 32
    call drawRect	
	
	ret	
genThirdPiece:	;L
    cmp AH, 2
	jne genForthPiece	
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, 3 * pieceSize
    mov DL, 43
    call drawRect
    
    mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, pieceSize
    mov DL, 43
    call drawRect
	
	ret	
genForthPiece:	;O
	cmp AH, 3
	jne genFifthPiece
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize + 4
    mov CX, 2 * pieceSize 
    mov BX, 2 * pieceSize
    mov DL, 45
    call drawRect
	
	ret	
genFifthPiece:	;S
	cmp AH, 4
	jne genSixthPiece
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + 2 * pieceSize
    mov CX, pieceSize 
    mov BX, 2 * pieceSize
    mov DL, 48
    call drawRect
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, 2 * pieceSize
    mov DL, 48
    call drawRect
	
	ret	
genSixthPiece:	;T
	cmp AH, 5
	jne genSeventhPiece	
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, 3 * pieceSize
    mov DL, 34
    call drawRect
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + 2 * pieceSize
    mov CX, pieceSize 
    mov BX, pieceSize
    mov DL, 34
    call drawRect
	
	ret	
genSeventhPiece: ;Z

	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + pieceSize
    mov CX, pieceSize 
    mov BX, 2 * pieceSize
    mov DL, 40
    call drawRect
	
	mov AX, (nextPieceFrameBeginningY + nextPieceFrameBorderWidth + 2 * pieceSize + 4) * 320 + nextPieceFrameBeginningX + nextPieceFrameBorderWidth + 2 * pieceSize
    mov CX, pieceSize 
    mov BX, 2 * pieceSize
    mov DL, 40
    call drawRect
	
	ret
;---------------------	
generateNextPiece:
	mov AH, byte[nextPieceType]
	mov byte[pieceType], AH
	mov byte[piecePivotPos], 3
	
	
firstPiece:	;I
	cmp AH, 0
	jne secondPiece	
	
	mov byte[piecePos], 13
	mov byte[piecePos + 1], 14
	mov byte[piecePos + 2], 15
	mov byte[piecePos + 3], 16
	mov byte[pieceCol], 52
	
	ret
secondPiece:	;J
	cmp AH, 1
	jne thirdPiece
	
	mov byte[piecePos], 13
	mov byte[piecePos + 1], 14
	mov byte[piecePos + 2], 15
	mov byte[piecePos + 3], 25
	mov byte[pieceCol], 32
	
	ret	
thirdPiece:	;L
    cmp AH, 2
	jne forthPiece	
	
	mov byte[piecePos], 13
	mov byte[piecePos + 1], 14
	mov byte[piecePos + 2], 15
	mov byte[piecePos + 3], 23
	mov byte[pieceCol], 43
	
	ret	
forthPiece:	;O
	cmp AH, 3
	jne fifthPiece
	
	mov byte[piecePos], 14
	mov byte[piecePos + 1], 15
	mov byte[piecePos + 2], 24
	mov byte[piecePos + 3], 25
	mov byte[pieceCol], 45
	
	ret	
fifthPiece:	;S
	cmp AH, 4
	jne sixthPiece
	
	mov byte[piecePos], 14
	mov byte[piecePos + 1], 15
	mov byte[piecePos + 2], 23
	mov byte[piecePos + 3], 24
	mov byte[pieceCol], 48
	
	ret	
sixthPiece:	;T
	cmp AH, 5
	jne seventhPiece	
	
	mov byte[piecePos], 13
	mov byte[piecePos + 1], 14
	mov byte[piecePos + 2], 15
	mov byte[piecePos + 3], 24
	mov byte[pieceCol], 34
	
	ret	
seventhPiece:	;Z
	mov byte[piecePos], 13
	mov byte[piecePos + 1], 14
	mov byte[piecePos + 2], 24
	mov byte[piecePos + 3], 25
	mov byte[pieceCol], 40
	
	ret
;///////////////////////////////////////////////////////////    
solidifyPiece:
    xor BX, BX
    mov BL, byte[piecePos]
    mov AL, byte[pieceCol]
    mov byte[boardState + BX], AL
    
    mov BL, byte[piecePos + 1]
    mov byte[boardState + BX], AL
    
    mov BL, byte[piecePos + 2]
    mov byte[boardState + BX], AL
    
    mov BL, byte[piecePos + 3]
    mov byte[boardState + BX], AL
    
    ret
;///////////////// - TO DO
updateBoard:
    mov DL, 20
updateBoardLoop:
        dec DL
        call clearOneRow
        cmp DL, 0 
    jne updateBoardLoop

    ret
clearOneRow:
;DL - row To clear
    mov BL, 10
    mov AL, DL
    mul BL
    
    mov BX, AX
    
    mov CX, 10    
clearOneRowLoop1:
        cmp byte[boardState + BX], boardColor        
        je notclearOneRow         
        inc BX    
        
    loop clearOneRowLoop1
    
    add word[score], 100    
    
    cmp DL, 0
    je notclearOneRow
    
    push DX      
clearOneRowLoop2:   
        dec DL
        call moveRowDown        
        cmp DL, 1
        jne clearOneRowLoop2
    
    pop DX
    jmp clearOneRow
notclearOneRow:
    ret
    
moveRowDown:
;DL - beginRow
    mov BL, 10
    mov AL, DL
    mul BL
    
    mov BX, AX
    
    mov CX, 10    
moveRowDownLoop:
        mov AL, byte[boardState + BX]
        mov byte[boardState + BX + 10], AL   
        mov byte[boardState + BX], boardColor
        
        inc BX    
    loop moveRowDownLoop
        
    ret
;///////////////// - TO DO
moveOneDown:
    xor AX, AX
    mov BL, 10
    xor DL, DL  
    
    ;Check Frame Collision    
    cmp byte[piecePos], 19 * 10
    jae cantMoveOneDown
    cmp byte[piecePos + 1], 19 * 10
    jae cantMoveOneDown
    cmp byte[piecePos + 2], 19 * 10
    jae cantMoveOneDown
    cmp byte[piecePos + 3], 19 * 10
    jae cantMoveOneDown
    
    ;Check Space Collsion
    xor BX, BX
    mov BL, byte[piecePos]
    add BL, 10
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneDown
    mov BL, byte[piecePos + 1]
    add BL, 10
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneDown
    mov BL, byte[piecePos + 2]
    add BL, 10
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneDown
    mov BL, byte[piecePos + 3]
    add BL, 10
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneDown    

    add byte[piecePos], 10
    add byte[piecePos + 1], 10
    add byte[piecePos + 2], 10
    add byte[piecePos + 3], 10
    
    add byte[piecePivotPos], 10
    
    xor AX, AX  
    ret    
cantMoveOneDown:  
    call solidifyPiece
    mov AX, 0xFFFF       
    ret
;-----------------------------------
moveOneLeft:
    mov BL, 10   
    
    ;Check Frame Collision
    xor AX, AX
    mov AL, byte[piecePos]
    div BL
    cmp AH, 0   
    je cantMoveOneLeft    
    xor AX, AX
    mov AL, byte[piecePos + 1]
    div BL
    cmp AH, 0    
    je cantMoveOneLeft    
    xor AX, AX
    mov AL, byte[piecePos + 2]
    div BL
    cmp AH, 0    
    je cantMoveOneLeft    
    xor AX, AX
    mov AL, byte[piecePos + 3]
    div BL
    cmp AH, 0    
    je cantMoveOneLeft
    
    ;Check Space Collsion
    xor BX, BX
    mov BL, byte[piecePos]
    dec BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneLeft
    mov BL, byte[piecePos + 1]
    dec BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneLeft
    mov BL, byte[piecePos + 2]
    dec BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneLeft
    mov BL, byte[piecePos + 3]
    dec BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneLeft    

    dec byte[piecePos]
    dec byte[piecePos + 1]
    dec byte[piecePos + 2]
    dec byte[piecePos + 3]
    
    dec byte[piecePivotPos]
    
cantMoveOneLeft:  
    xor AX, AX  
    ret
;-----------------------------------   
moveOneRight:    
    mov BL, 10
    
    ;Check Frame Collision
    xor AX, AX
    mov AL, byte[piecePos]
    div BL
    cmp AH, 9       
    je cantMoveOneRight
    xor AX, AX   
    mov AL, byte[piecePos + 1]
    div BL
    cmp AH, 9    
    je cantMoveOneRight 
    xor AX, AX   
    mov AL, byte[piecePos + 2]
    div BL
    cmp AH, 9    
    je cantMoveOneRight
    xor AX, AX    
    mov AL, byte[piecePos + 3]
    div BL
    cmp AH, 9    
    je cantMoveOneRight
    
    ;Check Space Collsion
    xor BX, BX
    mov BL, byte[piecePos]
    inc BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneRight
    mov BL, byte[piecePos + 1]
    inc BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneRight
    mov BL, byte[piecePos + 2]
    inc BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneRight
    mov BL, byte[piecePos + 3]
    inc BL
    cmp byte[boardState + BX], boardColor
    jne cantMoveOneRight    

    inc byte[piecePos]
    inc byte[piecePos + 1]
    inc byte[piecePos + 2]
    inc byte[piecePos + 3]
     
    inc byte[piecePivotPos]
    
cantMoveOneRight:
    ret
    
rotateClockwise:
    ;CheckBoard
    mov BX, 4
    
rotateClockwiseLoop1:    
        dec BX
        push BX
        
        xor AX, AX
        mov BL, 10
        mov AL, byte[piecePivotPos]
        div BL
        
        pop BX
        cmp AH, 0
        jb cantRotateClockwise
        cmp AH, 6
        ja cantRotateClockwise
        cmp AL, 16
        ja cantRotateClockwise
        
        mov CX, AX
        xor AX, AX
        
        mov AL, byte[piecePos + BX]
        push BX
        
        mov BL, 10
        sub AL, byte[piecePivotPos]        
        div BL
        mov DX, AX
        
        ;AH - X, AL - Y
        mov AH, DL
        cmp byte[pieceType], 0
        je rotateClockwiseSpc        
        mov AL, 3
rotateClockwiseSpcBack:
        sub AL, DH    
        mov DX, AX
        
        mov AL, DL
        mov BL, 10
        mul BL
        add AL, DH
        
        pop BX
        add AL, byte[piecePivotPos]
        mov byte[temporaryPiecePos + BX], AL
        
        cmp BX, 0
    jne rotateClockwiseLoop1    
    
    xor BX, BX
    mov BL, byte[temporaryPiecePos]
    cmp byte[boardState + BX], boardColor
    jne cantRotateClockwise
    mov BL, byte[temporaryPiecePos + 1]
    cmp byte[boardState + BX], boardColor
    jne cantRotateClockwise
    mov BL, byte[temporaryPiecePos + 2]
    cmp byte[boardState + BX], boardColor
    jne cantRotateClockwise
    mov BL, byte[temporaryPiecePos + 3]
    cmp byte[boardState + BX], boardColor
    jne cantRotateClockwise
    
    mov AL, byte[temporaryPiecePos]
    mov byte[piecePos], AL
    mov AL, byte[temporaryPiecePos + 1]
    mov byte[piecePos + 1], AL
    mov AL, byte[temporaryPiecePos + 2]
    mov byte[piecePos + 2], AL
    mov AL, byte[temporaryPiecePos + 3]
    mov byte[piecePos + 3], AL
    
cantRotateClockwise:
    xor AX, AX
    ret
    
rotateClockwiseSpc:
    mov AL, 4
    jmp rotateClockwiseSpcBack      
;/////////////////
rotateCounterClockwise:
    ;CheckBoard
    mov BX, 4
    
rotateCounterClockwiseLoop1:    
        dec BX
        push BX
        
        xor AX, AX
        mov BL, 10
        mov AL, byte[piecePivotPos]
        div BL
        
        pop BX
        cmp AH, 0
        jb cantRotateCounterClockwise
        cmp AH, 6
        ja cantRotateCounterClockwise
        cmp AL, 16
        ja cantRotateCounterClockwise
        
        mov CX, AX
        xor AX, AX
        
        mov AL, byte[piecePos + BX]
        push BX
        
        mov BL, 10
        sub AL, byte[piecePivotPos]        
        div BL
        mov DX, AX
        
        ;AH - X, AL - Y
        mov AL, DH
        cmp byte[pieceType], 0
        je rotateCounterClockwiseSpc        
        mov AH, 3
rotateCounterClockwiseSpcBack:
        sub AH, DL
        mov DX, AX
        
        mov AL, DL
        mov BL, 10
        mul BL
        add AL, DH
        
        pop BX
        add AL, byte[piecePivotPos]
        mov byte[temporaryPiecePos + BX], AL
        
        cmp BX, 0
    jne rotateCounterClockwiseLoop1    
    
    xor BX, BX
    mov BL, byte[temporaryPiecePos]
    cmp byte[boardState + BX], boardColor
    jne cantRotateCounterClockwise
    mov BL, byte[temporaryPiecePos + 1]
    cmp byte[boardState + BX], boardColor
    jne cantRotateCounterClockwise
    mov BL, byte[temporaryPiecePos + 2]
    cmp byte[boardState + BX], boardColor
    jne cantRotateCounterClockwise
    mov BL, byte[temporaryPiecePos + 3]
    cmp byte[boardState + BX], boardColor
    jne cantRotateCounterClockwise
    
    mov AL, byte[temporaryPiecePos]
    mov byte[piecePos], AL
    mov AL, byte[temporaryPiecePos + 1]
    mov byte[piecePos + 1], AL
    mov AL, byte[temporaryPiecePos + 2]
    mov byte[piecePos + 2], AL
    mov AL, byte[temporaryPiecePos + 3]
    mov byte[piecePos + 3], AL
    
cantRotateCounterClockwise:
    xor AX, AX
    ret
    
rotateCounterClockwiseSpc:
    mov AH, 4
    jmp rotateCounterClockwiseSpcBack      
;/////////////////
;Delay for one second
delayForWhile:
    mov CX, 0x0000
    mov DX, 0x8480
    mov AH, 0x86
    xor AL, AL
    int 0x15
    
    ret
;--------------------
delayForLongWhile:
    mov CX, 0x000F
    mov DX, 0x8480
    mov AH, 0x86
    xor AL, AL
    int 0x15
    
    ret
;/////////////////
setNewDelay:
    cmp byte[waitTime], 1
    jb noSetNewDelat
    
    mov AX, word[score]
    
    xor DX, DX
    mov BX, 1000
    div BX
    
    mov DX, AX
    mov AX, 40
    
    cmp AX, DX
    jl set1Delay
    sub AX, DX
    
    mov byte[waitTime], AL
noSetNewDelat:
    ret
    
set1Delay:
    mov byte[waitTime], 1
    ret
;/////////////////
scoreToString:    
    xor DX, DX
    mov AX, word[score]    
    mov BX, 10000
    div BX
    add AX, 48    
    mov byte[scoreAsString], AL
            
    mov AX, DX
    xor DX, DX    
    mov BX, 1000
    div BX
    add AX, 48    
    mov byte[scoreAsString + 1], AL
     
    mov AX, DX
    xor DX, DX
    mov BX, 100
    div BX
    add AX, 48    
    mov byte[scoreAsString + 2], AL
        
    mov AX, DX
    xor DX, DX
    mov BX, 10
    div BX
    add AX, 48    
    mov byte[scoreAsString + 3], AL
    add DX, 48 
    mov byte[scoreAsString + 4], DL
    
    mov BX, 5    
    mov DL, 24
scoreToString_loop:
    dec BX
    push BX
    
    mov AH, 0x02
    xor BH, BH
    mov DH, 12
    int 0x10
    
    mov AH, 0x0A
    pop BX
    mov AL, byte[scoreAsString + BX]
    push BX
    
    mov BL, 0x41
    mov CX, 0x01
    int 0x10
    
    pop BX
    dec DL
    
    cmp BX, 0
    jne scoreToString_loop    
    
    ret    
;////////////////////////
writeScore:
    
	mov BX, 5  
    mov DL, 24
displayScoreString_loop:
		dec BX
		push BX
		
		mov AH, 0x02
		xor BH, BH
		mov DH, 10
		int 0x10
		
		mov AH, 0x0A
		pop BX
		mov AL, byte[scoreString + BX]
		push BX
		
		mov BL, 0x07
		mov CX, 0x01
		int 0x10
		
		pop BX
		dec DL
		
		cmp BX, 0
    jne displayScoreString_loop 
    
    ret 
    
;----------------
displayGameOver:
	xor AX, AX
	mov CX, 200
	mov BX, 320
	mov DL, boardColor
	call drawRect
	
	mov BX, 9  
    mov DL, 22
displayGameOver_loop:
		dec BX
		push BX
		
		mov AH, 0x02
		xor BH, BH
		mov DH, 12
		int 0x10
		
		mov AH, 0x0A
		pop BX
		mov AL, byte[gameOver + BX]
		push BX
		
		mov BL, 0x28
		mov CX, 0x01
		int 0x10
		
		pop BX
		dec DL
		
		cmp BX, 0
    jne displayGameOver_loop   
    
    ret       
segment stack stack
    resb 512
stacktop:

