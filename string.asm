.data
string_msg: .asciiz "Hello."

.text
la $a0, string_msg  # Load address of 4-byte-per-char string
addi $v0, $0, 4          # Syscall 4 code
syscall