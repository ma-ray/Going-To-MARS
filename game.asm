#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Raymond Ma, 1006210048, maraymon
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8 (update this as needed)
# - Unit height in pixels: 8 (update this as needed)
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestones 1/2/3/4
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. Scoring system (counts how many times you shoot an asteroid)
# 2. Shooting obstacles
# 3. Smooth graphics
#
# Link to video demonstration for final submission:
# - https://www.youtube.com/watch?v=TLwuP3Izxz4
#
# Are you OK with us sharing the video with people outside course staff?
# - yes, and please share this project github link as well!
#   https://github.com/ma-ray/Going-To-MARS
#
# Any additional information that the TA needs to know: 
# - When you are at the game over screen, you can press Q to end the program or P to restart
#
#####################################################################
	
.eqv BASE_ADDRESS	0x10008000				# address for framebuffer

## COLOURS for the ship and the obstacles
.eqv BLACK		0x000000
.eqv GREY		0x6f6f6f
.eqv LIGHT_GREY		0xa7a7a7
.eqv ORANGE		0xfd9825
.eqv BLUE		0x006dff
.eqv YELLOW		0xe3e70f
.eqv RED		0xff0000
.eqv WHITE		0xffffff
.eqv DARK_YELLOW	0x5a4d00
.eqv YELLOW2		0xffdc00

.eqv SMALL_OBS_SIZE	6	# size of the small_obs_list
.eqv SHOOTING_SPEED	2	# speed of the bullets

.data
SMALL_OBS_LIST:		.word 30,14,-6,0,-7,0,-7,0,-7,0,-7,0	# array of (x,y), (x,y), (x,y)
SHIP_LOC:		.word 4, 14				# an array that stores the ship's coordinates. SHIP_LOC[0] = x, SHIP_LOC[1] y
								# Initially starts at (4,14)
SHIP_HEALTH:		.word 12				# health of the ship. 12 hits then game_over
SHIP_HEALTH_STATUS:	.word 3716, 3844, 3848, 3720, 3728, 3856, 3860, 3732, 3740, 3868, 3872, 3744
			# array coordinates (in offset form) to pixels that represent the ship's health
SHOOTING_LIST:		.word -1,10				# array of (x,y), (x,y), (x,y) coordinates of the bullets -1 indicates it has not spawned
SHOOTING_STATUS:	.word 3808, 3816, 3824, 3832		# pixels to the shooting status
SHOOTING_AVAIL:		.word 4
SHOOTING_TIMER:		.word 0					# per second incremanet the shooting availabel

SCORE:			.word 0					# keeps the score of the user

.text
.globl main

update_obs:
	li $t1, 0		# $t1 = iterator = 0
	
update_obs_loop:
	bge $t1, SMALL_OBS_SIZE, update_obs_end
	la $t0, SMALL_OBS_LIST	# load the address to obs_list
	sll $t4, $t1, 3		# offset for ith element in array
	add $t0, $t0, $t4	# $t0 = array[i]
	
	lw $t2, 0($t0)		# $t2 = current x
	lw $t3, 4($t0)		# $t3 = current y
	
	## CALLING draw_obs(x,y,0)
	# SAVING VARIABLES: $t0, $t1
	addi $sp, $sp, -4	# save $t0 to the stack
	sw $t0, 0($sp)
	addi $sp, $sp, -4	# save $t1 to the stack
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $ra on the stack
	sw $ra, 0($sp)
	# PUSH ARGUMENTS TO THE STACK
	addi $sp, $sp, -4
	sw $t2, 0($sp)		# push the x to the stack
	addi $sp, $sp, -4
	sw $t3, 0($sp)		# push y to the stack
	addi $sp, $sp, -4
	li $t7, 0		# set $t7 = 0 and then push to stack
	sw $t7, 0($sp)
	
	jal draw_obs		# call draw_obs(x,y,0)
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1	
	addi $sp, $sp, 4
	lw $t0, 0($sp)		# restore $t0
	addi $sp, $sp, 4
	lw $t2, 0($t0)		# restore $t2 = current x
	lw $t3, 4($t0)		# restore $t3 = current y
	
	bgt $t2, -3, add_obs	# if the obs is not off the screen skip generating new location
	#### GENERATE NEW COORDINATES
	## GENERATE NEW X BETWEEN 32 AND 48 INCLUSIVE (SHIFTED FOR SYSCALL 0 <= X < 17)
	li $v0, 42
	li $a0, 0
	li $a1, 17
	syscall
	move $t2, $a0		# move random value to $t2
	addi $t2, $t2, 32	# add 16 to it to acheive 32 AND 48 INCLUSIVE
	sw $t2, 0($t0)		# store in array
	
	## GENERATE NEW Y BETWEEN 1 AND 24 INCLUSIVE
	li $v0, 42
	li $a0, 0
	li $a1, 24
	syscall
	move $t3, $a0		# move random value to $t3
	addi $t3,$t3, 1		# add 1 to it to achieve 1 AND 25 INCLUSIVE
	sw $t3, 4($t0)		# store in array
	####
	
add_obs:
	addi $t2, $t2, -1	# set current x = x - 1
	sw $t2, 0($t0)		# store in array[i]
	
	# call draw_obs(x,y,s)
	addi $sp, $sp, -4	# save $t1 to the stack
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $ra on the stack
	sw $ra, 0($sp)
	# PUSH ARGUMENTS TO THE STACK
	addi $sp, $sp, -4
	sw $t2, 0($sp)		# push x to the stack
	addi $sp, $sp, -4
	sw $t3, 0($sp)		# push y to the stack
	addi $sp, $sp, -4
	li $t7, 1		# set $t7 = 1 and then push to stack
	sw $t7, 0($sp)
	
	jal draw_obs		# call draw_obs(x,y,1)
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1	
	addi $sp, $sp, 4
	
	addi $t1, $t1, 1	# update the iterator
	
	j update_obs_loop	# jump back to loop condition
	
update_obs_end:
	jr $ra			# return to caller
	
# Pass in x,y,s. if s is 1, draw the obstacle. Otherwise, clear the obstacle
# Uses stack calling convention
draw_obs:
	lw $t0, 0($sp)		# $t0, = s
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# $t1, = y
	addi $sp, $sp, 4
	lw $t2, 0($sp)		# $t2, = x
	addi $sp, $sp, 4
	
	bgt $t2, 31, draw_obs_end	# if x is not visible end function
	
	la $t4, BASE_ADDRESS		# $t4 = BASE_ADDRESS
	
	# CALCULATE THE PIXEL LOCATION OF SHIP
	sll $t5, $t2, 2		# $t5 = 4x
	sll $t6, $t1, 7		# $t6 = 128y
	add $t5, $t5, $t6	# $t5 = offset of frame buffer verison of location
	add $t4, $t4, $t5	# $t4 = frame buffer verison of location
	
	# LOAD COLOURS to draw obstalce color1: $t5, color2: $t6
	beq $t0, 0, wipe_obs
	li $t5, GREY
	li $t6, LIGHT_GREY
	j paint_obs
	
wipe_obs:
	# LOAD black to clear the obstacle from the screen
	li $t5, BLACK
	li $t6, BLACK
	
	# check the if the first pixel column of the obstacle is in bounds. Draw if it is.
paint_obs:
	ble $t2, -1, paint_col_two	# if the column is left of the screen (x < -1) move on to second column
	bge $t2, 32, paint_col_two	# if the column is right of the screen (x > 32) move on to second column
	
	sw $t5, 0($t4)			# draw the first column pixel
	# check the if the second pixel column of the obstacle is in bounds. Draw if it is.
paint_col_two:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1		# shift the x coordinate to the second column (x = x + 1)
	ble $t2, -1, paint_col_three	# if the column is left of the screen (x < -1) move on to third column
	bge $t2, 32, paint_col_three	# if the column is right of the screen (x > 32) move on to thrid column
	
	sw $t5, -128($t4)		# draw the pixels for the second column
	sw $t6, 0($t4)
	sw $t5, 128($t4)
	# check the if the third pixel column of the obstacle is in bounds. Draw if it is.
paint_col_three:
	addi $t4, $t4, 4		# shift to next column
	addi $t2, $t2, 1		# shift the x coordinate to the second column (x = x + 1)
	ble $t2, -1, draw_obs_end	# if the column is left of the screen (x < -1) end the function
	bge $t2, 32, draw_obs_end	# if the column is right of the screen (x > 32) end the function
	sw $t5, 0($t4)			# draw the pixel for the third column

draw_obs_end:
	jr $ra			# return to caller

## Pass in a number (0,1,2) to $a0. if 1, draw the ship. Otherwise, clear the ship
## Use the register based calling convention
draw_ship:
	la $t0, BASE_ADDRESS	# $t0 = address of framebuffer
	la $t1, SHIP_LOC	# $t1 = address of the ship
	lw $t2, 0($t1)		# $t2 = x coord of ship
	lw $t3, 4($t1)		# $t3 = y coord of ship
	
	# CALCULATE THE PIXEL LOCATION OF SHIP
	sll $t2, $t2, 2		# $t2 = 4x
	sll $t3, $t3, 7		# $t3 = 128y
	add $t1, $t2, $t3	# $t1 = offset of frame buffer verison of location
	add $t1, $t1, $t0	# $t1 = frame buffer verison of location
	
	# LOAD COLOURS NEEDED FOR SHIP
	beq $a0, 0, clear_ship	# if value passed in is 0, clear the ship
	beq $a0, 2, hit_ship	# if value passed in is 2, render hit ship
	# case where you need to render the ship
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, BLUE
	j render_ship
	
	# make the ship red to indicate a hit
hit_ship:
	li $t4, YELLOW
	li $t5, ORANGE
	li $t6, RED
	j render_ship
	
	# remove the ship off the screen by setting all colours to black
clear_ship:
	li $t4, BLACK
	li $t5, BLACK
	li $t6, BLACK
	
render_ship:	
	# DRAWING THE SHIP
	sw $t6, 0($t1)		# draw main pixel to screen
	sw $t4, -4($t1)
	sw $t6, -8($t1)
	sw $t6, -12($t1)
	sw $t5, -16($t1)
	sw $t6, -132($t1)
	sw $t6, 124($t1)
	sw $t6, -136($t1)
	sw $t6, -140($t1)
	sw $t5, -144($t1)
	sw $t6, 120($t1)
	sw $t6, 116($t1)
	sw $t5, 112($t1)
	sw $t6, -268($t1)
	sw $t6, 244($t1)
	
	jr $ra			# return to the caller
	
update_ship:
	# GET THE KEYBOARD INPUT
	li $t3, 0xffff0000		# load addrress of keypress
	lw $t4, ($t3)			# load if key was pressed
	bne $t4, 1, update_ship_end	# if key not pressed jump to SLEEP
	lw $t3, 4($t3)			# otherwise load the button that was pressed
	
	# LOAD SHIP COORDS
	la $t0, SHIP_LOC		# $t0 = address of ship
	lw $t1, 0($t0)			# $t1 = x coord of ship
	lw $t2, 4($t0)			# $t2 = y coord of ship
	
	# DETERMINE WHICH DIRECTION IT IS GOING
	beq $t3, 119, GO_UP		# if W was pressed
	beq $t3, 97, GO_LEFT		# if A was pressed
	beq $t3, 115, GO_DOWN		# if D was pressed
	beq $t3, 100, GO_RIGHT		# if S was pressed
	beq $t3, 32, SPAWN_BULLET	# is SPACE was pressed
	beq $t3, 112, RESTART		# if P was pressed
	jr $ra				# otherwise return to caller
	
SPAWN_BULLET:
	# load if we have enough bullets available
	la $t7, SHOOTING_AVAIL		# load how many bullets the player has
	lw $t6, 0($t7)			
	blt $t6, 1, update_shooting_end	# if bullets available is 0, do nothing
	addi $t6, $t6, -1		# decrease the bullets available by 1
	sw $t6, 0($t7)	 		# store it back

	# no need to update ship
	la $t3, SHOOTING_LIST			
	# load the contents at index i
	lw $t4, 0($t3)				# $t4 = bulltet's x
	lw $t6, 4($t3) 				# $t6 = bullet's y
	bgt $t4, -1, update_shooting_end	# if bullet active end
	#addi $t1, $t1, SHOOTING_SPEED		# x location of bullet
	sw $t1, 0($t3)				# store new location of bullet
	sw $t2, 4($t3)
	j update_shooting_end
	
	# MOVE THE SHIP
GO_UP:	addi $t2, $t2, -2		# y = y - 2
	j update_ship_array
	
GO_LEFT:
	addi $t1, $t1, -2		# x = x - 2
	j update_ship_array
	
GO_DOWN:	
	addi $t2, $t2, 2		# y = y + 2
	j update_ship_array
	
GO_RIGHT:
	addi $t1, $t1, 2		# x = x + 2
	
update_ship_array:
	# CHECK IF THE CHANGES ARE OUT OF BOUNDS
	#  if x < 4 or x > 31 return to caller
	blt $t1, 4, update_ship_end
	bgt $t1, 31, update_ship_end
	
	# if y < 2 or y > 24 return to caller (white line boundary)
	blt $t2, 2, update_ship_end
	bgt $t2, 24, update_ship_end
	
	# load coordinates back to array
	sw $t1, 0($t0)
	sw $t2, 4($t0)

update_ship_end:
	jr $ra			# return to caller
	
collision_check:
	la $t2, SMALL_OBS_LIST	# $t2 = address of obstacle list
	li $t3, 0		# $t3 = iterator = 0
	
collision_check_loop:
	bge $t3, SMALL_OBS_SIZE, collision_check_end	# while i <= 3
	sll $t4, $t3, 3		# the offset size
	add $t7, $t4, $t2	# $t7 = address of obs_array[i]
	lw $t5, 4($t7)		# $t5 = obstacle's y coords
	lw $t4, 0($t7)		# $t4 = obstacles's x coords
	
	# DO NOT CHECK IF OBSTACLES ARE ON THE EDGES
	blt $t4, 1, collision_check_update	# if obs x coords < 1, move on to next obstacle
	bgt $t4, 30, collision_check_update	# if obs x coords > 30, move on to next obstacle
	
	## CHECK IF OBSTASCLE IS INBOUNDS OF SHIP
	sll $t0, $t4, 2		# $t2 = 4x
	sll $t1, $t5, 7		# $t3 = 128y
	add $t0, $t0, $t1	# offset for pixel from frame buffer
	la $t1, BASE_ADDRESS	# $t1 = BASE_ADDRESS
	add $t0, $t1, $t0	# address of the pixel
	
	# Check the left of the obstacle
	lw $t4, -4($t0)				# load the colour of the adjacent pixel
	addi $t5, $t0, -4			# pixel for bullet if we are going to erase
	beq $t4, WHITE, collision_bullet	# if adjacent pixel is white, the obstacle has hit a bullet
	beq $t4, BLUE, collision_ship		# if the adjacent if pixel is blue, thats means we hit a ship
	
	# Check the top of the obstacle
	lw $t4, -128($t0)			
	addi $t5, $t0, -128			
	beq $t4, WHITE, collision_bullet	
	
	# Check the bottom of the obstacle
	lw $t4, 128($t0)			
	addi $t5, $t0, 128			
	beq $t4, WHITE, collision_bullet	
	
	### Check if the bullet was in proximity of the obstacle
	lw $t4, -252($t0)			
	addi $t5, $t0, -252			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 260($t0)			
	addi $t5, $t0, 260			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, -132($t0)			
	addi $t5, $t0, -132			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 124($t0)			
	addi $t5, $t0, 124			
	beq $t4, WHITE, collision_bullet
	
	### Check if the bullet has drawn over the obstacles
	lw $t4, 0($t0)				
	addi $t5, $t0, 0			
	beq $t4, WHITE, collision_bullet	
	
	# Check the 
	lw $t4, 4($t0)				
	addi $t5, $t0, 4			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 8($t0)				
	addi $t5, $t0, 8			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, -124($t0)			
	addi $t5, $t0, -124			
	beq $t4, WHITE, collision_bullet	
	
	lw $t4, 132($t0)			
	addi $t5, $t0, 132			
	beq $t4, WHITE, collision_bullet
	######################################################		
	
	j collision_check_update
collision_ship:
	# save $t0, $t1, $t2, $t3 to the stack
	addi $sp, $sp, -4	# save $t0
	sw $t0, 0($sp)
	addi $sp, $sp, -4	# save $t1
	sw $t1, 0($sp)
	addi $sp, $sp, -4	# save $t2
	sw $t2, 0($sp)
	addi $sp, $sp, -4	# save $t3
	sw $t3, 0($sp)
	addi $sp, $sp, -4	# save $ra
	sw $ra, 0($sp)
	
	li $a0, 2		# call draw_ship(2)
	jal draw_ship
	jal update_health	# call update_health to decrease health
	
	lw $ra, 0($sp)		# restore $ra
	addi $sp, $sp, 4
	lw $t3, 0($sp)		# restore $t3
	addi $sp, $sp, 4
	lw $t2, 0($sp)		# restore $t2
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# restore $t1
	addi $sp, $sp, 4
	lw $t0, 0($sp)		# restore $t0
	addi $sp, $sp, 4
	
	# invoke sleep for 0.25 seconds
	li $v0, 32
	li $a0, 50
	syscall
	j collision_check_update	

collision_bullet:
	# Increment the score by 1
	la $t4, SCORE				# load the address of score
	lw $t6, 0($t4)	
	addi $t6, $t6, 1			#  add 1 to the score
	sw $t6, 0($t4)				# store it back into SCORE

	# make the obstacle orange to indicate a hit
	li $t6, ORANGE
	sw $t6, 0($t0)				# draw the first column pixel
	sw $t6, 4($t0)				# draw the pixels for the second column
	sw $t6, 8($t0)
	sw $t6, -124($t0)
	sw $t6, 132($t0)
	
	# invoke sleep for 0.25 seconds
	li $v0, 32
	li $a0, 25
	syscall

	# erase the obstacle and reset
	sw $zero, 0($t0)			# draw the first column pixel
	sw $zero, 4($t0)			# draw the pixels for the second column
	sw $zero, 8($t0)
	sw $zero, -124($t0)
	sw $zero, 132($t0)
	li $t6, -5				# load a value that is off the screen
	sw $t6, 0($t7)				# reset the obstacle
	sw $zero, 4($t7)
	# erase bullet and reset
	sw $zero, 0($t5)			# undraw the bullet
	la $t7, SHOOTING_LIST			# $t7 = address of shooting list
	li $t6, -1				# load the inactive state
	sw $t6, 0($t7)				# store it in shooting list
	
collision_check_update:
	addi $t3, $t3, 1			# i = i + 1
	j collision_check_loop			# jump back to while conditoin
	
collision_check_end:
	addi $sp, $sp, -4			# save $ra
	sw $ra, 0($sp)

	# call draw_ship(1)
	li $a0, 1				# call draw_ship(1)
	jal draw_ship
	
	lw $ra, 0($sp)				# restore $ra
	addi $sp, $sp, 4

	jr $ra					# return to caller
	
update_health:
	############################
	la $t0, SHIP_HEALTH		# $t0 = address of ship health
	lw $t1, 0($t0)			# $t1 = ship health
	addi $t1, $t1, -1		# decrease ship health
	
	la $t2, SHIP_HEALTH_STATUS	# $t2 = address of SHIP_HEALTH_STATUS
	sll $t3, $t1, 2			# offset for accessing array[ship_health}
	add $t2, $t2, $t3		# address for array[ship_health]
	lw $t2, 0($t2)			# $t2 = array[ship_heath]
	la $t3, BASE_ADDRESS		# $t3 = BASE_ADDRESS
	add $t2, $t2, $t3		# address for the pixel to erase
	li $t7, GREY			# load the colour GREY
	sw $t7, 0($t2)			# paint the pixel GREY
	
	sw $t1, 0($t0)			# store the new ship health		
	
	jr $ra				# return to caller
	
update_shooting:
	la $t0, SHOOTING_LIST		# $t0 = array of the coordinates of the bullet
	li $t1, 0			# intialize iterator
			
	# load the contents at index i
	lw $t4, 0($t0)			# $t4 = x
	lw $t5, 4($t0) 			# $t4 = y
	blt $t4, 0, update_shooting_end		# if bullet is not active (not fired)
	# CALCULATE THE PIXEL LOCATION OF BULLET
	sll $t6, $t4, 2		# $t6 = 4x
	sll $t7, $t5, 7		# $t7 = 128y
	add $t6, $t7, $t6	# $t6 = offset of frame buffer verison of location
	add $t6, $t6, $gp	# $t6 = frame buffer verison of location
	
	sw $zero, 0($t6)	# undraw the pixel
	
	addi $t4, $t4, SHOOTING_SPEED	# x = x + 3
	
	bgt $t4, 31, bullet_inactive	# x is out of bounds make it inactive
	li $t7, WHITE
	li $t5, SHOOTING_SPEED
	sll $t5, $t5, 2			# shooting speed * 4
	add $t6, $t5, $t6		# update pixel address
	sw $t7, 0($t6)			# draw the new pixel 3 to the right from original location
	sw $t4, 0($t0)			# store new x in array
	
update_shooting_end:
	jr $ra				# return to caller
	
bullet_inactive:
	li $t4, -1			# let x be -1 to indicate it is inactive
	sw $t4, 0($t0)			# store new x in array
	j update_shooting_end
	
draw_gui:
	# draw the white line at the bottom
	li $t1, WHITE			# $t1 = colour white
	la $t0, BASE_ADDRESS		# load the base address
	li $t2, 3456			# $t2 = iterator
	
draw_gui_loop:
	bgt $t2, 3580, setup_health	# if pixel is greater tha 3580 exit loop
	add $t7, $t0, $t2		# calculate address for pixel	
	sw $t1, 0($t7)			# store white on that pixel
	addi $t2, $t2, 4		# move to the right pixel
	j draw_gui_loop			# jump to loop condition
	
setup_health:
	li $t3, RED
	la $t4, BASE_ADDRESS		# $t4 = BASE_ADDRESS			
	la $t0, SHIP_HEALTH_STATUS	# $t0 = address of SHIP_HEALTH_STATUS
	li $t1, 0			# $t1 = iterator = 0
	
setup_health_loop:
	bge $t1, 12, draw_gui_end	# i > 12 
	sll $t5, $t1, 2			# $t5 = offset for i
	add $t5, $t5, $t0		# $t5 = address for array[i]
	lw $t5, 0($t5)			# $t5 = offset for pixel location
	add $t5, $t5, $t4		# $t5 = pixel location
	sw $t3, 0($t5)			# draw the pixel red
	addi $t1, $t1, 1		# update the iterator i = i + 1
	j setup_health_loop
	
draw_gui_end:
	jr $ra				# return to caller
	
draw_shoot_status:
	# check if enough time has passed to increment the bullets available
	la $t0, SHOOTING_AVAIL
	lw $t1, 0($t0)			# load how many bullets the player can use
	la $t2, SHOOTING_TIMER	
	lw $t3, 0($t2)			# load the time so far
	bge $t3, 2000, add_bullet	# if it has been 2 seconds, increment availble bullets
	j draw_bars			# other wise draw the bullet status
	
add_bullet:
	addi $t1, $t1, 1		# increment the bullet
	sw $zero,  0($t2)		# reset the timer
	bgt $t1, 4, set_max_bullet	# cap the available bullets to 4
	j draw_bars
set_max_bullet:
	li $t1, 4			# set the max bullets to 4

draw_bars:
	sw $t1, 0($t0)			# store the updated available bullets
	la $t0, SHOOTING_STATUS		# load address of SHOOTING_STATUS
	li $t2, 0			# setup iterator

	# set it all to dark yellow
inactive_shoot_loop:
	bge $t2, 4, active_shoot
	sll $t3, $t2, 2			# calculate offset for array
	add $t4, $t3, $t0		# get address of SHOOT_STATUS[i]
	lw $t5, 0($t4)			# load SHOOT_STATUS[i]
	la $t6, BASE_ADDRESS	
	add $t6, $t6, $t5		# calculate address to the pixel
	li $t7, DARK_YELLOW		# load the colour DARK_YELLOw
	sw $t7, 0($t6)			# draw the pixels
	sw $t7, 128($t6)
	addi $t2, $t2, 1		# update iterator
	j inactive_shoot_loop		# jump back to first loop
active_shoot:
	li $t2, 0			# reset the iterator
active_shoot_loop:
	bge $t2, $t1, draw_shoot_status_end
	sll $t3, $t2, 2			# calculate offset for array
	add $t4, $t3, $t0		# get address of SHOOT_STATUS[i]
	lw $t5, 0($t4)			# load SHOOT_STATUS[i]
	la $t6, BASE_ADDRESS	
	add $t6, $t6, $t5		# calculate address to the pixel
	li $t7, YELLOW2			# load the colour DARK_YELLOw
	sw $t7, 0($t6)			# draw the pixels
	sw $t7, 128($t6)
	addi $t2, $t2, 1		# update iterator
	j active_shoot_loop		# jump back to first loop
	
draw_shoot_status_end:
	jr $ra				# return to caller
	
# reset all values
RESTART:
	## reset ship health
	la $t0, SHIP_HEALTH	# $t0 = health of the ship
	li $t1, 12		# load intital health of the ship
	sw $t1, 0($t0)		# store to variable

	## reset ship location
	la $t0, SHIP_LOC	# $t0, location of the ship_array
	li $t1, 4		# ship's spawn point x = 4
	li $t2, 14		# ship's spawn point y = 14
	sw $t1, 0($t0)		# store the ship's new location
	sw $t2, 4($t0)
	
	## reset bullet_location
	la $t0, SHOOTING_LIST	# $t0 = location of shooting list
	li $t1, -1
	sw $t1, 0($t0)		# store -1 in list to show inactive state
	
	# reset the shoot timer
	la $t0, SHOOTING_TIMER
	li $t1, 0
	sw $t1, 0($t0)		# reset the timer to 0
	
	# reset the bullets available
	la $t0, SHOOTING_AVAIL
	li $t1, 4
	sw $t1, 0($t0)		# reset the bullets available to 4
	
	# reset the score
	la $t0, SCORE
	li $t1, 0
	sw $t1, 0($t0)		# load 0 to SCORE
	
	## reset obstacle location
	la $t0, SMALL_OBS_LIST	# $t0 = location of small obstacle array
	li $t1, 0		# $t1 = iterator = 0
	
restart_obs_loop:
	bge $t1, SMALL_OBS_SIZE, restart_end
	sll $t2, $t1, 3		# $t2 = offset for the iterator
	add $t3, $t2, $t0	# $t3 = address of small obs array[i]
	li $t4, -5		# $t3 = location of new obstacle (off the screen)
	sw $t4, 0($t3)		# array[i] = -5
	addi $t1, $t1, 1	# update the iterator i++
	j restart_obs_loop	# jump back to while condition
	
restart_end:
	j begin			# jump to the beginning of the main game loop
	
# clear the whole screen to black
clear_screen:
	la $t0, BASE_ADDRESS
	li $t1, BLACK
	li $t2, 0		# the iterator
	
clear_screen_loop:
	bge $t2, 1024, clear_screen_end
	sw $t1, 0($t0)		# set the pixel to black
	addi $t0, $t0, 4	# update pixel location
	addi $t2, $t2, 1	# update iterator: i = i + 1
	j clear_screen_loop		

clear_screen_end:
	jr $ra			# return to caller
	
main:
	jal clear_screen	
	jal start_screen	# draws the start screen
	
	# sleep for 2 seconds the refresh rate
	li $v0, 32
	li $a0, 2000
	syscall
begin:	jal clear_screen	# draw the screen
	jal draw_gui		# draw the gui
	
	la $t0, SHIP_HEALTH	# $t0 = address of SHIP_HEALTH
	lw $t0, 0($t0)		# $t1 = ship health
GAME_LOOP:
	blt $t0, 1, game_over_state		# if lives are 0 then jump to game_over_state
	
	jal update_obs		# update the location of obstacles
	jal update_shooting	# move the bullets and check for collisions
	jal draw_shoot_status	# update the status on how many bullets the player can shoot	
	jal collision_check	# iterate thorugh each obstacle, and checks if it hits the ship
	
	li $a0, 0		# call draw_ship(0)
	jal draw_ship		# clear the ship on the screen
	
	jal update_ship		# check user input and update location
	
	li $a0, 1		# call draw_ship(1)
	jal draw_ship		# draw the ship	on the screen

SLEEP:	# sleep for 40ms for the refresh rate
	li $v0, 32
	li $a0, 40
	syscall
	
	
	la $t0, SHOOTING_TIMER	# load address to the shooting timer
	lw $t1, 0($t0)		# load the contents
	addi $t1, $t1, 40	# add 40 ms to the shooting timer
	sw $t1, 0($t0)		# store it back into .data
	
	la $t0, SHIP_HEALTH	# $t0 = address of SHIP_HEALTH
	lw $t0, 0($t0)		# $t1 = ship health
	
	j GAME_LOOP		# jump back to beginning of game loop
	
game_over_state:
	jal clear_screen	# clear the screen
	jal game_over		# draw the game over screen
	jal print_score		# print the scores to the screen
	
game_over_loop:
	beq $t3, 113, END	# if Q was pressed restart the game
	
	# GET THE KEYBOARD INPUT 	(P to restart and Q to quit)
	li $t3, 0xffff0000		# load address of keypress
	lw $t4, ($t3)			# load if key was pressed
	bne $t4, 1, game_over_loop	# if key not pressed jump to SLEEP
	lw $t3, 4($t3)			# otherwise load the button that was pressed
	beq $t3, 112, RESTART		# if P was pressed restart the game
	j game_over_loop		# check again for keyboard input
	
END:
	li $v0, 10			# terminate the program gracfully
	syscall	
	
## IMAGE FUNCTIONS
# Will print the double digit score
print_score:
	la $t0, SCORE		# load address of SCORE
	lw $t0, 0($t0)		# $t0 = SCORE
	
	li $t7, 10		# $t7 = 10 for division
	
	div $t0, $t7		# SCORE / 10
	
	# 10s digit
	mflo $t6		# $t6 = SCORE // 10
	# 1s digit
	mfhi $t7		# $7 = SCORE % 10
	
	addi $sp $sp, -4	# save $ra
	sw $ra, 0($sp)
	
	move $a0, $t7		# push parameters using register calling convention
	li $a1, 2496
	
	jal draw_digit		# draw the 1s digit first
		
	move $a0, $t6		# push parameters using register calling convention
	li $a1, 2468
	
	jal draw_digit		# draw the 10s digit
	
	lw $ra, 0($sp)		# restore $ra
	add $sp, $sp, 4
	
	jr $ra
	
# passes in a digit and the addres on where to print $a0 = digit $a1 = pixel offset
draw_digit:
	move $t0, $a0			# load the digit
	move $t1, $a1			# load the offset
	li $t2, WHITE			# load the colour white
	la $t3, BASE_ADDRESS
	add $t1, $t3, $t1
	
	beq $t0, 1, draw_one
	beq $t0, 2, draw_two
	beq $t0, 3, draw_three
	beq $t0, 4, draw_four
	beq $t0, 5, draw_five
	beq $t0, 6, draw_six
	beq $t0, 7, draw_seven
	beq $t0, 8, draw_eight
	beq $t0, 9, draw_nine
	
draw_zero:				# Draws 0 on the screen
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 260($t1)
        sw $t2, 272($t1)
        sw $t2, 388($t1)
        sw $t2, 400($t1)
        sw $t2, 516($t1)
        sw $t2, 528($t1)
        sw $t2, 644($t1)
        sw $t2, 656($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
	jr $ra

draw_one:				# Draws 1 on the screen
	sw $t2, 140($t1)
        sw $t2, 264($t1)
        sw $t2, 268($t1)
        sw $t2, 396($t1)
        sw $t2, 524($t1)
        sw $t2, 652($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        sw $t2, 784($t1)
        jr $ra

draw_two:				# Draws 2 on the screen
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 260($t1)
        sw $t2, 272($t1)
        sw $t2, 396($t1)
        sw $t2, 520($t1)
        sw $t2, 644($t1)
        sw $t2, 772($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        sw $t2, 784($t1)
        jr $ra

draw_three:				# Draws 3 on the screen
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 260($t1)
        sw $t2, 272($t1)
        sw $t2, 396($t1)
        sw $t2, 528($t1)
        sw $t2, 644($t1)
        sw $t2, 656($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        jr $ra

draw_four:				# Draws 4 on the screen
        sw $t2, 140($t1)
        sw $t2, 264($t1)
        sw $t2, 268($t1)
        sw $t2, 388($t1)
        sw $t2, 396($t1)
        sw $t2, 516($t1)
        sw $t2, 520($t1)
        sw $t2, 524($t1)
        sw $t2, 528($t1)
        sw $t2, 652($t1)
        sw $t2, 780($t1)
        jr $ra

draw_five:				# Draws 5 on the screen
        sw $t2, 132($t1)
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 144($t1)
        sw $t2, 260($t1)
        sw $t2, 388($t1)
        sw $t2, 392($t1)
        sw $t2, 396($t1)
        sw $t2, 528($t1)
        sw $t2, 656($t1)
        sw $t2, 772($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        jr $ra

draw_six:				# Draws 6 on the screen
	sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 144($t1)
        sw $t2, 260($t1)
        sw $t2, 388($t1)
        sw $t2, 392($t1)
        sw $t2, 396($t1)
        sw $t2, 516($t1)
        sw $t2, 528($t1)
        sw $t2, 644($t1)
        sw $t2, 656($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        jr $ra

draw_seven:				# Draws 7 on the screen
        sw $t2, 132($t1)
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 144($t1)
        sw $t2, 272($t1)
        sw $t2, 396($t1)
        sw $t2, 520($t1)
        sw $t2, 648($t1)
        sw $t2, 776($t1)
        jr $ra

draw_eight:				# Draws 8 on the screen
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 260($t1)
        sw $t2, 272($t1)
        sw $t2, 392($t1)
        sw $t2, 396($t1)
        sw $t2, 516($t1)
        sw $t2, 528($t1)
        sw $t2, 644($t1)
        sw $t2, 656($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        jr $ra

draw_nine:				# Draws 9 on the screen
        sw $t2, 136($t1)
        sw $t2, 140($t1)
        sw $t2, 260($t1)
        sw $t2, 272($t1)
        sw $t2, 388($t1)
        sw $t2, 400($t1)
        sw $t2, 520($t1)
        sw $t2, 524($t1)
        sw $t2, 528($t1)
        sw $t2, 656($t1)
        sw $t2, 776($t1)
        sw $t2, 780($t1)
        jr $ra

start_screen:				# draws the start screen. Code generated by a Python script
        la $t0, BASE_ADDRESS		# $t0 is the base address
        li $t1, 0xffdc00		# loads the colours required to draw the image
        li $t2, 0xff0000
        li $t3, 0xe26a03
        sw $t1, 268($t0)
        sw $t1, 272($t0)
        sw $t1, 292($t0)
        sw $t1, 296($t0)
        sw $t1, 312($t0)
        sw $t1, 316($t0)
        sw $t1, 320($t0)
        sw $t1, 332($t0)
        sw $t1, 344($t0)
        sw $t1, 360($t0)
        sw $t1, 364($t0)
        sw $t1, 392($t0)
        sw $t1, 416($t0)
        sw $t1, 428($t0)
        sw $t1, 444($t0)
        sw $t1, 460($t0)
        sw $t1, 464($t0)
        sw $t1, 472($t0)
        sw $t1, 484($t0)
        sw $t1, 520($t0)
        sw $t1, 528($t0)
        sw $t1, 532($t0)
        sw $t1, 544($t0)
        sw $t1, 556($t0)
        sw $t1, 572($t0)
        sw $t1, 588($t0)
        sw $t1, 596($t0)
        sw $t1, 600($t0)
        sw $t1, 612($t0)
        sw $t1, 620($t0)
        sw $t1, 624($t0)
        sw $t1, 648($t0)
        sw $t1, 660($t0)
        sw $t1, 672($t0)
        sw $t1, 684($t0)
        sw $t1, 700($t0)
        sw $t1, 716($t0)
        sw $t1, 728($t0)
        sw $t1, 740($t0)
        sw $t1, 752($t0)
        sw $t1, 780($t0)
        sw $t1, 784($t0)
        sw $t1, 804($t0)
        sw $t1, 808($t0)
        sw $t1, 824($t0)
        sw $t1, 828($t0)
        sw $t1, 832($t0)
        sw $t1, 844($t0)
        sw $t1, 856($t0)
        sw $t1, 872($t0)
        sw $t1, 876($t0)
        sw $t2, 1160($t0)
        sw $t2, 1164($t0)
        sw $t2, 1168($t0)
        sw $t2, 1172($t0)
        sw $t2, 1176($t0)
        sw $t2, 1192($t0)
        sw $t2, 1196($t0)
        sw $t2, 1296($t0)
        sw $t2, 1316($t0)
        sw $t2, 1328($t0)
        sw $t2, 1424($t0)
        sw $t2, 1444($t0)
        sw $t2, 1456($t0)
        sw $t2, 1552($t0)
        sw $t2, 1572($t0)
        sw $t2, 1584($t0)
        sw $t2, 1680($t0)
        sw $t2, 1704($t0)
        sw $t2, 1708($t0)
        sw $t3, 2056($t0)
        sw $t3, 2080($t0)
        sw $t3, 2092($t0)
        sw $t3, 2096($t0)
        sw $t3, 2100($t0)
        sw $t3, 2112($t0)
        sw $t3, 2116($t0)
        sw $t3, 2120($t0)
        sw $t3, 2124($t0)
        sw $t3, 2140($t0)
        sw $t3, 2144($t0)
        sw $t3, 2148($t0)
        sw $t3, 2152($t0)
        sw $t3, 2184($t0)
        sw $t3, 2188($t0)
        sw $t3, 2204($t0)
        sw $t3, 2208($t0)
        sw $t3, 2216($t0)
        sw $t3, 2220($t0)
        sw $t3, 2228($t0)
        sw $t3, 2232($t0)
        sw $t3, 2240($t0)
        sw $t3, 2244($t0)
        sw $t3, 2256($t0)
        sw $t3, 2264($t0)
        sw $t3, 2268($t0)
        sw $t3, 2312($t0)
        sw $t3, 2316($t0)
        sw $t3, 2320($t0)
        sw $t3, 2328($t0)
        sw $t3, 2332($t0)
        sw $t3, 2336($t0)
        sw $t3, 2344($t0)
        sw $t3, 2348($t0)
        sw $t3, 2356($t0)
        sw $t3, 2360($t0)
        sw $t3, 2368($t0)
        sw $t3, 2372($t0)
        sw $t3, 2384($t0)
        sw $t3, 2392($t0)
        sw $t3, 2396($t0)
        sw $t3, 2440($t0)
        sw $t3, 2444($t0)
        sw $t3, 2448($t0)
        sw $t3, 2452($t0)
        sw $t3, 2456($t0)
        sw $t3, 2460($t0)
        sw $t3, 2464($t0)
        sw $t3, 2472($t0)
        sw $t3, 2476($t0)
        sw $t3, 2480($t0)
        sw $t3, 2484($t0)
        sw $t3, 2488($t0)
        sw $t3, 2496($t0)
        sw $t3, 2500($t0)
        sw $t3, 2504($t0)
        sw $t3, 2508($t0)
        sw $t3, 2524($t0)
        sw $t3, 2528($t0)
        sw $t3, 2532($t0)
        sw $t3, 2568($t0)
        sw $t3, 2572($t0)
        sw $t3, 2580($t0)
        sw $t3, 2588($t0)
        sw $t3, 2592($t0)
        sw $t3, 2600($t0)
        sw $t3, 2604($t0)
        sw $t3, 2612($t0)
        sw $t3, 2616($t0)
        sw $t3, 2624($t0)
        sw $t3, 2628($t0)
        sw $t3, 2632($t0)
        sw $t3, 2636($t0)
        sw $t3, 2660($t0)
        sw $t3, 2664($t0)
        sw $t3, 2696($t0)
        sw $t3, 2700($t0)
        sw $t3, 2716($t0)
        sw $t3, 2720($t0)
        sw $t3, 2728($t0)
        sw $t3, 2732($t0)
        sw $t3, 2740($t0)
        sw $t3, 2744($t0)
        sw $t3, 2752($t0)
        sw $t3, 2756($t0)
        sw $t3, 2768($t0)
        sw $t3, 2788($t0)
        sw $t3, 2792($t0)
        sw $t3, 2824($t0)
        sw $t3, 2828($t0)
        sw $t3, 2844($t0)
        sw $t3, 2848($t0)
        sw $t3, 2856($t0)
        sw $t3, 2860($t0)
        sw $t3, 2868($t0)
        sw $t3, 2872($t0)
        sw $t3, 2880($t0)
        sw $t3, 2884($t0)
        sw $t3, 2896($t0)
        sw $t3, 2904($t0)
        sw $t3, 2908($t0)
        sw $t3, 2912($t0)
        sw $t3, 2916($t0)	
	jr $ra				# return to caller
	
game_over:				# draws the game over screen. Code generated by a Python script
        la $t0, BASE_ADDRESS
        li $t1, 0xff0000
        li $t2, 0xffffff
        li $t3, 0xff8d00
        li $t4, 0x009eff
        li $t5, 0x4baf31
        sw $t1, 276($t0)
        sw $t1, 280($t0)
        sw $t1, 284($t0)
        sw $t1, 288($t0)
        sw $t1, 300($t0)
        sw $t1, 304($t0)
        sw $t1, 308($t0)
        sw $t1, 320($t0)
        sw $t1, 336($t0)
        sw $t1, 344($t0)
        sw $t1, 348($t0)
        sw $t1, 352($t0)
        sw $t1, 356($t0)
        sw $t1, 360($t0)
        sw $t1, 400($t0)
        sw $t1, 424($t0)
        sw $t1, 440($t0)
        sw $t1, 448($t0)
        sw $t1, 452($t0)
        sw $t1, 460($t0)
        sw $t1, 464($t0)
        sw $t1, 472($t0)
        sw $t1, 528($t0)
        sw $t1, 536($t0)
        sw $t1, 540($t0)
        sw $t1, 544($t0)
        sw $t1, 552($t0)
        sw $t1, 556($t0)
        sw $t1, 560($t0)
        sw $t1, 564($t0)
        sw $t1, 568($t0)
        sw $t1, 576($t0)
        sw $t1, 584($t0)
        sw $t1, 592($t0)
        sw $t1, 600($t0)
        sw $t1, 604($t0)
        sw $t1, 608($t0)
        sw $t1, 612($t0)
        sw $t1, 656($t0)
        sw $t1, 672($t0)
        sw $t1, 680($t0)
        sw $t1, 696($t0)
        sw $t1, 704($t0)
        sw $t1, 720($t0)
        sw $t1, 728($t0)
        sw $t1, 784($t0)
        sw $t1, 800($t0)
        sw $t1, 808($t0)
        sw $t1, 824($t0)
        sw $t1, 832($t0)
        sw $t1, 848($t0)
        sw $t1, 856($t0)
        sw $t1, 916($t0)
        sw $t1, 920($t0)
        sw $t1, 924($t0)
        sw $t1, 936($t0)
        sw $t1, 952($t0)
        sw $t1, 960($t0)
        sw $t1, 976($t0)
        sw $t1, 984($t0)
        sw $t1, 988($t0)
        sw $t1, 992($t0)
        sw $t1, 996($t0)
        sw $t1, 1000($t0)
        sw $t1, 1300($t0)
        sw $t1, 1304($t0)
        sw $t1, 1308($t0)
        sw $t1, 1320($t0)
        sw $t1, 1336($t0)
        sw $t1, 1344($t0)
        sw $t1, 1348($t0)
        sw $t1, 1352($t0)
        sw $t1, 1356($t0)
        sw $t1, 1360($t0)
        sw $t1, 1368($t0)
        sw $t1, 1372($t0)
        sw $t1, 1376($t0)
        sw $t1, 1380($t0)
        sw $t1, 1424($t0)
        sw $t1, 1440($t0)
        sw $t1, 1448($t0)
        sw $t1, 1464($t0)
        sw $t1, 1472($t0)
        sw $t1, 1496($t0)
        sw $t1, 1512($t0)
        sw $t1, 1552($t0)
        sw $t1, 1568($t0)
        sw $t1, 1576($t0)
        sw $t1, 1592($t0)
        sw $t1, 1600($t0)
        sw $t1, 1604($t0)
        sw $t1, 1608($t0)
        sw $t1, 1612($t0)
        sw $t1, 1624($t0)
        sw $t1, 1628($t0)
        sw $t1, 1632($t0)
        sw $t1, 1636($t0)
        sw $t1, 1680($t0)
        sw $t1, 1696($t0)
        sw $t1, 1708($t0)
        sw $t1, 1716($t0)
        sw $t1, 1728($t0)
        sw $t1, 1752($t0)
        sw $t1, 1764($t0)
        sw $t1, 1808($t0)
        sw $t1, 1824($t0)
        sw $t1, 1836($t0)
        sw $t1, 1844($t0)
        sw $t1, 1856($t0)
        sw $t1, 1880($t0)
        sw $t1, 1896($t0)
        sw $t1, 1940($t0)
        sw $t1, 1944($t0)
        sw $t1, 1948($t0)
        sw $t1, 1968($t0)
        sw $t1, 1984($t0)
        sw $t1, 1988($t0)
        sw $t1, 1992($t0)
        sw $t1, 1996($t0)
        sw $t1, 2000($t0)
        sw $t1, 2008($t0)
        sw $t1, 2024($t0)
        sw $t2, 2292($t0)
        sw $t2, 2336($t0)
        sw $t2, 2340($t0)
        sw $t2, 2344($t0)
        sw $t2, 2348($t0)
        sw $t2, 2352($t0)
        sw $t2, 2356($t0)
        sw $t2, 2360($t0)
        sw $t2, 2364($t0)
        sw $t2, 2368($t0)
        sw $t2, 2372($t0)
        sw $t2, 2376($t0)
        sw $t2, 2380($t0)
        sw $t2, 2384($t0)
        sw $t2, 2388($t0)
        sw $t2, 2392($t0)
        sw $t2, 2444($t0)
        sw $t2, 2464($t0)
        sw $t2, 2492($t0)
        sw $t2, 2520($t0)
        sw $t2, 2592($t0)
        sw $t2, 2620($t0)
        sw $t2, 2648($t0)
        sw $t3, 2668($t0)
        sw $t3, 2672($t0)
        sw $t2, 2720($t0)
        sw $t2, 2748($t0)
        sw $t2, 2776($t0)
        sw $t3, 2796($t0)
        sw $t3, 2800($t0)
        sw $t2, 2848($t0)
        sw $t2, 2876($t0)
        sw $t2, 2904($t0)
        sw $t2, 2952($t0)
        sw $t2, 2976($t0)
        sw $t2, 3004($t0)
        sw $t2, 3032($t0)
        sw $t2, 3104($t0)
        sw $t2, 3132($t0)
        sw $t2, 3160($t0)
        sw $t2, 3224($t0)
        sw $t2, 3232($t0)
        sw $t2, 3260($t0)
        sw $t2, 3288($t0)
        sw $t2, 3304($t0)
        sw $t2, 3340($t0)
        sw $t2, 3360($t0)
        sw $t2, 3388($t0)
        sw $t2, 3416($t0)
        sw $t2, 3488($t0)
        sw $t2, 3492($t0)
        sw $t2, 3496($t0)
        sw $t2, 3500($t0)
        sw $t2, 3504($t0)
        sw $t2, 3508($t0)
        sw $t2, 3512($t0)
        sw $t2, 3516($t0)
        sw $t2, 3520($t0)
        sw $t2, 3524($t0)
        sw $t2, 3528($t0)
        sw $t2, 3532($t0)
        sw $t2, 3536($t0)
        sw $t2, 3540($t0)
        sw $t2, 3544($t0)
        sw $t2, 3700($t0)
        sw $t2, 3724($t0)
        sw $t4, 3764($t0)
        sw $t4, 3768($t0)
        sw $t4, 3772($t0)
        sw $t4, 3776($t0)
        sw $t4, 3780($t0)
        sw $t4, 3784($t0)
        sw $t5, 3884($t0)
        sw $t4, 3888($t0)
        sw $t4, 3892($t0)
        sw $t4, 3896($t0)
        sw $t4, 3900($t0)
        sw $t4, 3904($t0)
        sw $t4, 3908($t0)
        sw $t4, 3912($t0)
        sw $t5, 3916($t0)
        sw $t5, 3920($t0)
        sw $t5, 4008($t0)
        sw $t5, 4012($t0)
        sw $t4, 4016($t0)
        sw $t4, 4020($t0)
        sw $t4, 4024($t0)
        sw $t4, 4028($t0)
        sw $t4, 4032($t0)
        sw $t5, 4036($t0)
        sw $t5, 4040($t0)
        sw $t5, 4044($t0)
        sw $t5, 4048($t0)
        sw $t5, 4052($t0)
        jr $ra				# return to caller
