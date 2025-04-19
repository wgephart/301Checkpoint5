#This is starter code, so that you know the basic format of this file.
#Use _ in your system labels to decrease the chance that labels in the "main"
#program will conflict

.data
.text
_syscallStart_:
    beq $v0, $0, _syscall0 #jump to syscall 0
    addi $k1, $0, 1
    beq $v0, $k1, _syscall1 #jump to syscall 1
    addi $k1, $0, 5
    beq $v0, $k1, _syscall5 #jump to syscall 5
    addi $k1, $0, 9
    beq $v0, $k1, _syscall9 #jump to syscall 9
    addi $k1, $0, 10
    beq $v0, $k1, _syscall10 #jump to syscall 10
    addi $k1, $0, 11
    beq $v0, $k1, _syscall11 #jump to syscall 11
    addi $k1, $0, 12
    beq $v0, $k1, _syscall12 #jump to syscall 12
    # Add branches to any syscalls required for your stars.

    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 # initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_ # Load end of static memory
    addi $t0, $0, -4092  # HEAP POINTER 0x3FFFF004
    sw $k1, 0($t0) # Store initial heap pointer
    j _syscallEnd_

#Print Integer
_syscall1:
    add $t0, $a0, $0            # copy integer to $t0
    beq $t0, $0, _print_zero    # special case
    slt $t1, $t0, $0            # $t2 = 1 if integer is negative
    bne $t1, $0, _negative      # branch if integer is negative

_convert:
    addi $sp, $sp, -40  # make space for 10 "words" (digits)
    add $t5, $sp, $0    # $t5 = base pointer
    add $t6, $0, $0     # $t6 = dig count

_get_digit:
    beq $t0, $0, _store_last_digit  # if quotient is zero, break loop (one more digit)

    addi $t7, $0, 10
    div $t0, $t7        # LO = quotient, HI = remainder
    mfhi $t8            # $t8 = remainder (which is digit 0-9)
    mflo $t0            # $t0 = new quotient
    
    # store ascii digit
    addi $t8, $t8, '0'
    sw $t8, 0($t5)
    addi $t5, $t5, 4 # increment base pointer
    addi $t6, $t6, 1 # increment dig count
    j _get_digit

_store_last_digit:
    # store final most-significant digit
    addi $t8, $t0, '0'
    sw $t8, 0($t5)
    addi $t5, $t5, 4
    addi $t6, $t6, 1

_print_digits:
    # print char versions of digits from back of allocated 10 digit space
    beq $t6, $0, _done_print
    addi $t5, $t5, -4   # decrement pointer to next digit
    lw $t8, 0($t5)      # read digit
    addi $t3, $0, -256
    sw $t8, 0($t3)
    addi $t6, $t6, -1   # decrement digit count
    j _print_digits

_done_print:
    # restore stack and return
    addi $sp, $sp, 40
    jr $k0

_negative:
    addi $t4, $0, '-'
    addi $t3, $0, -256
    sw $t4, 0($t3)
    sub $t0, $0, $t0    # negate integer
    j _convert

_print_zero:
    addi $t2, $0, '0'
    addi $t3, $0, -256
    sw $t2, 0($t3)
    jr $k0

#Read Integer
_syscall5:

    jr $k0

#Heap allocation
_syscall9:
    addi $t0, $0, -4092 # add heap pointer address into $t0
    lw $v0, 0($t0) # load heap pointer into $v0
    addi $t1, $v0, $a0 # allocate new space on heap
    sw $t1, 0($t0) # store updated heap pointer
    jr $k0 

#"End" the program
_syscall10:
    j _syscall10

#print character
_syscall11:
    addi $t0, $0, -256
    sw $a0, 0($t0)
    jr $k0

#read character
_syscall12:
    # load addresses
    addi $t0, $0, -236 
    addi $t1, $0, -240 
    # loop until a character is available
_pollingLoop:
    lw $t2, 0($t0) # lw from keyboard status register
    beq $t2, $0, _pollingLoop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $v0, 0($t1) # lw from keyboard data register
    jr $k0

#extra challenge syscalls go here?

_syscallEnd_: