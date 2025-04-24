.data
prev_result: .word 0

.text
.globl main

# Registers:
# $s0: operand1
# $s1: operator
# $s2: operand2
# $s3: result
# $s4: digit accumulator / lookahead
# $s5: '0'
# $s6: '9'
# $s7: newline

main:
    addi $s5, $zero, 48    # '0'
    addi $s6, $zero, 57    # '9'
    addi $s7, $zero, 10    # newline

calc_loop:
    # --- Operand1 ---
    addi $v0, $zero, 12    # read char
    syscall
    add  $t0, $zero, $v0
    addi $t1, $zero, 95    # '_'
    beq  $t0, $t1, use_prev1
    addi $t1, $zero, 45    # '-'
    beq  $t0, $t1, neg1
    sub  $s4, $t0, $s5     # digit
    jal  parse_int
    add  $s0, $zero, $v0
    j    after_op1

use_prev1:
    lw   $s0, 0(prev_result)
    # no get lookahead here—operator will be next input
after_op1:

    # --- Operator ---
    addi $v0, $zero, 12
    syscall
    add  $s1, $zero, $v0

    # --- Operand2 ---
    addi $v0, $zero, 12    # read first char
    syscall
    add  $t0, $zero, $v0
    addi $t1, $zero, 95    # '_'
    beq  $t0, $t1, use_prev2
    addi $t1, $zero, 45    # '-'
    beq  $t0, $t1, neg2
    sub  $s4, $t0, $s5     # digit
    jal  parse_int
    add  $s2, $zero, $v0
    j    compute

use_prev2:
    lw   $s2, 0(prev_result)
    j    compute

neg1:
    addi $v0, $zero, 12    # read next digit
    syscall
    add  $t0, $zero, $v0
    sub  $s4, $t0, $s5
    jal  parse_int
    sub  $s0, $zero, $v0
    j    after_op1

neg2:
    addi $v0, $zero, 12
    syscall
    add  $t0, $zero, $v0
    sub  $s4, $t0, $s5
    jal  parse_int
    sub  $s2, $zero, $v0
    j    compute

compute:
    addi $t1, $zero, 43    # '+'
    beq  $s1, $t1, do_add
    addi $t1, $zero, 45    # '-'
    beq  $s1, $t1, do_sub
    addi $t1, $zero, 42    # '*'
    beq  $s1, $t1, do_mul
    addi $t1, $zero, 47    # '/'
    beq  $s1, $t1, do_div
    j    calc_loop

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
    add  $a0, $zero, $s3
    addi $v0, $zero, 1
    syscall
    sw   $s3, 0(prev_result)
    addi $a0, $zero, 10
    addi $v0, $zero, 11
    syscall
    j    calc_loop

# parse_int: reads digits until non-digit, returns value in $v0, lookahead in $s4
parse_int:
    addi $sp, $sp, -4
    sw   $ra, 0($sp)
parse_loop:
    addi $v0, $zero, 12
    syscall
    add  $t0, $zero, $v0
    slt  $t2, $t0, $s5
    bne  $t2, $zero, parse_done
    sgt  $t2, $t0, $s6
    bne  $t2, $zero, parse_done
    sub  $t0, $t0, $s5
    add  $t1, $s4, $zero
    sll  $s4, $s4, 3
    sll  $t1, $t1, 1
    add  $s4, $s4, $t1
    add  $s4, $s4, $t0
    j    parse_loop
parse_done:
    add  $v0, $zero, $s4
    add  $s4, $zero, $t0
    lw   $ra, 0($sp)
    addi $sp, $sp, 4
    jr   $ra
