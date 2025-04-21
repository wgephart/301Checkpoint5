main:
    la $t0, frog_img           # $t0 = pointer to RGB pixel data
    addi $t1, $zero, 0         # $t1 = y = 0

outer_loop:
    addi $t2, $zero, 0         # $t2 = x = 0

inner_loop:
    lw $t3, 0($t0)             # R
    lw $t4, 4($t0)             # G
    lw $t5, 8($t0)             # B

    sll $t3, $t3, 16           # R << 16
    sll $t4, $t4, 8            # G << 8
    add $t6, $t3, $t4          # t6 = R + G
    add $t6, $t6, $t5          # t6 = R + G + B

    sw $t2, -224($zero)        # write X
    sw $t1, -220($zero)        # write Y
    sw $t6, -216($zero)        # write color
    sw $zero, -212($zero)      # trigger pixel write

    addi $t0, $t0, 12          # next pixel (3 words)
    addi $t2, $t2, 1           # x++

    addi $t7, $zero, 256       # screen width
    slt $t8, $t2, $t7          # if x < 256
    bne $t8, $zero, inner_loop

    addi $t1, $t1, 1           # y++
    slt $t8, $t1, $t7          # if y < 256
    bne $t8, $zero, outer_loop

    addi $v0, $zero, 10        # syscall 10 = exit
    syscall
