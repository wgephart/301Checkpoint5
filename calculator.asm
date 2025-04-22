.data
.text

Calcloop:
    addi $v0, $0, 5 # read int (if first char is _ then this will do nothing)
    syscall

    addi $s0, $v0, 0 # first term in s0

    addi $v0, $0, 12 # read char
    syscall
    addi $s1, $v0, 0 #operand in s1

    addi $t0, $0, 95 #_ ASCII
    beq $s1, $t0, Underscore1

    addi $v0, $0, 5 # read int
    syscall

    addi $s2, $v0, 0 # second term in s2

    addi $t1, $0, 43
    beq $t1, $s1, Addition
    addi $t1, $0, 45
    beq $t1, $s1, Subtraction
    addi $t1, $0, 47
    beq $t1, $s1, Division
    addi $t1, $0, 42
    beq $t1, $s1, Multiplication
    addi $t1, $0, 37
    beq $t1, $s1, Modulo

Underscore1:
    addi $s0, $s7, 0 #puts past result in s0

    addi $v0, $0, 12 # read char
    syscall
    addi $s1, $v0, 0 #operand in s1

    addi $v0, $0, 5 # read int
    syscall

    addi $s2, $v0, 0 # second term in s2

    addi $v0, $0, 12 # read char
    syscall

    addi $t0, $0, 95 #_ ASCII
    beq $s1, $t0, Underscore1

    addi $t1, $0, 43
    beq $t1, $s1, Addition
    addi $t1, $0, 45
    beq $t1, $s1, Subtraction
    addi $t1, $0, 47
    beq $t1, $s1, Division
    addi $t1, $0, 42
    beq $t1, $s1, Multiplication
    addi $t1, $0, 37
    beq $t1, $s1, Modulo

Underscore2:
    addi $v0, $0, 12 # read char
    syscall

    addi $s2, $s7, 0 # put past result in t2

    addi $t1, $0, 43
    beq $t1, $s1, Addition
    addi $t1, $0, 45
    beq $t1, $s1, Subtraction
    addi $t1, $0, 47
    beq $t1, $s1, Division
    addi $t1, $0, 42
    beq $t1, $s1, Multiplication
    addi $t1, $0, 37
    beq $t1, $s1, Modulo

Addition:
    add $s7, $s0, $s2
    addi $v0, $0, 1   #print int
    addi $a0, $s7, 0
    syscall
    j Calcloop
Subtraction:
    sub $s7, $s0, $s2
    addi $v0, $0, 1   #print int
    addi $a0, $s7, 0
    syscall
    j Calcloop
Division:
    div $s0, $s2
    mflo $s7
    addi $v0, $0, 1   #print int
    addi $a0, $s7, 0
    syscall
    j Calcloop
Multiplication:
    mult $s0, $s2
    mflo $s7
    addi $v0, $0, 1   #print int
    addi $a0, $s7, 0
    syscall
    j Calcloop
Modulo:
    div $s0, $s2
    mfhi $s7
    addi $v0, $0, 1   #print int
    addi $a0, $s7, 0
    syscall
    j Calcloop