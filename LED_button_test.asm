# Protocol: this device driver connects the button input device and LED output device through
# syscalls 16 and 17. When syscall 16 is called, an infinite loop will start until the button
# is pressed. Once pressed, the program will jump back to the next line where syscall 17 will
# activate the button shortly.

.data
.text
.align 2 
.globl main
main:
    # call button syscall 
    addi $v0, $0, 16
    syscall

    # the program will never reach here if the button is not pressed, so no branch is needed

    # call LED syscall
    addi $v0, $0, 17
    syscall

    # end program
    addi $v0, $zero, 10
    syscall