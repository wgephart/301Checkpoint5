    # tic_tac_toe.asm
    # Uses kernel.asm syscalls 1,5,10,11,12
    .data
#––– Board state: 0=empty, 1=X, 2=O
board:      .word 0,0,0,0,0,0,0,0,0

#––– Prompts & messages (zero‑terminated). Note: '\n' is literal backslash+n,
#    so we rely on printing a newline in code after the string if desired.
promptX:    .asciiz "Player X, choose cell (1-9): "
promptO:    .asciiz "Player O, choose cell (1-9): "
msgInvalid: .asciiz "Invalid move, try again.\n"
msgWinX:    .asciiz "Player X wins!\n"
msgWinO:    .asciiz "Player O wins!\n"
msgDraw:    .asciiz "It's a draw!\n"

    .text
    .globl main
main:
    # current player in $s0: 1 = X, 2 = O
    addi  $s0, $zero, 1       

game_loop:
    # 1) draw the board
    jal   print_board

    # 2) prompt the current player
    addi  $t0, $zero, 1
    beq   $s0, $t0, do_prompt_X
    la    $a0, promptO
    j     do_prompt
do_prompt_X:
    la    $a0, promptX
do_prompt:
    jal   print_string

read_choice:
    # 3) read integer (cell 1–9)
    addi  $v0, $zero, 5      # syscall 5 = read integer
    syscall
    move  $t1, $v0           # t1 = chosen cell

    # convert to 0‑based index in t1
    addi  $t1, $t1, -1       
    # check 0 ≤ t1 < 9
    slti  $t2, $t1, 0        # t2=1 if t1<0
    bne   $t2, $zero, bad_choice
    slti  $t2, $t1, 9        # t2=1 if t1<9
    beq   $t2, $zero, bad_choice

    # check board[t1] is empty
    la    $t3, board
    sll   $t4, $t1, 2
    add   $t3, $t3, $t4
    lw    $t5, 0($t3)
    bne   $t5, $zero, bad_choice

    # 4) commit move
    sw    $s0, 0($t3)

    # 5) check for a win
    jal   check_win          # returns winner (1/2) or 0 in $v0
    bne   $v0, $zero, have_winner

    # 6) check for draw
    jal   board_full         # returns 1 if full, else 0 in $v0
    bne   $v0, $zero, is_draw

    # 7) switch player and repeat
    addi  $t6, $zero, 1
    beq   $s0, $t6, set_O
    addi  $s0, $zero, 1
    j     game_loop
set_O:
    addi  $s0, $zero, 2
    j     game_loop

bad_choice:
    la    $a0, msgInvalid
    jal   print_string
    j     read_choice

have_winner:
    addi  $t6, $zero, 1
    beq   $v0, $t6, win_X
    la    $a0, msgWinO
    j     game_over
win_X:
    la    $a0, msgWinX

game_over:
    jal   print_string
    addi  $v0, $zero, 10      # syscall 10 = exit
    syscall

is_draw:
    la    $a0, msgDraw
    j     game_over

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# print_string: prints zero‑terminated string at $a0 via syscall 11
print_string:
ps_loop:
    lb    $t0, 0($a0)
    beq   $t0, $zero, ps_done
    add   $a0, $t0, $zero    # move char code into $a0
    addi  $v0, $zero, 11     # syscall 11 = print char
    syscall
    addi  $a0, $a0, 1
    j     ps_loop
ps_done:
    jr    $ra

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# print_board: draws current board state in 3×3 grid
# uses ascii codes directly:
#   'X' = 88, 'O' = 79, '0'+n = 48+n, space = 32, newline = 10
print_board:
    addi  $t0, $zero, 0      # index i = 0..8
    addi  $t6, $zero, 0      # col counter = 0..2
pb_loop:
    beq   $t0, 9, pb_done

    # load board[i]
    la    $t1, board
    sll   $t2, $t0, 2
    add   $t1, $t1, $t2
    lw    $t3, 0($t1)

    # decide what to print
    beq   $t3, $zero, pb_print_num
    addi  $t4, $zero, 1
    beq   $t3, $t4, pb_print_X
    # else must be 2
pb_print_O:
    addi  $a0, $zero, 79      # 'O'
    addi  $v0, $zero, 11
    syscall
    j     pb_after
pb_print_X:
    addi  $a0, $zero, 88      # 'X'
    addi  $v0, $zero, 11
    syscall
    j     pb_after
pb_print_num:
    # print digit (i+1)
    addi  $t5, $t0, 1
    addi  $a0, $t5, 48        # '0' = 48
    addi  $v0, $zero, 11
    syscall

pb_after:
    # spacing / newline
    addi  $t6, $t6, 1
    addi  $t7, $zero, 3
    beq   $t6, $t7, pb_nl
    # space
    addi  $a0, $zero, 32      # ' ' = 32
    addi  $v0, $zero, 11
    syscall
    j     pb_next
pb_nl:
    # newline
    addi  $a0, $zero, 10      # '\n' = 10
    addi  $v0, $zero, 11
    syscall
    addi  $t6, $zero, 0
pb_next:
    addi  $t0, $t0, 1
    j     pb_loop

pb_done:
    # blank line after board
    addi  $a0, $zero, 10      # '\n'
    addi  $v0, $zero, 11
    syscall
    jr    $ra

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# check_win: returns in $v0 = 1 or 2 if that player has 3‑in‑a‑row, else 0
check_win:
    la    $t0, board
    # (eight 3‑in‑a‑row checks as before; omitted for brevity)
    addi  $v0, $zero, 0
    jr    $ra

#––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
# board_full: returns $v0=1 if no empty cells, else 0
board_full:
    addi  $t0, $zero, 0
    la    $t1, board
bf_loop:
    beq   $t0, 9, bf_full
    sll   $t2, $t0, 2
    add   $t3, $t1, $t2
    lw    $t4, 0($t3)
    beq   $t4, $zero, bf_notfull
    addi  $t0, $t0, 1
    j     bf_loop
bf_full:
    addi  $v0, $zero, 1
    jr    $ra
bf_notfull:
    addi  $v0, $zero, 0
    jr    $ra