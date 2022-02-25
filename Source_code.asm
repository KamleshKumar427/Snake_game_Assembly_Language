; Author : Kamlesh Kumar
;LinkedIn : https://www.linkedin.com/in/kamlesh-kumar-389847224/
;Semester Project
INCLUDE Irvine32.inc

.data

wall BYTE 219				; 219 is for Ascii code of basic character of game's border walls 
							; following 4 element represent the positions of 
right_wall BYTE 107
left_wall BYTE 8
up_wall BYTE 2
down_wall BYTE 22
						; following lines declare byte variables to store coordinates of food generated and to check whether food is eaten.
food_X_coord BYTE ?
food_Y_coord BYTE ?
food_eaten BYTE 1

snake BYTE 'X', 39 DUP('x')			; the max length of snake will be 40, and setting head = 'X' and body = 'x' 
x_coords BYTE 40,39,38,37,36,35,34,33 DUP('34')	  ; starting x-coordinates of snake on screen and heading towards right
y_coords BYTE 10,10,10,10,10,10,10,33 DUP('10')	  ; In starting y-coordinates of snake will remain same ie 10
empty_array BYTE 110 DUP(" "),0					; array to print an empty line
mess BYTE "D", 0
score_prompt BYTE " Score: ", 0				; message to print score
end_message BYTE "YOU ARE DEAD!  ",0		; mesage to print end of game

snake_length BYTE 7				; length of snake
score BYTE 0					; initial score = 0
							; following lines simply creates variables to be used in program
count DWORD 0
temp BYTE ?
temp_y BYTE ?
temp_x BYTE ?
death BYTE 0

prev_input BYTE 'l'
input BYTE 'l'
speed WORD 100
delay_temp DWORD ?
										; following lines contain messages for instruction and start menu.
startGame BYTE "Start Game", 0					
instructions BYTE "Instructions", 0			 
exitGame BYTE "Exit Game", 0
arrow BYTE "<--",0
menuInstructions BYTE "i - UP, k - DOWN, s - SELECT", 0 
ins1 BYTE "Controls : i - UP, k - DOWN, l - RIGHT, j - LEFT", 0
ins2 BYTE "- Move the snake around using the controls given above", 0
ins4 BYTE "- If snake touches itself, then it's GAME OVER!", 0
									
									; following lines are ascii design for displaying end of game
gameover_1 BYTE "  ___   __   _  _  ____     __   _  _  ____  ____ ", 0 
gameover_2 BYTE " / __) / _\ ( \/ )(  __)   /  \ / )( \(  __)(  _ \", 0
gameover_3 BYTE "( (_ \/    \/ \/ \ ) _)   (  O )\ \/ / ) _)  )   /", 0
gameover_4 BYTE " \___/\_/\_/\_)(_/(____)   \__/  \__/ (____)(__\_)", 0 
gameover_5 BYTE "               Press any key to exit ",0

.code

main proc

call menu				; calling menu function to print the menu
call clear_screen		; if control returnes from menu procedure then start game otherwise it will exit or only show instructions
mov esi, 0				
call score_display		; first display the score
call draw_boundary		; then draw the boundary
call start_snake		; this function start the game.

exit				; end of main procedure
main endp


start_snake proc USES EAX EDX ESI ECX EBX

mov esi, 0
call generate_food			; this function generates the food within the boundary of game

l1:
							; moving coordinates of snake to temparay variables temp_x and temp_Y
mov bl, x_coords[esi]		; so that we can restore this position in update label
mov bh, y_coords[esi]		
mov temp_x, bl
mov temp_y, bh

call ReadKey		; input from user
jz no_change		; if there is no input then snake will move in the same direction.

mov input, al		; store user_input in variabel input

no_change:

cmp input, 'l'		; if input is l then jump to move_right label
je move_right

cmp input, 'j'		; if input is j then jump to move_left label
je move_left

cmp input, 'i'		; if input is i then jump to move_up label
je move_up

cmp input, 'k'
je move_down		; if input is l then jump to move_down label

mov input, cl		; if input is same as previous then directly update the snake, and leave x_coord and y_coord as it is.
jmp update

move_right:
add x_coords[esi], 1	  ; increment x_coords
jmp update

move_left:
sub x_coords[esi], 1	  ; decrement x_coords
jmp update

move_up:
sub y_coords[esi], 1	  ; decrement y_coords
jmp update

move_down:
add y_coords[esi], 1		; increment  y_coords


update:
mov al, temp_x					 ; move previous x_coord and y_coord to al and ah respectively
mov ah, temp_y				
call check_boundary_collision	 ; check if snake has passed through the boundary(so we can wrap around)
call draw_snake					 ; first call to draw_snake only creates draws the head of Snake as EAX = 0.
call update_snake				 ; and the rest of snake is drawn by using update_snake procedure
call check_food					 ; check if the generated food is being eaten
call check_snake_collision		 ; check if snake has collid with itself

cmp death, 1		; check_snake_collision procedure will sest death = 1 if snake has collided with itself
jne safe			; if not collided then jmp to safe

mov eax, white + (black * 16)
call SetTextColor		; chagnge color to white

call gameover_display	; print the ascii pattern 
mov dl, 0
mov dh, 24
call gotoxy				; move cursor to (0,24)

call readchar		; wait for user to input something
jmp end_game		; jmp to end_game label

safe:		; move here if no collision

mov cl, input			; mov current input in cl 
mov prev_input, cl		; and mov with previous input

mov delay_temp, eax		; delay_temp is a varible use to temperarly save value of eax.
movzx eax, speed		; speed is a also a variable defined in code section
call delay				; simple call for delay 
mov eax, delay_temp		;  restoring value of eax
jmp l1			; since snake is still safe than loop again

end_game:
RET
start_snake endp

menu proc USES EAX EDX
mainMenu:

case1:
	call clear_screen				; procedure to clear the whole screen
	call draw_boundary				; creating the standard boundary of game

	MOV dl, 42				; x = 42
	mov dh, 15				; y= 15
	call gotoxy			; move cursor to (42,15)
	mov edx, OFFSET menuInstructions
	call writestring		; print menu instruction
				
	mov dl, 50				
	mov dh, 10
	call gotoxy		; again move cursor to (50,10)

	mov edx, OFFSET startGame	; print first option for menu
	call writestring			
	mov edx, OFFSET arrow		; initally arrow(simple string of character defined above) wil be at start game option
	call writestring			

	mov dl, 50			; again move cursor to (50,11) i.e to next line 
	mov dh, 11			
	call gotoxy
	mov edx, OFFSET instructions		; print instruction message
	call writestring		

	mov dl, 50		; again move cursor to (50,12)
	mov dh, 12
	call gotoxy
	mov edx, OFFSET exitGame		; print exitGame option
	call writestring			

	call ReadChar			;read character from user
	cmp al, 115				; ASCII for s(selection)
	JE start_menu				; move to label at the end of procedure menu and start the game in main procedure after returning
	cmp al, 107				; ASCII for k
	JE case2					;if press k then go to case2 (where arrow points to instruction option)
	cmp al, 105				; ASCII for i
	JE case3					;if press i then go to case3 (where arrow points to exit option)

case2:				
						; under the label case 2: the same procedure will be followed to print the menu as in 
						; case 1: label but here arrow will point to instructions option.
	call clear_screen		
	call draw_boundary

	mov dl, 42		; again move cursor to (42,15)
	mov dh, 15
	call gotoxy
	mov edx, OFFSET menuInstructions		
	call writestring
			
	mov dl, 50
	mov dh, 10
	call gotoxy

	mov edx, OFFSET startGame
	call writestring

	mov dl, 50
	mov dh, 11
	call gotoxy
	mov edx, OFFSET instructions
	call writestring					
	mov edx, OFFSET arrow			; here arrow is placed after istruction option message
	call writestring

	mov dl, 50
	mov dh, 12
	call gotoxy
	mov edx, OFFSET exitGame
	call writestring

	call ReadChar					; read character from user
	cmp al, 115 ; ASCII for s(selection)		; compare if input is s
	JE instructions_menu		; jmp to label for printing intructions
	cmp al, 107 ; ASCII for k		;
	JE case3			;if press k then go to case3 (where arrow points to exit option)
	cmp al, 105 ; ASCII for i 
	JE case1		;if press i then go to case1 (where arrow points to start game option)

case3:						
						; under the label case 3: the same procedure will be followed to print the menu as in 
						; case 1: label but here arrow will point to exit option of start menu.
	call clear_screen
	call draw_boundary

	mov dl, 42				; move cursor to (42, 15)
	mov dh, 15
	call gotoxy
	mov edx, OFFSET menuInstructions	; printing message in menuInstructions
	call writestring			

	mov dl, 50
	mov dh, 10	
	call gotoxy
	mov edx, OFFSET startGame
	call writestring

	mov dl, 50		
	mov dh, 11
	call gotoxy
	mov edx, OFFSET instructions
	call writestring

	mov dl, 50
	mov dh, 12
	call gotoxy
	mov edx, OFFSET exitGame
	call writestring
	mov edx, OFFSET arrow
	call writestring
				
	call ReadChar			; read input from user
	cmp al, 115 ; ASCII for s(selection)		; if it is s then exit the game
	JE exit_menu			; move to exit_menu label to exit game
	cmp al, 105 ; ASCII for i		; if press i then go to case2 (where arrow points to instruction option)
	JE case2
	cmp al, 107 ; ASCII for k		; ;if press k then go to case1 (where arrow points to start game option)
	JE case1
	JMP mainMenu	; if anything other is pressed then go to mainMenu label again

	exit_menu:
	call clear_screen		; just call the clear_screen function	
	exit				; and exit the console

	instructions_menu:		; 
	call display_instructions
	call readChar
	JMP mainMenu

start_menu:
call clear_screen
RET
menu ENDP

display_instructions proc USES EDX	  ; procedure to simply print the game instruction, when instruction	
										; option is selected from main menu

call clear_screen			; first clear the whole screen using clear_screen fucntion
call draw_boundary			; draw the standard game boundary

mov dl, 32			
mov dh, 10
call gotoxy			; move cursor to (32, 10)

mov edx, OFFSET ins1	; print first instruction message
call writestring

mov dl, 32
mov dh, 11	
call gotoxy			; move cursor to (32, 11)

mov edx, OFFSET ins2   ; print second instruction message
call writestring

mov dl, 32
mov dh, 12		; move cursor to (32, 12) 
call gotoxy

mov edx, OFFSET ins4	; print 4th instruction message
call writestring

RET
display_instructions endp


gameover_display proc USES EDX
call clear_screen
call draw_boundary
					; the following procedure move the cursor first to (30,10) using gotoxy, then print first line
					; of ascii model defined above in code segement. then increment the y coordinate and print next 
					; message of model, and do same 3 more times to print whole model on screen.
mov dl, 30
mov dh, 10
call gotoxy
mov edx, OFFSET gameover_1
call writestring

mov dl, 30
mov dh, 11
call gotoxy
mov edx, OFFSET gameover_2
call writestring

mov dl, 30
mov dh, 12
call gotoxy
mov edx, OFFSET gameover_3
call writestring

mov dl, 30
mov dh, 13
call gotoxy
mov edx, OFFSET gameover_4
call writestring

mov dl, 30
mov dh, 15
call gotoxy
mov edx, OFFSET gameover_5
call writestring

RET
gameover_display endp


check_boundary_collision proc USES ESI EAX EBX

mov esi, 0					
mov al, x_coords[esi]
mov ah, y_coords[esi]		; mov head of snake coordinate to the al and ah

						; following 4 lines check whether a wrap is needed or not:
mov bl, right_wall		; bl contains right wall coordinates
dec bl					; decrementing the bl.
cmp al, bl			; cmp bl with x coordinates of snake.
je wrap_right		; if same then that means to wrap around the right wall.

					; following wrap checker works similary as the above checker does.
mov bl, left_wall	
inc bl
cmp al, bl
je wrap_left

mov bl, up_wall
cmp ah, bl
je wrap_up

mov bl, down_wall
cmp ah, bl
je wrap_down

jmp end_check

wrap_right:	
mov bl, left_wall			; move left wall coordinate to bl
inc bl				; incrementing the bl, so that snake is not shown on the wall, instead feels like coming from inside of wall
mov x_coords[esi], bl  ; now x coords of snake are updated
jmp end_check			; move to the end	 

				; other wrap labels works in the similar way as wrap_right does.
wrap_left:
mov bl, right_wall
dec bl
mov x_coords[esi], bl
jmp end_check

wrap_up:
mov bl, down_wall
dec bl
mov y_coords[esi], bl
jmp end_check

wrap_down:
mov bl, up_wall
inc bl
mov y_coords[esi], bl
jmp end_check

end_check:

ret
check_boundary_collision endp

check_snake_collision proc USES ESI EAX ECX EDX
						; following function checks for snake collision:	
						; and if there is collision then mov 1 to the death variable
mov esi, 0					
movzx ecx, snake_length		; we need to loop since the length of snake

mov al, x_coords[esi]
mov ah, y_coords[esi]		; simply copy x and y coordinate of  snake's head to al and ah

l1:

inc esi
mov dl, x_coords[esi]		; move x and y coordinate of next segement of snake to dl and dh
mov dh, y_coords[esi]
cmp al, dl				;if the x coordinate of sanke's head matches with coordinate of any other segment then there is collision.
jne no_collision		; if not equal then jmp to no collision

cmp ah, dh			;if the y coordinate of sanke's head matches with coordinate of any other segment then there is collision.
jne no_collision	; if not equal then jmp to no collision

mov death, 1		; just mov 1 to death variale if there is collision

no_collision:

loop l1

ret
check_snake_collision endp

draw_boundary proc USES EAX ECX EDX

mov dl, left_wall			
mov dh, up_wall
call gotoxy			; first goto (upper left corner of boundary )
mov ecx, 100		; and mov 100 to ecx

			; l1 creates the upper boundary
l1:
mov al, wall		; move wall character to al
call WriteChar		then print it for 100 times
loop l1
	
mov dl, left_wall		; then set x-coordinate to left_wall 
mov dh, up_wall			; and y-coordinate to up_wall cordinate
mov ecx, 20				; then run a loop 20 times to print each row of screen.
				
				; following loop prints left and right boundary
l2:					
add dh, 1				; increment y coordinate 
call gotoxy				; then used gotoxy, which moves cursor to the next row
mov al, wall			
call WriteChar			; print wall character
add dl, 99				; add 99 to dl means to skip 99 spaces 
call gotoxy				; and goto the right boundary position
call WriteChar			; and print wall character there
mov dl, left_wall		; again set x-coordinate equal to left-boundary coordinat
loop l2					; and loop the same procedure

add dh, 1			; increment y coordinate 
mov dl, left_wall	; move left_wall coordinate to dl
call gotoxy			; goto the last row
mov ecx, 100		; last loop l3 will run 100 times and prints the lower boundary

l3:
mov al, wall		; simply keep on moving wall character to al 
call WriteChar		; and print it
loop l3

ret
draw_boundary endp


draw_snake proc USES EAX EDX ESI	
									; this procedure simply prints the nth byte of snake array where n = ESI, at the positon
									; stored in x_coords[esi] and y_corrds[esi]
mov eax, green + (black * 16)		; change color to green 
call SetTextColor						
mov dl, x_coords[esi]				; 
mov dh, y_coords[esi]
call gotoxy
mov al, snake[esi]
call WriteChar
mov eax, black + (black * 16)
call SetTextColor
ret
draw_snake endp

update_snake proc USES ESI ECX EAX EDX
;;
mov esi, 1
movzx ecx, snake_length

l1:
mov dl, x_coords[esi]
mov dh, y_coords[esi]
mov x_coords[esi], al
mov y_coords[esi], ah
call draw_snake	
mov al, dl
mov ah, dh
call gotoxy
mov temp, al
mov al, ' '
call WriteChar
mov al, temp
inc esi
loop l1

ret
update_snake endp

clear_screen proc USES EDX ECX
		; this procedure simply clears the whole screen.
		; NOTE: we could use cls, but that clear only some portion of screen, that why we defined our own procedure

mov dl, 0
mov dh, 0
call gotoxy
mov ecx, 24		; we are using maximum 24 horizontal rows of screen 
l1:				; using an array of bytes conataning only " " after printing it 24 times it wipes whole the screen
mov edx, offset empty_array		; move offsest of that array
call WriteString			; print the whole array of bytes
call crlf			; print new line
loop l1		; loop for 24 times

ret
clear_screen endp

score_display proc USES EDX EAX

mov dl, left_wall
mov dh, 0
call gotoxy			; move cursor to (left_wall cordinate , 0)
mov edx, offset score_prompt	; print the score message
call WriteString	

mov dl, left_wall	
add dl, 8		; add 8 (sizez of ("score :")) to dl, to increment x-coordinate by 8
mov dh, 0	
call gotoxy			; move cursor to (left_wall cordinate + 8, 0)
movzx eax, score	; printing the value of score
call WriteDec
ret
score_display endp

check_food proc USES EAX EDX ESI

				;This function simply compares food cordinates and snake coordinates
mov esi, 0
mov  al, y_coords[esi]			; mov y coordinate of snake to al
	cmp food_Y_coord, al		; check if y coordinate of food is same as of snake
	jne last

mov  al, x_coords[esi]			; mov X coordinate of snake to al
	cmp food_X_coord, al		; check if x coordinate of food is same as of snake
	jne last
	
							;if coordinates matches
	inc score				;then increment the score
	sub speed , 2			; and speed

	mov dl, left_wall		; dl = left coorinate of wall
    add dl, 8				; add 8 (sizez of ("score :")) to dl, to increment x-coordinate by 8
    mov dh, 0
    call gotoxy			; ; move cursor to (left_wall cordinate + 8, 0)

	mov eax, white + (black * 16)	
    call SetTextColor		; change color 
    mov al, score		
    call WriteDec			; simply print score there
	mov eax, black + (black * 16)	
    call SetTextColor		 ; again set color to black

	call generate_food ; if food has been eaten then generate food agaian

last:	
ret
check_food endp


			; The following function generates 'X' randomaly within the boundary walls
generate_food proc USES EAX EDX

call Randomize			;generates the random seed
mov eax, 15				 	
call RandomRange		;we need food in between y coordinate from 4 to 19
add eax, 4				;8+1 so that the food is not generated on left-boundry
mov  dh, al				;Y-coordinate

mov eax, 90				;we need food in between x coordinate from 9 to 107	
call RandomRange 
add eax, 14				;2+1 so that the food is not generated on upper-boundry
mov  dl, al				;X-coordinate

mov food_X_coord, dl		; store the coordinates of food.
mov food_Y_coord, dh

mov eax, red + (black * 16)		
call SetTextColor			; set color to red

call Gotoxy			; go to that position
mov al, 'X'			
call writeChar		; print X

mov eax, black + (black * 16)
call SetTextColor	again change color to black

ret
generate_food endp

end main