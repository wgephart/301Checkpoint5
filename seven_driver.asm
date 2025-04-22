.text
.globl main

main:
    addi $sp, $0, -4096

    addi $s0, $0, -240 # keyboard status 
    addi $s1, $0, -236 # keyboard data 
    addi $s2, $0, -192 # seven segment display output

    loop:
        
    # Poll keyboard status
        lw $t0, 0($s0)          # load keyboard status (0 or 1)
        beq $t0, $zero, loop    # if no key pressed, loop

        # Read key from keyboard data register
        lw $t1, 0($s1)          # get key value

        # Print to seven segment display
        sw $t1, 0($s2)

        # Tell keyboard to increment to next keypress
        add $t2, $0, $0               # value doesn't matter
        sw $t2, 0($s0)

        j loop
