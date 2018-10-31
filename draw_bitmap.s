.equ ADDR_VGA, 0x08000000

.data
PianoTitle: .incbin "PianoTitle.bmp"
PianoGame: .incbin "PianoGame.bmp"

.text
.global _start

_start:

	movia r4, PianoGame
    call DRAW_BITMAP

Loopy:
	br Loopy

#draws a bitmap which is located a specified address
# r4 ->starting location of bitmap
#save registers r8-r13
DRAW_BITMAP:
    
	movi r8, 320 #width value
    movi r9, 240 #height value 
   
    movia r10, ADDR_VGA
    
	mov r11, r4
    
    #get location of colours
    addi r11, r11, 67 #adding the bitmap offset
    
DRAW_ROW:
	
    ldh r13, 0(r11)
    
    #draw pixel
    sthio r13, 0(r10)
    
    #add two to address, add two to x position counter
    addi r10, r10, 2
    addi r12, r12, 2
    
    #decrement width
    subi r8, r8, 1
    
    #increment bitmap index
    addi r11, r11, 2
    
    beq r8, r0, DECREASE_ROW
    br DRAW_ROW

DECREASE_ROW:
	addi r9, r9, -1
    addi r10, r10, 1024
    sub r10, r10, r12 #subtract x position, so we start back again
    
    movi r12, 0 #x counter to 0
    
    movi r8, 320
    bne r9, r0, DRAW_ROW
    
EXIT:
   
    ret 

#END OF DRAW_SQUARE_FUNCTION
	
	