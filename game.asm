#####################################################################
#
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Name, Student Number, UTorID
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
# - Milestone 1/2/3/4 (choose the one the applies)
#
# Which approved features have been implemented for milestone 4?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know: 
# - (write here, if any)
#
#####################################################################

.eqv BASE_ADDRESS	0x10008000

.data

.text
.globl main

# draw_obstacle(obs_array) loop through the array and draw the obastacle on the screen
draw_obstacle:
	# pop off the stack
	lw $t0, 0($sp)		# pop y off the stack
	addi $sp, $sp, 4
	lw $t1, 0($sp)		# pop x off the stack


	li $t3, 0xa7a7a7	# light gray colour
	li $t4, 0x6f6f6f	# gray colour

main:
	li $t0, BASE_ADDRESS	# $t1 will store the base address
	


	# First let's render the 1st obstacle at (30,1)
	sw $t1, 248($t0)
	sw $t2, 120($t0)
	sw $t2, 376($t0)
	sw $t2, 252($t0)
	sw $t2, 244($t0)

	li $v0, 10	# terminate the program gracfully
	syscall

















