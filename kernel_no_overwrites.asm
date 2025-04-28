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

    # print string
    addi $k1, $0, 4
    beq $v0, $k1, _syscall4

    # read string
    addi $k1, $0, 8
    beq $v0, $k1, _syscall8
    
    # dipswitch
    addi $k1, $0, 13
    beq $v0, $k1, _syscall13

    # led bar
    addi $k1, $0, 14
    beq $v0, $k1, _syscall14

    # hex display
    addi $k1, $0, 15
    beq $v0, $k1, _syscall15

    # button
    addi $k1, $0, 16
    beq $v0, $k1, _syscall16
    
    # led
    addi $k1, $0, 17
    beq $v0, $k1, _syscall17

    # seven segment display
    addi $k1, $0, 19
    beq $v0, $k1, _syscall19 

    # led matrix
    addi $k1, $0, 20
    beq $v0, $k1, _syscall20

    # joystick
    addi $k1, $0, 21
    beq $v0, $k1, _syscall21

    #Error state - this should never happen - treat it like an end program
    j _syscall10

#Do init stuff
_syscall0:
    addi $sp, $0, -4096 # initialize stack pointer
    la $k1, _END_OF_STATIC_MEMORY_ # Load end of static memory
    sw $k1, -4092($0) # Store initial heap pointer (0x3FFFF004)
    j _syscallEnd_

#Print Integer
_syscall1:
    addi $sp, $sp, -36 # allocate stack space for saving $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    sw $t7, 28($sp)
    sw $t8, 32($sp)

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

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $t8, 32($sp)
    addi $sp, $sp, 36

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

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $t8, 32($sp)
    addi $sp, $sp, 36 # restore stack space

    jr $k0

#Read Integer
_syscall5:
    addi $sp, $sp, -36 # allocate stack space for saving $t registers
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    sw $t7, 28($sp)
    sw $t8, 32($sp)

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
    slt $t4, $t5, $t3           # $t4 = 1 if char < 0 / ascii 48
    bne $t4, $0, _read_loop     # loop if char is non-digit / ascii < 48
    addi $t3, $0, 57   
    slt $t4, $t3, $t5           # $t4 = 1 if char > 9 / ascii 57
    bne $t4, $0, _read_loop     # loop if char is non-digit / ascii > 57

    # process digits
    addi $t5, $t5, -48          # subtract 48 from ascii value 
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
    addi $t1, $0, -1            
    j _read_loop

    # end of input
_end:
    addi $t2, $0, -240
    sw $0, 0($t2)
    addi $t2, $0, -236
    sw $0, 0($t2)

    addi $t3, $0, -1
    beq $t1, $t3, _negative_result      # if sign == -1 then negate

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $t8, 32($sp)
    addi $sp, $sp, 36 # restore stack space

    jr $k0

_negative_result:
    sub $v0, $0, $v0            # $v0 = -$v0

    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $t8, 32($sp)
    addi $sp, $sp, 36 # restore stack space 

    jr $k0

#Heap allocation
_syscall9:
    addi $sp, $sp, -4
    sw $t1, 0($sp)

    lw $v0, -4092($0) # load heap pointer into $v0
    add $t1, $v0, $a0 # allocate new space on heap
    sw $t1, -4092($0) # store updated heap pointer

    lw $t1, 0($sp)
    addi $sp, $sp, 4
    jr $k0 

#"End" the program
_syscall10:
    j _syscall10

#print character
_syscall11:
    sw $a0, -256($0)
    jr $k0

#read character
_syscall12:
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    # loop until a character is available
_pollingLoop:
    lw $t0, -240($0) # lw from keyboard status register
    beq $t0, $0, _pollingLoop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $v0, -236($0) # lw from keyboard data register
    sw $0, -240($0) # clear status

    lw $t0, 0($sp)
    addi $sp, $sp, 4
    jr $k0

#extra challenge syscalls

# print string: prints a string to the terminal from static memory character by character
_syscall4: 
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $t1, 4($sp)

    add $t0, $a0, $0        # copy string start address to $t1
    addi $t0, $t0, 4        # add 4 to skip null string at the beginning
    
_print_char_loop:
    lw $t1, 0($t0)          
    beq $t1, $0, _end_print_string  # exit if string is 00000000
    sw $t1, -256($0)           
    addi $t0, $t0, 4         # move to next character
    j _print_char_loop

_end_print_string:
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    addi $sp, $sp, 8
    jr $k0


_syscall8:
    # allocate space and store temp variables
    addi $sp, $sp, -40
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $t2, 8($sp)
    sw $t3, 12($sp)
    sw $t4, 16($sp)
    sw $t5, 20($sp)
    sw $t6, 24($sp)
    sw $t7, 28($sp)
    sw $t8, 32($sp)
    sw $t9, 36($sp)

    # load addresses
    addi $t0, $0, -240 
    addi $t1, $0, -236

    # allocate space for 25 characters 
    addi $sp, $sp, -100

    # $t3 = stack address for string
    add $t3, $sp, $0 
    
    # Initialize character counter
    add $t5, $0, $0     # $t5 will count characters read
    add $t6, $t3, $0    # $t6 will keep original stack pointer

    # temp store loop
    _store_char_loop:
    lw $t2, 0($t0)      # lw from keyboard status register
    beq $t2, $0, _store_char_loop  # if status is 0 then no character is available - loop again
    # when character is available read it
    lw $t4, 0($t1)      # lw from keyboard data register
    sw $0, 0($t0)       # Reset keyboard status
    sw $0, 0($t1)       # Reset keyboard data
    
    # Check if character is newline (ASCII 10)
    addi $t7, $0, 10    # $t7 = newline character
    beq $t4, $t7, _end_read_string
    
    sw $t4, 0($t3)      # store character on the stack
    # increase offset
    addi $t3, $t3, 4
    addi $t5, $t5, 1    # increment character counter
    j _store_char_loop

    _end_read_string:
    # Calculate size needed for heap allocation (characters * 4 + 4 for null terminator)
    addi $t7, $t5, 1    # Add 1 for null terminator
    sll $t7, $t7, 2     # Multiply by 4 (assuming word storage)
    
    # Load heap pointer address
    addi $k1, $0, -4092
    lw $t8, 0($k1)      # Get current heap pointer
    
    # Store original heap pointer to return in $v0
    add $v0, $t8, $0
    
    # Copy characters from stack to heap
    add $t3, $t6, $0    # Reset to beginning of stack buffer
    add $t9, $t8, $0    # $t9 = current position in heap
    
    # Copy loop
    addi $t2, $0, 0     # Initialize counter
    _copy_loop:
        beq $t2, $t5, _add_null_terminator  # If we've copied all chars, add null terminator
        
        lw $t4, 0($t3)  # Load word from stack
        sw $t4, 0($t9)  # Store word to heap
        
        addi $t3, $t3, 4  # Increment stack pointer
        addi $t9, $t9, 4  # Increment heap pointer
        addi $t2, $t2, 1  # Increment counter
        j _copy_loop
    
    _add_null_terminator:
        sw $0, 0($t9)   # Store null terminator
        
        # Update heap pointer (add size to current heap pointer)
        add $t8, $t8, $t7
        sw $t8, 0($k1)  # Store updated heap pointer
    
    # Deallocate stack space for string
    addi $sp, $sp, 100
    
    # Restore temp variables
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $t2, 8($sp)
    lw $t3, 12($sp)
    lw $t4, 16($sp)
    lw $t5, 20($sp)
    lw $t6, 24($sp)
    lw $t7, 28($sp)
    lw $t8, 32($sp)
    lw $t9, 36($sp)
    addi $sp, $sp, 40
    
    jr $k0

# dipswitch: loops until a switch is flicked in the dipswitch device
_syscall13:
# dip loop will loop until a switch is triggered
_dipLoop:
    lw $v0, -168($0)          # load from dipswitch register
    beq $v0, $0, _dipLoop   # if value in dipswitch register is still 0, then no switch has been flipped -- loop again
    jr $k0

# LED bar: takes $a0 as an argument and outputs it to the LED bar device
_syscall14:
    sw $a0, -160($0)          # store argument in LED bar address
    jr $k0

# Hex display: reads from keyboard and sends input to the hex display device
_syscall15:
    # store return register
    addi $sp, $sp, -4
    sw $k0, 0($sp)

    addi $v0, $0, 5
    syscall             # read integer
    sw $v0, -188($0)    # store keyboard-read hex value to the display

    # load return address
    lw $k0, 0($sp)
    addi $sp, $sp, 4

    jr $k0

# button: loops until the button is pressed 
_syscall16:
_buttonLoop:
    lw $v0, -164($0)          # load from button register
    beq $v0, $0, _buttonLoop    # will loop until the value in $v0 is not 0
    jr $k0


# LED: activates button, takes no argument 
_syscall17:
    sw $0, -248($0)       # turn on device
    jr $k0

# seven segment display
_syscall19: 
    addi $sp, $sp, -16
    sw $t2, 0($sp)
    sw $t4, 4($sp)
    sw $t5, 8($sp)
    sw $t6, 12($sp)

    # store return address on stack before syscall 5
    addi $sp, $sp, -4
    sw $k0, 0($sp)

    addi $v0, $0, 5
    syscall             # read integer from keyboard using syscall 5

    addi $t2, $0, -192 # seven segment display output address

    add $t4, $0, $v0    # set $t4 to the integer from the keyboard

    # determine which number to make
    beq $t4, $0, _make_zero
    addi $t5, $0, 1
    beq $t4, $t5, _make_one
    addi $t5, $0, 2
    beq $t4, $t5, _make_two
    addi $t5, $0, 3
    beq $t4, $t5, _make_three
    addi $t5, $0, 4
    beq $t4, $t5, _make_four
    addi $t5, $0, 5
    beq $t4, $t5, _make_five
    addi $t5, $0, 6
    beq $t4, $t5, _make_six
    addi $t5, $0, 7
    beq $t4, $t5, _make_seven
    addi $t5, $0, 8
    beq $t4, $t5, _make_eight
    addi $t5, $0, 9
    beq $t4, $t5, _make_nine

    _make_zero:
        addi $t6, $0, 63
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_one:
        addi $t6, $0, 48
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_two:
        addi $t6, $0, 91
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_three:
        addi $t6, $0, 79
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_four:
        addi $t6, $0, 102
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_five:
        addi $t6, $0, 109
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_six:
        addi $t6, $0, 125
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_seven:
        addi $t6, $0, 7
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_eight:
        addi $t6, $0, 127
        sw $t6, 0($t2)
        j _end_seven_segment

    _make_nine:
        addi $t6, $0, 111
        sw $t6, 0($t2)
        j _end_seven_segment

    _end_seven_segment:
        lw $k0, 0($sp)
        addi $sp, $sp, 4
        lw $t2, 0($sp)
        lw $t4, 4($sp)
        lw $t5, 8($sp)
        lw $t6, 12($sp)
        addi $sp, $sp, 16
        jr $k0

# LED matrix: takes $a0 as an input and displays corresponding LED squares on the 8x4 matrix
_syscall20:
    sw $a0, -200($0)
    jr $k0

# Joystick
_syscall21:
    lw $v0, -176($0) # x data
    lw $v1, -172($0) # y data
    jr $k0

_syscallEnd_: