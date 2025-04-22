.data
prev_result: .word 0

.text
.globl main

main:
    # Load ASCII constants into saved registers
    addi $s5, $zero, 48    # '0'
    addi $s6, $zero, 57    # '9'
    addi $s7, $zero, 10    # newline

calc_loop:
    # read first operand
    addi $v0, $zero, 12    # read char
    syscall
    add  $s4, $zero, $v0   # first char in $s4

    # If '_' use previous result
    addi $t0, $zero, 95    # '_'
    beq  $s4, $t0, use_prev1
    # else parse integer starting with first digit
    sub  $s4, $s4, $s5     # digit value
    jal  parse_int        # returns full int in $v0
    add  $s0, $zero, $v0   # operand1 = v0
    j    read_op

use_prev1:
    lw   $s0, 0(prev_result)

read_op:
    # read operator
    addi $v0, $zero, 12
    syscall
    add  $s1, $zero, $v0   # operator

    # read second operand
read_second:
    addi $v0, $zero, 12
    syscall
    add  $s4, $zero, $v0   # char in $s4
    addi $t0, $zero, 95
    beq  $s4, $t0, use_prev2
    sub  $s4, $s4, $s5     # digit
    jal  parse_int
    add  $s2, $zero, $v0   # operand2
    j    compute

use_prev2:
    lw   $s2, 0(prev_result)

compute:
    # compute result and put in $s3
    addi $t0, $zero, 43    # '+'
    beq  $s1, $t0, do_add
    addi $t0, $zero, 45    # '-'
    beq  $s1, $t0, do_sub
    addi $t0, $zero, 42    # '*'
    beq  $s1, $t0, do_mul
    addi $t0, $zero, 47    # '/'
    beq  $s1, $t0, do_div
    j    calc_loop         # invalid

do_add:
    add  $s3, $s0, $s2
    j    print_result

do_sub:
    sub  $s3, $s0, $s2
    j    print_result

do_mul:
    mult $s0, $s2
    mflo $s3
    j    print_result

do_div:
    div  $s0, $s2
    mflo $s3

print_result:
    # print integer
    add  $a0, $zero, $s3
    addi $v0, $zero, 1
    syscall
    # save for next
    sw   $s3, 0(prev_result)
    # newline
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall
    j    calc_loop

parse_int:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
parse_loop:
    addi $v0, $zero, 12
    syscall
    beq  $v0, $s7, parse_done
    sub  $v0, $v0, $s5

    add  $t1, $s4, $zero
    sll  $s4, $s4, 3
    sll  $t1, $t1, 1
    add  $s4, $s4, $t1
    add  $s4, $s4, $v0
    j    parse_loop
parse_done:
    add  $v0, $zero, $s4
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
