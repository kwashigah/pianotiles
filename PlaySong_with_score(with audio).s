#Song Arrays: Mary Has A Little Lamb
#Notes Written as KEY INPUT 
#Duration Written as TIMERPERIOD

#Characters
.equ ADDR_VGA, 0x08000000
.equ AUDIO_BASE, 0xFF203040
.equ TIMER0_BASE,      0xFF202000
.equ TIMER1_BASE,	   0xFF202020
.equ  TIMER_STATUS,    0
.equ  TIMER_CONTROL,   4
.equ  TIMER_PERIODL,   8
.equ  TIMER_PERIODH,   12
.equ  TIMER_SNAPL,     16
.equ  TIMER_SNAPH,     20

.equ PS2_BASE, 0xFF200100
.equ VALID_BIT_PS2, 0x8000
.equ PS2_CTRL, 4
.equ RED_LEDS, 0xFF200000

.equ A, 0x1C
.equ W, 0x1D
.equ S, 0x1B
.equ E, 0x24
.equ D, 0x23
.equ F, 0x2B
.equ T, 0x2C
.equ G, 0x34
.equ Y, 0x35
.equ H, 0x33
.equ U, 0x3C
.equ J, 0x3B
.equ K, 0x42
.equ RELEASE_CONST, 0xF0
.equ stackaddress, 0x03fffffc

#Half Periods of the notes we're going to play (w/ 44000 samples per second)
.equ C4, 0x54
.equ C4s, 0x4F
.equ D4, 0x4B
.equ D4s, 0x47
.equ E4, 0x43
.equ F4, 0x3F
.equ F4s, 0x3B
.equ G4, 0x38
.equ G4s, 0x35
.equ A4, 0x32
.equ A4s, 0x2F
.equ B4, 0x2D
.equ C5, 0x2A

#Note Durations
.equ defaultRest,   0x01C9C380 #0.3s
.equ eighthNote,	0x02FAF080 #0.5s
.equ quarterNote,	0x05F5E100 #1.0s
.equ halfNote,		0x0BEBC200 #2.0s
.equ wholeNote,		0x17D78400 #4.0s
#Average reaction time to visual stimuli
.equ REACTION_TIME, 0x017D7840 #0.25s



.data
.align 1
LambNotes:
	.hword	D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, G, RELEASE_CONST, G, RELEASE_CONST
	.hword	D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST
	.hword	D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, G, RELEASE_CONST, G, RELEASE_CONST
	.hword	D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, S, RELEASE_CONST, D, RELEASE_CONST, S, RELEASE_CONST, A, RELEASE_CONST, 0
CurrentNote:
	.hword RELEASE_CONST

CurrentNotePressed:
	.hword RELEASE_CONST
    
.align 2
LambDuration:
	.word	quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest
	.word	quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, wholeNote, defaultRest
	.word	quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, halfNote, defaultRest
	.word	quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, quarterNote, defaultRest, wholeNote, defaultRest, 0
Score:
	.word 0x0

.global _start

.text

_start:

	
	movia sp, stackaddress #allocate stack
	
	movia r8, RED_LEDS
	stwio r0, 0(r8)
	
    movia r8, PS2_BASE
    movia r9, AUDIO_BASE
    
    #Clear the left & right FIFOs of AUDIO_BASE
	movi r10, 0b1100
	ldwio r11, 0(r9)
	or r11, r10, r11
	stwio r11, 0(r9)
	stwio r0, 0(r9)

    #enable interrupts
	#ps2
	ldwio r10, PS2_CTRL(r8)
	addi r10, r10, 1
	stwio r10, PS2_CTRL(r8)
    #audio
    ldwio r10, 0(r9)
    ori r10, r10, 0x02
    stwio r10, 0(r9)
    
    
#enable irq
	
	#enable for PS2
	addi r10, r0, 0x80
    #enable for Audio Core
    addi r11, r0, 0x40
    or r10, r10, r11	
	wrctl ctl3, r10
	addi r10, r0, 0x1	
	wrctl ctl0, r10


    movi r16, 48	# Half period "off" = 48 samples
    movi r17, 0	# Audio sample value "off" = 0
    mov r18, r16
    
Loop:
	movia r4, LambNotes
    movia r5, LambDuration
    
    call PLAY_SONG
    
    br Loop
    
    

# r4 ->location of the beginning of note arrays
# r5 -> location of beginning of duration arrays
# save registers r8-r11 before calling!
PLAY_SONG:
	#save the return address
    addi sp, sp, -16
    stw ra, 12(sp)

	#move values of location to r8 and r9
    mov r8, r4 #notes
    mov r9, r5 #duration
    
GO_THROUGH:
    
    #check if terminating condition
    movi r10, 0
    ldh r10, 0(r8)
    beq r10, r0, FINISH_SONG #if NULL, return
    
    #store current note into global note array
    movia r11, CurrentNote
    sth r10, 0(r11)
    
    #draw the colour on the screen
    
    stw r8, 8(sp) #store r8
    stw r9, 4(sp) #store r9
    stw r10, 0(sp) #store r10

    mov r4, r10
    call CHOOSE_COLOUR
    
    mov r4, r2 
    movi r5, 40
    movi r6, 50
    movia r7, 123200
    
    call DRAW_SQUARE
    ldw r9, 4(sp) #restore r9
    
    #load duration into r4 
    ldw r4, 0(r9)
    
    #call duration timer function
    call NOTE_TIMER_FUNCTION
    
    ldw r10, 0(sp) #restore r8
    ldw r9, 4(sp) #restore r9
    ldw r8, 8(sp) #restore r10
    
    #poll until the timer times out
	movia r11, TIMER0_BASE
TIMER_POLL:
	ldwio r10, 0(r11) 	#check if the TO bit of the status register is 1
    andi r10, r10, 0x1
    beq r10, r0, TIMER_POLL
    
    movi r10, 0x03		#clear TO bit
    stwio r10, 0(r11)

INCREMENT:
    #increment r8 and r9, the location timers to
    # go to the next note
    
    addi r8, r8, 2
    addi r9, r9, 4
    
	br GO_THROUGH
    
FINISH_SONG:
    #pop the return address
    ldw ra, 12(sp)
    addi sp, sp, 16
    
    ret

.section .exceptions, "ax"
.align 2

TERMINAL_HANDLER:

	#acknowledge interrupt when reading from PS2 
    #store registers to stack code here
	addi sp, sp, -24 #-4*numOfVals
    stw ra, 20(sp)
    stw r10, 16(sp)
    stw r11, 12(sp)
    stw r9, 8(sp)
    stw r8, 4(sp)
    stw r4, 0(sp)

CHECK_INTERRUPT_SOURCE:
	#check to see if interrupt pending for keyboard (keyboard takes priority??)
    movia r8, PS2_BASE
    ldwio r9, 4(r8)
    andi r9, r9, 0x100
    bne r9, r0, KEYBOARD_INTERRUPT
    #check to see if interrupt pending for audio core
    movia r8, AUDIO_BASE
    ldwio r9, 0(r8)
    andi r9, r9, 0x200
    bne r9, r0, AUDIO_INTERRUPT
    
KEYBOARD_INTERRUPT:

READ_POLL__:	    
    movia r8, PS2_BASE
    
	ldwio r10, 0(r8) 
	movia r11, VALID_BIT_PS2
	and r11, r11, r10
	srli r11, r11, 15
	beq r11, r0, READ_POLL__ #if not ready for read, repeat polling
    
    andi r10, r10, 0xFF #get value of key
    
    
 	movia r11, CurrentNotePressed
    ldh r9, 0(r11) #get current note pressed
    
	
	#CHANGE_NOTE_FUNCTION (contains WRITE_AUDIO_FUNCTION)
    addi sp, sp, -4
    stw r10, 0(sp)
    
	mov r4, r10
	call CHANGE_NOTE_FUNCTION
    
    ldw r10, 0(sp)
	addi sp, sp, 4
    
	#return r2 == 1 if same note still playing
	bne r2, r0, exit
    
    #if the note pressed is the same note, don't do anything
    #beq r9, r10, exit
    
    sth r10, 0(r11) #store in current note pressed
    
    #update score
    mov r4, r10
    
    call UPDATE_SCORE
    
    br exit
    
AUDIO_INTERRUPT:
	
	call WRITE_AUDIO_FUNCTION
		

exit:	
	ldw r4, 0(sp)
    ldw r8, 4(sp)
    ldw r9, 8(sp)
    ldw r11, 12(sp)
    ldw r10, 16(sp)
    ldw ra, 20(sp)
    
    addi sp, sp, 24
    
	subi ea, ea, 4
	eret
#drawing a square subroutine, can be used to initialize screen too
#arguments:
#	r4: colour
# 	r5: width
#	r6: height
#	r7: starting offset (top left corner)
#	remember to store r8-r11 before you call! and to pop it after!
DRAW_SQUARE:
    #subi sp, sp, 4
    #stw ra, 0(sp) #saving return address
    
	mov r8, r5 #width value
    mov r9, r6 #height value 
    
   	movi r11, 0 #initialize x counter
    
    movia r10, ADDR_VGA
    add r10, r10, r7 #starting address, top left corner of square 
	
DRAW_ROW:   
    #draw pixel
    sthio r4, 0(r10)
    
    #add two to address, add two to x position counter
    addi r10, r10, 2
    addi r11, r11, 2
    
    #decrement width
    subi r8, r8, 1
    
    beq r8, r0, DECREASE_ROW
    br DRAW_ROW

DECREASE_ROW:
	addi r9, r9, -1
    addi r10, r10, 1024
    sub r10, r10, r11 #subtract x position, so we start back again
    
    movi r11, 0 #x counter to 0
    
    mov r8, r5
    bne r9, r0, DRAW_ROW
    
EXIT:
    #ldw ra, 0(sp)
    #addi sp, sp, 4 #restoring return address    
    ret 
#END OF DRAW_SQUARE_FUNCTION

# r4 -> note to be played 
# r2 -> colour to be drawn
# store r8-r9 before calling!
#CHOOSE_COLOUR
CHOOSE_COLOUR:
	mov r8, r4
	#check if A
    movi r9, A
    beq r8, r9, Colour1
	
	#check if W
	movi r9, W
    beq r8, r9, Colour2
    
	#check if S
    movi r9, S
    beq r8, r9, Colour3
	
	#check if E
	movi r9, E
    beq r8, r9, Colour4
    
	#check if D
    movi r9, D
    beq r8, r9, Colour5
    
	#check if F
    movia r9, F
    beq r8, r9, Colour6
    
	#check if T
	movia r9, T
    beq r8, r9, Colour7
	
	#check if G
    movi r9, G
    beq r8, r9, Colour8
	
	#check if Y
	movi r9, Y
    beq r8, r9, Colour9
	
	#check if H
	movi r9, H
	beq r8, r9, Colour10
	
	#check if U
	movi r9, U
	beq r8, r9, Colour11
	
	#check if J
	movi r9, J
	beq r8, r9, Colour12
	
	#check if K
	movi r9, K
	beq r8, r9, Colour13
    
	#else, turn off
	br OFF
	
Colour1:
	#C4
	movia r2, 0xF800
	ret
Colour2:
	#C4s
	movia r2, 0xFA80
	ret
Colour3:
	#D4
	movia r2, 0xFBA0
	ret
Colour4:
	#D4s
	movia r2, 0xFD60
	ret
Colour5:
	#E4
	movia r2, 0xFEC0
	ret
Colour6:
	#F4
	movia r2, 0x37E0
	ret
Colour7:
	#F4s
	movia r2, 0x07F4
	ret
Colour8:
	#G4
	movia r2, 0x07FF
	ret
Colour9:
	#G4s
	movia r2, 0x03DF
	ret
Colour10:
	movia r2, 0x015F
	ret
Colour11:
	movia r2, 0x301F
	ret
Colour12:
	movia r2, 0x701F
	ret
Colour13:
	movia r2, 0xC81F
	ret
OFF: 
	movia r2, 0x0000
	ret
    
#NOTE_TIMER_FUNCTION
#location of current note length Duration Array gets passed into r4 ( ldw r4 CURR_NOTE_INDEX(REG_W_ARRAY))
#timer #0 sends interrupt when the note duration is done
#make sure to store and pop r8-r9
NOTE_TIMER_FUNCTION:
	movia r8, TIMER0_BASE
    addi  r9, r0, 0x8                   # stop the counter
    stwio r9, TIMER_CONTROL(r8)

    # Set the period registers to NoteDuration
    add  r9, r0, r4
	#get lower 4 bits
	andi r9, r9, 0x0000FFFF
    stwio r9, TIMER_PERIODL(r8)
	add  r9, r0, r4
	#get upper 4 bits
    srli r9, r9, 16
	andi r9, r9, 0xFFFF
    stwio r9, TIMER_PERIODH(r8)
	
	# tell the counter to interrupt when done and start counting
    addi  r9, r0, 0x6                   # 0x6 = 0101 so we write 1 to START and to ENABLE
    stwio r9, TIMER_CONTROL(r8)
	
	ret
#END OF NOTE_TIMER_FUNCTION

#function for updating the score
# r4 -> the note that the user pressed
# will add 50 if the note was pressed
# otherwise add nothing if it wasn't pressed
# save registers r8-r9
UPDATE_SCORE:
	movia r8, CurrentNote
    ldh r9, 0(r8) #get the value of the current note that's supposed to be played
    
    bne r9, r4, DECREASE_SCORE
    
INCREASE_SCORE:

	movia r8, Score
    ldw r9, 0(r8) #get current store
    
    addi r9, r9, 4 #increment score
    stw r9, 0(r8)
    
    movia r8, RED_LEDS #write to hex display
    stwio r9, 0(r8)
    
    br LEAVE
    
DECREASE_SCORE:
	movia r8, Score
    ldw r9, 0(r8) #get current store
    
	beq r9, r0, LEAVE
    addi r9, r9, -2 #increment score
    stw r9, 0(r8)
    
    movia r8, RED_LEDS #write to hex display
    stwio r9, 0(r8)
	
LEAVE:
	ret
    
#READ_POLL_FUNCTION, 
#	r4 is whatever device you're polling (usually the ps/2, maybe timer?)
#	r5 is the valid bit of the device, used to check if the device is valid
#	r2 returns the valid data that you can now use :3)
#	make sure to store and pop r8-r9
READ_POLL_FUNCTION:	
	ldwio r8, 0(r4) 
	and r9, r5, r8
	srli r9, r9, 15
	beq r9, r0, READ_POLL_FUNCTION #if not ready for read, repeat polling
    #remove extra data
    andi r8, r8, 0xFF
	mov r2, r8
	ret
#END OF READ_POLL_FUNCTION

#uses global variables:
#	r16 -> half period
#	r17 -> amplitude 
#	r18 -> half period countdown 
#This function writes audio to the AUDIO CORE until the device is full
#Takes no inputs and no outputs
#	make sure to store and pop r8-r10
WRITE_AUDIO_FUNCTION:
CHECK_IF_EMPTY:
	#is right FIFO full?
    movia r8, AUDIO_BASE
	ldwio r9, 4(r8)
    andhi r10, r9, 0xff00
    beq r10, r0, EXIT_A
	#is left FIFO full?
    andhi r10, r9, 0x00ff
    beq r10, r0, EXIT_A
    
WriteTwoSamples:
	#write the audio from the global variables to both sides
    stwio r17, 8(r8)
    stwio r17, 12(r8)
    subi r18, r18, 1
    bne r18, r0, CHECK_IF_EMPTY
    
HalfPeriodInvertWaveform:
    mov r18, r16
    sub r17, r0, r17				# 32-bit signed samples: Negate.
    br CHECK_IF_EMPTY
EXIT_A:
	ret
	
#END OF WRITE_AUDIO_FUNCTION

#CHANGE_NOTE_FUNCTION
#If note is given move r4 into r8 instead of calling poll
#uses global variables:
#	r16 -> half period
#	r17 -> amplitude 
#	r18 -> half period countdown 
#	make sure to store and pop r8-r9
CHANGE_NOTE_FUNCTION:
	mov r8, r4
	movi r2, 0 #initialize r2 to 0
CHECK_LETTER:
    
	#check if A
    movi r9, A
    beq r8, r9, PLAY_C4
	
	#check if W
	movi r9, W
    beq r8, r9, PLAY_C4s
    
	#check if S
    movi r9, S
    beq r8, r9, PLAY_D4
	
	#check if E
	movi r9, E
    beq r8, r9, PLAY_D4s
    
	#check if D
    movi r9, D
    beq r8, r9, PLAY_E4
    
	#check if F
    movia r9, F
    beq r8, r9, PLAY_F4
    
	#check if T
	movia r9, T
    beq r8, r9, PLAY_F4s
	
	#check if G
    movi r9, G
    beq r8, r9, PLAY_G4
	
	#check if Y
	movi r9, Y
    beq r8, r9, PLAY_G4s
	
	#check if H
	movi r9, H
	beq r8, r9, PLAY_A4
	
	#check if U
	movi r9, U
	beq r8, r9, PLAY_A4s
	
	#check if J
	movi r9, J
	beq r8, r9, PLAY_B4
	
	#check if K
	movi r9, K
	beq r8, r9, PLAY_C5
    
	#check if key is being released
    movia r9, RELEASE_CONST
	beq r8, r9, READ_POLL_OFF
	#else, turn off
	br TURN_OFF_NOTE

PLAY_C4:
	#check if the note is already being played, if so exit
	movi r8, C4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, C4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_C4s:
	#check if the note is already being played, if so exit
	movi r8, C4s
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, C4s				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_D4:
	#check if the note is already being played, if so exit
	movi r8, D4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, D4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_D4s:
	#check if the note is already being played, if so exit
	movi r8, D4s
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, D4s				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_E4:
	#check if the note is already being played, if so exit
	movi r8, E4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, E4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_F4:
	#check if the note is already being played, if so exit
	movi r8, F4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, F4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4  
	br EXIT_FUNCION
	
PLAY_F4s:
	#check if the note is already being played, if so exit
	movi r8, F4s
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, F4s				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4   
	br EXIT_FUNCION
	
PLAY_G4:
	#check if the note is already being played, if so exit
	movi r8, G4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, G4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_G4s:
	#check if the note is already being played, if so exit
	movi r8, G4s
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, G4s				# Half period
    mov r18, r16
    movia r17, 0x60000000	# Audio sample value
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_A4:
	#check if the note is already being played, if so exit
	movi r8, A4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, A4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_A4s:
	#check if the note is already being played, if so exit
	movi r8, A4s
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, A4s				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_B4:
	#check if the note is already being played, if so exit
	movi r8, B4
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, B4				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
PLAY_C5:
	#check if the note is already being played, if so exit
	movi r8, C5
	beq r8, r16, WRITE_ANYWAY
	#else, play
	movi r16, C5				# Half period
    movia r17, 0x60000000	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
	
READ_POLL_OFF:	
	#don't care about return currently, because only one note plays at a time
	movia r4, PS2_BASE
	movia r5, VALID_BIT_PS2
	addi sp, sp, -4
	stw ra, 0(sp)
	call READ_POLL_FUNCTION
	#do not care about return val, set back to 0
	movi r2, 0
	
	ldw ra, 0(sp)
	addi sp, sp, 4
	
TURN_OFF_NOTE:
    movi r16, 48				# Half period
    movia r17, 0	# Audio sample value
    mov r18, r16
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	br EXIT_FUNCION
WRITE_ANYWAY:
	addi sp, sp, -4
	stw ra, 0(sp)
	call WRITE_AUDIO_FUNCTION
	ldw ra, 0(sp)
	addi sp, sp, 4
	movi r2, 1 #1 if the note is already playing/displaying
EXIT_FUNCION:
	ret
	

	