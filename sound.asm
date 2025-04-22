.text
.globl main

main:
    # Setup channels
    
    # Channel 0 - Square wave melody
    addi $a0, $0, 1             # Command: Set volume
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 255           # Max volume
    jal sound_syscall
    
    addi $a0, $0, 2             # Command: Set waveform
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 0             # Square wave (00)
    jal sound_syscall
    
    # Channel 1 - Triangle wave bass
    addi $a0, $0, 1             # Command: Set volume
    addi $a1, $0, 1             # Channel 1
    addi $a2, $0, 180           # 70% volume
    jal sound_syscall
    
    addi $a0, $0, 2             # Command: Set waveform
    addi $a1, $0, 1             # Channel 1
    addi $a2, $0, 1             # Triangle wave (01)
    jal sound_syscall
    
    # Channel 2 - Percussion (noise)
    addi $a0, $0, 1             # Command: Set volume
    addi $a1, $0, 2             # Channel 2
    addi $a2, $0, 128           # 50% volume
    jal sound_syscall
    
    addi $a0, $0, 2             # Command: Set waveform
    addi $a1, $0, 2             # Channel 2
    addi $a2, $0, 3             # Noise waveform (11)
    jal sound_syscall
    
    # Play Mario theme first part
    
    # Note 1: E5
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 659           # E5 (659 Hz)
    jal sound_syscall
    
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 1             # Enable
    jal sound_syscall
    
    # Delay
    addi $t0, $0, 100000
delay1:
    addi $t0, $t0, -1
    bne $t0, $0, delay1        # Replaced bnez with bne
    
    # Note 2: E5 (repeat)
    # Same frequency, already set
    
    # Delay
    addi $t0, $0, 100000
delay2:
    addi $t0, $t0, -1
    bne $t0, $0, delay2        # Replaced bnez with bne
    
    # Pause
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 0             # Disable
    jal sound_syscall
    
    # Short delay for pause
    addi $t0, $0, 50000
delay3:
    addi $t0, $t0, -1
    bne $t0, $0, delay3        # Replaced bnez with bne
    
    # Note 3: E5 (after pause)
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 1             # Enable
    jal sound_syscall
    
    # Delay
    addi $t0, $0, 100000
delay4:
    addi $t0, $t0, -1
    bne $t0, $0, delay4        # Replaced bnez with bne
    
    # Note 4: C5
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 523           # C5 (523 Hz)
    jal sound_syscall
    
    # Delay
    addi $t0, $0, 100000
delay5:
    addi $t0, $t0, -1
    bne $t0, $0, delay5        # Replaced bnez with bne
    
    # Note 5: E5
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 659           # E5 (659 Hz)
    jal sound_syscall
    
    # Delay
    addi $t0, $0, 100000
delay6:
    addi $t0, $t0, -1
    bne $t0, $0, delay6        # Replaced bnez with bne
    
    # Note 6: G5 with bass and percussion
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 784           # G5 (784 Hz)
    jal sound_syscall
    
    # Add bass on channel 1
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 1             # Channel 1
    addi $a2, $0, 392           # G4 (one octave below)
    jal sound_syscall
    
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 1             # Channel 1
    addi $a2, $0, 1             # Enable
    jal sound_syscall
    
    # Add percussion on channel 2
    addi $a0, $0, 0             # Command: Set frequency
    addi $a1, $0, 2             # Channel 2
    addi $a2, $0, 100           # Arbitrary frequency for noise
    jal sound_syscall
    
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 2             # Channel 2
    addi $a2, $0, 1             # Enable
    jal sound_syscall
    
    # Longer delay for final chord
    addi $t0, $0, 200000
delay7:
    addi $t0, $t0, -1
    bne $t0, $0, delay7        # Replaced bnez with bne
    
    # Disable all channels
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 0             # Channel 0
    addi $a2, $0, 0             # Disable
    jal sound_syscall
    
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 1             # Channel 1
    addi $a2, $0, 0             # Disable
    jal sound_syscall
    
    addi $a0, $0, 3             # Command: Enable/disable
    addi $a1, $0, 2             # Channel 2
    addi $a2, $0, 0             # Disable
    jal sound_syscall
    
exit:
    j exit                # Loop forever
