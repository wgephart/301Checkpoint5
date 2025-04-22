.data
prev_result: .word 0

.text
.globl main

# Registers usage:
# $s0: parse_number accumulator
# $s1: operator
# $s2: left operand for parentheses
# $s3: final result
# $s4: lookahead char
# $s5: ascii '0'
# $s6: ascii '9'
# $s7: ascii newline (10)

main:
    # Initialize constants
    addi $s5, $zero, 48    # '0'
    addi $s6, $zero, 57    # '9'
    addi $s7, $zero, 10    # newline

calc_loop:
    # Skip whitespace, get lookahead in $s4
    jal  skip_ws
    # Parse full expression, result in $v0, lookahead in $s4
    jal  parse_expr
    add  $s3, $zero, $v0   # save result

    # Print result integer
    add  $a0, $zero, $s3
    addi $v0, $zero, 1     # syscall 1: print int
    syscall
    # Store for next use
    sw   $s3, 0(prev_result)
    # Print newline char
    add  $a0, $zero, $s7   # newline
    addi $v0, $zero, 11    # syscall 11: print char
    syscall
    j    calc_loop

# getChar: syscall 12 -> $s4
getChar:
    addi $v0, $zero, 12    # read char
    syscall
    add  $s4, $zero, $v0
    jr   $ra

# skip_ws: read into $s4 until non-space and non-newline
skip_ws:
    jal  getChar
    addi $t0, $zero, 32    # space
    beq  $s4, $t0, skip_ws
    beq  $s4, $s7, skip_ws # newline
    jr   $ra

# parse_expr: result in $v0, lookahead in $s4
parse_expr:
    addi $t0, $zero, 95    # '_'
    beq  $s4, $t0, parse_prev
    addi $t0, $zero, 40    # '('
    beq  $s4, $t0, parse_paren
    jal  parse_number      # number
    jr   $ra

parse_prev:
    lw   $v0, 0(prev_result)
    jal  getChar
    jr   $ra

parse_paren:
    jal  getChar          # consume '('
    jal  parse_expr       # parse left
    add  $s2, $zero, $v0  # store left operand
    jal  skip_ws
    add  $s1, $zero, $s4  # operator
    jal  getChar          # consume operator
    jal  parse_expr       # parse right
    add  $t1, $zero, $v0  # store right operand
    jal  skip_ws
    jal  getChar          # consume ')'
    # compute
    addi $t0, $zero, 43   # '+'
    beq  $s1, $t0, do_add2
    addi $t0, $zero, 45   # '-'
    beq  $s1, $t0, do_sub2
    addi $t0, $zero, 42   # '*'
    beq  $s1, $t0, do_mul2
    addi $t0, $zero, 47   # '/'
    beq  $s1, $t0, do_div2
    add  $v0, $zero, $zero
    jr   $ra

do_add2:
    add  $v0, $s2, $t1
    jr   $ra

do_sub2:
    sub  $v0, $s2, $t1
    jr   $ra

do_mul2:
    mult $s2, $t1
    mflo $v0
    jr   $ra

do_div2:
    div  $s2, $t1
    mflo $v0
    jr   $ra

# parse_number: initial digit in $s4, result in $v0, lookahead in $s4
parse_number:
    sub  $s0, $s4, $s5     # accumulator = first digit
num_loop:
    jal  getChar
    # if non-digit, exit loop
    slt  $t2, $s4, $s5    # s4 < '0'
    bne  $t2, $zero, num_done
    sgt  $t2, $s4, $s6    # s4 > '9'
    bne  $t2, $zero, num_done
    sub  $t1, $s4, $s5    # digit = s4 - '0'
    add  $t3, $s0, $zero
    sll  $s0, $s0, 3      # s0*8
    sll  $t3, $t3, 1      # s0*2
    add  $s0, $s0, $t3    # s0*10
    add  $s0, $s0, $t1    # s0 += digit
    j    num_loop
num_done:
    add  $v0, $zero, $s0
    jr   $ra
