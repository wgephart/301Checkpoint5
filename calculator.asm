.data
.text
    addi $s0, $0, 95 # _ ascii
    addi $s1, $0, 43 # + ascii
    addi $s2, $0, 45 # - ascii
    addi $s3, $0, 47 # / ascii
    addi $s4, $0, 42 # * ascii
    addi $s5, $0, 37 # % ascii
    addi $s6, $0, 0 # previous result

calc_loop:
    # read integer
    addi $v0, $0, 5
    syscall

    addi $t0, $v0, 0 # $t0 = first term

    # read chaacter
    addi $v0, $0, 12
    syscall

    addi $t1, $v0, 0 # $t1 = operator

    beq $t1, $s0, underscore_first

    addi $v0, $0, 5 
    syscall

    addi $t2, $v0, 0 # $t2 = second term

    addi $v0, $0, 12
    syscall

    beq $t1, $s0, underscore_second

    beq $t1, $s1, addition 
    beq $t1, $s2, subtraction
    beq $t1, $s3, division
    beq $t1, $s4, multiplication
    beq $t1, $s5, modulo

underscore_first:
    addi $t0, $s6, 0 # $t0 = previous result

    addi $v0, $0, 12
    syscall

    addi $t1, $v0, 0 # $t1 = operator

    addi $v0, $0, 5 # read int
    syscall

    addi $t2, $v0, 0 # $t2 = second term

    addi $v0, $0, 12 # read char
    syscall

    beq $t1, $s0, underscore_second

    beq $t1, $s1, addition
    beq $t1, $s2, subtraction
    beq $t1, $s3, division
    beq $t1, $s4, multiplication
    beq $t1, $s5, modulo

underscore_second:
    addi $v0, $0, 12
    syscall

    addi $t2, $s6, 0 # $t2 = previous result
    beq $t1, $s1, addition
    beq $t1, $s2, subtraction
    beq $t1, $s3, division
    beq $t1, $s4, multiplication
    beq $t1, $s5, modulo

addition:
    add $s6, $t0, $t2
    addi $v0, $0, 1
    addi $a0, $s6, 0
    syscall
    j calc_loop

subtraction:
    sub $s6, $t0, $t2
    addi $v0, $0, 1
    addi $a0, $s6, 0
    syscall
    j calc_loop

division:
    div $t0, $t2
    mflo $s6
    addi $v0, $0, 1 
    addi $a0, $s6, 0
    syscall
    j calc_loop

multiplication:
    mult $t0, $t2
    mflo $s6
    addi $v0, $0, 1 
    addi $a0, $s6, 0
    syscall
    j calc_loop

modulo:
    div $t0, $t2
    mfhi $s6
    addi $v0, $0, 1 
    addi $a0, $s6, 0
    syscall
    j calc_loop
