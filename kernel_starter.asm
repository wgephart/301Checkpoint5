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

    # dipswitch
    addi $k1, $0, 13
    beq $v0, $k1, _syscall13

    addi $k1, $0, 14
    beq $v0, $k1, _syscall14

    addi $k1, $0, 15
    beq $v0, $k1, _syscall15

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
    beq $t0, $0, _print_digits  # if quotient is zero, break loop

    addi $t7, $0, 10
    div $t0, $t7        # LO = quotient, HI = remainder
    mfhi $t8            # $t8 = remainder (which is digit 0-9)
    mflo $t0            # $t0 = new quotient
    
    # store ascii digit
    addi $t8, $t8, 48
    sw $t8, 0($t5)
    addi $t5, $t5, 4 # increment base pointer
    addi $t6, $t6, 1 # increment dig count
    j _get_digit

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
    addi $t4, $0, 45
    addi $t3, $0, -256
    sw $t4, 0($t3)
    sub $t0, $0, $t0    # negate integer
    j _convert

_print_zero:
    addi $t2, $0, 48
    addi $t3, $0, -256
    sw $t2, 0($t3)
    jr $k0

#Read Integer
_syscall5:
    add $v0, $0, $0     # initialize $v0
    addi $t1, $0, 1     # $t1 = sign (+1)

_read_loop:
    addi $t2, $0, -240  # status address
_poll:
    lw $t3, 0($t2)      # t3 = load status
    beq $t3, $0, _poll  # if $t3 == 0 (no key), loop back
    addi $t2, $0, -236  # data address
    lw $t5, 0($t2)      # read one ascii char into $t5

    # check newline
    addi $t3, $0, 10    # newline char    
    beq $t5, $t3, _end  # if $t3 char is newline, exit loop

    # check negative
    addi $t3, $0, 45
    beq $t5, $t3, _minus

    # skip non-digits
    addi $t3, $0, 48
    slt $t4, $t5, $t3           # $t4 = 1 if char < '0'
    bne $t4, $0, _read_loop     # loop if char is non-digit (< '0')
    addi $t3, $0, 57   
    slt $t4, $t3, $t5           # $t4 = 1 if char > '9'
    bne $t4, $0, _read_loop     # loop if char is non-digit (> '9')

    # process digits
    addi $t5, $t5, -48          # subtract 48 from ascii value ('0' -> '9' == 48 -> 57 ascii)
    add $t7, $v0, $0            # $t7 = old $v0
    sll $v0, $v0, 3             # $v0 = old x 8
    sll $t8, $t7, 1             # $t8 = old x 2
    add $v0, $v0, $t8           # $v0 = old x 10
    add $v0, $v0, $t5           # $v0 = old x 10 + digit
    addi $t2, $zero, -240       # address of status register
    sw $zero, 0($t2)            # store to status advance to next char
    j _read_loop                # read next char

    # process negatives
_minus:
    beq $v0, $0, _set_negative
    j _read_loop

_set_negative:
    addi $t1, $0, -1            # $t1 = sign (-1)
    j _read_loop

    # end of input
_end:
    addi $t2, $0, -240
    sw $0, 0($t2)
    addi $t2, $0, -236
    sw $0, 0($t2)

    addi $t3, $0, -1
    beq $t1, $t3, _negative_result      # if sign == -1 then negate
    jr $k0

_negative_result:
    sub $v0, $0, $v0            # $v0 = -$v0
    jr $k0

#Heap allocation
_syscall9:
    addi $t0, $0, -4092 # add heap pointer address into $t0
    lw $v0, 0($t0) # load heap pointer into $v0
    add $t1, $v0, $a0 # allocate new space on heap
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
    addi $t0, $0, -240 
    addi $t1, $0, -236
    # loop until a character is available
_pollingLoop:
    lw $t2, 0($t0) # lw from keyboard status register
    beq $t2, $0, _pollingLoop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $v0, 0($t1) # lw from keyboard data register
    sw $0, 0($t0)
    sw $0, 0($t1)
    jr $k0

#extra challenge syscalls go here?

# dipswitch: loops until a switch is flicked in the dipswitch device
_syscall13:
    #load dipswitch address
    addi $t0, $0, -168
    sw $0, 0($v0)

_dipLoop:
    lw $v0, 0($t0)
    beq $v0, $0, _dipLoop
    jr $k0

# LED bar: takes $a0 as an argument and outputs it to the LED bar device
_syscall14:
    addi $t0, $0, -160
    sw $a0, 0($t0)
    jr $k0

# Hex display
_syscall15:
    addi $v0, $0, 5
    syscall             # read integer
    
    addi $t0, $v0, 0    # $t0 = integer
    addi $t1, $0, -188
    sw $t0, 0($t1)
    jr $k0

_syscallEnd_: