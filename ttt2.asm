.data
.text
.align 2 
.globl main
main:
    # Reserve stack space for our game board (3x3 = 9 cells)
    # Each cell is a word (4 bytes)
    addi $sp, $sp, -36      # Allocate space for 9-cell board
    
    # Initialize registers for game state
    addi $s0, $zero, 0      # s0 = current player (0 = X, 1 = O)
    addi $s1, $zero, 0      # s1 = number of moves made (0-9)
    addi $s2, $zero, 0      # s2 = game status (0 = ongoing, 1 = win, 2 = draw)
    addi $s3, $sp, 0        # s3 = pointer to game board in memory
    
    # Initialize the game board to all empty cells (value 2)
    addi $t0, $zero, 0      # t0 = counter for initialization loop
    addi $t1, $zero, 9      # t1 = total number of cells
    addi $t2, $zero, 2      # t2 = empty cell value (2)
    
init_board:
    beq $t0, $t1, init_done # If counter reaches 9, initialization is done
    sll $t3, $t0, 2         # t3 = offset (counter * 4 bytes)
    add $t4, $s3, $t3       # t4 = address of current cell
    sw $t2, 0($t4)          # Store empty value (2) in current cell
    addi $t0, $t0, 1        # Increment counter
    j init_board

init_done:
    # Display welcome message
    addi $v0, $zero, 11             # syscall 11 = print character
    addi $a0, $zero, 84             # 'T'
    syscall
    addi $a0, $zero, 73             # 'I'
    syscall
    addi $a0, $zero, 67             # 'C'
    syscall
    addi $a0, $zero, 45             # '-'
    syscall
    addi $a0, $zero, 84             # 'T'
    syscall
    addi $a0, $zero, 65             # 'A'
    syscall
    addi $a0, $zero, 67             # 'C'
    syscall
    addi $a0, $zero, 45             # '-'
    syscall
    addi $a0, $zero, 84             # 'T'
    syscall
    addi $a0, $zero, 79             # 'O'
    syscall
    addi $a0, $zero, 69             # 'E'
    syscall
    addi $a0, $zero, 10             # '\n'
    syscall
    addi $a0, $zero, 10             # '\n'
    syscall
    
    # Print instructions
    addi $a0, $zero, 85             # 'U'
    syscall
    addi $a0, $zero, 115            # 's'
    syscall
    addi $a0, $zero, 101            # 'e'
    syscall
    addi $a0, $zero, 32             # ' '
    syscall
    addi $a0, $zero, 49             # '1'
    syscall
    addi $a0, $zero, 45             # '-'
    syscall
    addi $a0, $zero, 57             # '9'
    syscall
    addi $a0, $zero, 32             # ' '
    syscall
    addi $a0, $zero, 116            # 't'
    syscall
    addi $a0, $zero, 111            # 'o'
    syscall
    addi $a0, $zero, 32             # ' '
    syscall
    addi $a0, $zero, 112            # 'p'
    syscall
    addi $a0, $zero, 108            # 'l'
    syscall
    addi $a0, $zero, 97             # 'a'
    syscall
    addi $a0, $zero, 121            # 'y'
    syscall
    addi $a0, $zero, 10             # '\n'
    syscall
    addi $a0, $zero, 10             # '\n'
    syscall

# Main game loop
game_loop:
    # Display the current board
    jal draw_board
    
    # Check game status
    bne $s2, $zero, game_over    # If game status is not 0, game is over
    
    # Show current player
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 80          # 'P'
    syscall
    addi $a0, $zero, 108         # 'l'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 121         # 'y'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    addi $a0, $zero, 114         # 'r'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    
    beq $s0, $zero, player_x     # If current player is 0, show X
    addi $a0, $zero, 79          # 'O'
    j show_player
player_x:
    addi $a0, $zero, 88          # 'X'
show_player:
    syscall
    addi $a0, $zero, 39          # ' 
    syscall
    addi $a0, $zero, 115         # 's'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    addi $a0, $zero, 116         # 't'
    syscall
    addi $a0, $zero, 117         # 'u'
    syscall
    addi $a0, $zero, 114         # 'r'
    syscall
    addi $a0, $zero, 110         # 'n'
    syscall
    addi $a0, $zero, 58          # ':'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    
    # Get player move (1-9)
    addi $v0, $zero, 5           # syscall 5 = read integer
    syscall
    add $t0, $v0, $zero          # t0 = player input
    
    # Validate input (must be 1-9)
    addi $t1, $zero, 1
    slt $t2, $t0, $t1            # t2 = 1 if input < 1
    bne $t2, $zero, invalid_move
    
    addi $t1, $zero, 10
    slt $t2, $t0, $t1            # t2 = 1 if input < 10
    beq $t2, $zero, invalid_move # If input >= 10, invalid
    
    # Convert 1-9 input to 0-8 index
    addi $t0, $t0, -1
    
    # Check if cell is already taken
    sll $t1, $t0, 2              # t1 = offset (index * 4 bytes)
    add $t1, $s3, $t1            # t1 = address of selected cell
    lw $t2, 0($t1)               # t2 = value of selected cell
    addi $t3, $zero, 2           # t3 = empty cell value (2)
    bne $t2, $t3, cell_taken     # If cell is not empty, it's taken
    
    # Place the player's mark (0 for X, 1 for O)
    sw $s0, 0($t1)               # Store current player's mark in selected cell
    
    # Check for win condition
    jal check_win
    bne $v0, $zero, player_wins  # If check_win returns non-zero, someone won
    
    # Check for draw (all cells filled)
    addi $s1, $s1, 1             # Increment move counter
    addi $t0, $zero, 9           # t0 = total cells
    beq $s1, $t0, game_draw      # If 9 moves made, it's a draw
    
    # Switch player
    addi $t0, $zero, 1
    sub $s0, $t0, $s0            # Toggle between 0 and 1
    
    j game_loop                  # Continue game loop

invalid_move:
    # Display error message for invalid move
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 10          # '\n'
    syscall
    addi $a0, $zero, 73          # 'I'
    syscall
    addi $a0, $zero, 110         # 'n'
    syscall
    addi $a0, $zero, 118         # 'v'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 108         # 'l'
    syscall
    addi $a0, $zero, 105         # 'i'
    syscall
    addi $a0, $zero, 100         # 'd'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    addi $a0, $zero, 109         # 'm'
    syscall
    addi $a0, $zero, 111         # 'o'
    syscall
    addi $a0, $zero, 118         # 'v'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    
    j game_loop                  # Retry

cell_taken:
    # Display error message for taken cell
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 10          # '\n'
    syscall
    addi $a0, $zero, 67          # 'C'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    addi $a0, $zero, 108         # 'l'
    syscall
    addi $a0, $zero, 108         # 'l'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    addi $a0, $zero, 116         # 't'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 107         # 'k'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    addi $a0, $zero, 110         # 'n'
    syscall
    addi $a0, $zero, 10          # '\n'
    syscall
    
    j game_loop                  # Retry

player_wins:
    # Set game status to win
    addi $s2, $zero, 1           # s2 = 1 (win)
    j game_over

game_draw:
    # Set game status to draw
    addi $s2, $zero, 2           # s2 = 2 (draw)
    j game_over

game_over:
    # Display final board
    jal draw_board
    
    # Display game result
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 10          # '\n'
    syscall
    
    addi $t0, $zero, 1           # t0 = 1 (win status)
    beq $s2, $t0, show_winner    # If game status is win, show winner
    
    # Otherwise it's a draw
    addi $a0, $zero, 71          # 'G'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 109         # 'm'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    addi $a0, $zero, 68          # 'D'
    syscall
    addi $a0, $zero, 114         # 'r'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 119         # 'w'
    syscall
    addi $a0, $zero, 33          # '!'
    syscall
    j end_game

show_winner:
    # Show which player won
    addi $a0, $zero, 80          # 'P'
    syscall
    addi $a0, $zero, 108         # 'l'
    syscall
    addi $a0, $zero, 97          # 'a'
    syscall
    addi $a0, $zero, 121         # 'y'
    syscall
    addi $a0, $zero, 101         # 'e'
    syscall
    addi $a0, $zero, 114         # 'r'
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    
    beq $s0, $zero, winner_x     # If current player is 0, X won
    addi $a0, $zero, 79          # 'O'
    j show_winner_char
winner_x:
    addi $a0, $zero, 88          # 'X'
show_winner_char:
    syscall
    addi $a0, $zero, 32          # ' '
    syscall
    addi $a0, $zero, 119         # 'w'
    syscall
    addi $a0, $zero, 105         # 'i'
    syscall
    addi $a0, $zero, 110         # 'n'
    syscall
    addi $a0, $zero, 115         # 's'
    syscall
    addi $a0, $zero, 33          # '!'
    syscall

end_game:
    # End program
    addi $v0, $zero, 10          # syscall 10 = terminate program
    syscall

# Draw board function
draw_board:
    # Save return address on stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Print newline before board
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 10          # '\n'
    syscall
    
    # Initialize counter for board cells
    addi $t0, $zero, 0           # t0 = counter (0-8)
    
draw_loop:
    # Check if we've drawn all cells
    addi $t1, $zero, 9
    beq $t0, $t1, draw_done      # If counter reaches 9, drawing is done
    
    # Calculate address of current cell
    sll $t1, $t0, 2              # t1 = offset (counter * 4 bytes)
    add $t1, $s3, $t1            # t1 = address of current cell
    lw $t2, 0($t1)               # t2 = value of current cell
    
    # Print cell value (X, O, or number)
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $t3, $zero, 2           # t3 = empty cell value (2)
    bne $t2, $t3, print_mark     # If cell is not empty, print mark
    
    # Print cell number (1-9) for empty cells
    addi $a0, $t0, 49            # a0 = ASCII for '1' + counter
    j print_cell

print_mark:
    # Print X or O depending on cell value
    beq $t2, $zero, print_x      # If cell value is 0, print X
    addi $a0, $zero, 79          # a0 = 'O'
    j print_cell
print_x:
    addi $a0, $zero, 88          # a0 = 'X'
print_cell:
    syscall
    
    # Print cell separator or newline
    addi $t3, $t0, 1
    div $t3, $t3, 3
    mfhi $t3                     # t3 = (counter + 1) % 3
    
    bne $t3, $zero, no_newline   # If not end of row, no newline
    
    # End of row, print newline
    addi $a0, $zero, 10          # '\n'
    syscall
    
    # Print row separator if not last row
    addi $t3, $zero, 8
    beq $t0, $t3, no_separator   # If counter is 8, we're at last cell, no separator
    
    # Check if we need row separator (after cells 2 and 5)
    addi $t3, $zero, 2
    beq $t0, $t3, print_separator
    addi $t3, $zero, 5
    beq $t0, $t3, print_separator
    j no_separator

print_separator:
    # Print separator row (---)
    addi $a0, $zero, 45          # '-'
    syscall
    addi $a0, $zero, 45          # '-'
    syscall
    addi $a0, $zero, 45          # '-'
    syscall
    addi $a0, $zero, 10          # '\n'
    syscall
    j no_separator

no_newline:
    # Print column separator (|)
    addi $a0, $zero, 124         # '|'
    syscall
    
no_separator:
    # Increment counter and continue
    addi $t0, $t0, 1
    j draw_loop

draw_done:
    # Print newline after board
    addi $v0, $zero, 11          # syscall 11 = print character
    addi $a0, $zero, 10          # '\n'
    syscall
    
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

# Check win function (checks for 3 in a row)
check_win:
    # Rows
    addi $t0, $zero, 0           # Row 1 (cells 0,1,2)
    jal check_line
    bne $v0, $zero, check_win_return
    
    addi $t0, $zero, 3           # Row 2 (cells 3,4,5)
    jal check_line
    bne $v0, $zero, check_win_return
    
    addi $t0, $zero, 6           # Row 3 (cells 6,7,8)
    jal check_line
    bne $v0, $zero, check_win_return
    
    # Columns
    addi $t0, $zero, 0           # Column 1 (cells 0,3,6)
    addi $t1, $zero, 3
    jal check_line_with_step
    bne $v0, $zero, check_win_return
    
    addi $t0, $zero, 1           # Column 2 (cells 1,4,7)
    addi $t1, $zero, 3
    jal check_line_with_step
    bne $v0, $zero, check_win_return
    
    addi $t0, $zero, 2           # Column 3 (cells 2,5,8)
    addi $t1, $zero, 3
    jal check_line_with_step
    bne $v0, $zero, check_win_return
    
    # Diagonals
    addi $t0, $zero, 0           # Diagonal 1 (cells 0,4,8)
    addi $t1, $zero, 4
    jal check_line_with_step
    bne $v0, $zero, check_win_return
    
    addi $t0, $zero, 2           # Diagonal 2 (cells 2,4,6)
    addi $t1, $zero, 2
    jal check_line_with_step
    
check_win_return:
    jr $ra

# Check a horizontal line starting at position t0
check_line:
    addi $t1, $zero, 1           # t1 = step size (always 1 for horizontal)
check_line_with_step:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # Get values of the three cells in the line
    sll $t2, $t0, 2              # t2 = offset for first cell
    add $t2, $s3, $t2            # t2 = address of first cell
    lw $t3, 0($t2)               # t3 = value of first cell
    
    sll $t4, $t1, 2              # t4 = bytes per step
    add $t2, $t2, $t4            # t2 = address of second cell
    lw $t5, 0($t2)               # t5 = value of second cell
    
    add $t2, $t2, $t4            # t2 = address of third cell
    lw $t6, 0($t2)               # t6 = value of third cell
    
    # Check if all three cells have the same player's mark and are not empty
    addi $t2, $zero, 2           # t2 = empty cell value (2)
    beq $t3, $t2, no_win         # If first cell is empty, no win
    bne $t3, $t5, no_win         # If first and second cells don't match, no win
    bne $t3, $t6, no_win         # If first and third cells don't match, no win
    
    # All three cells match and are not empty, we have a win
    addi $v0, $zero, 1           # Return 1 to indicate win
    j check_line_done
    
no_win:
    addi $v0, $zero, 0           # Return 0 to indicate no win
    
check_line_done:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra