#ifndef __PROJECT1_CPP__
#define __PROJECT1_CPP__

#include "project1.h"
#include <vector>
#include <string>
#include <unordered_map>
#include <iostream>
#include <sstream>
#include <fstream>

using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 4) // Checks that at least 3 arguments are given in command line
    {
        std::cerr << "Expected Usage:\n ./assemble infile1.asm infile2.asm ... infilek.asm staticmem_outfile.bin instructions_outfile.bin\n" << std::endl;
        exit(1);
    }
    //Prepare output files
    std::ofstream inst_outfile, static_outfile;
    static_outfile.open(argv[argc - 2], std::ios::binary);
    inst_outfile.open(argv[argc - 1], std::ios::binary);
    std::vector<std::string> instructions;

    // **** ADD MAPS FOR LABELS ****
    std::unordered_map<std::string, int> instruction_labels;
    std::unordered_map<std::string, int> static_labels;

    // **** TRACK INSTRUCTION POSITION ****
    int instruction_count = 0;
    int static_instruction_offset = 0;

    // **** INITIALIZE BOOLEAN FOR STATIC VS NON STATIC ****
    bool in_static = false;

    // **** VECTOR FOR STATIC STRINGS ****
    std::vector<std::string> static_instructions;

    /**
     * Phase 1:
     * Read all instructions, clean them of comments and whitespace DONE
     * TODO: Determine the numbers for all static memory labels
     * (measured in bytes starting at 0)
     * TODO: Determine the line numbers of all instruction line labels
     * (measured in instructions) starting at 0
    */

    //For each input file:
    for (int i = 1; i < argc - 2; i++) {
        std::ifstream infile(argv[i]); //  open the input file for reading
        if (!infile) { // if file can't be opened, need to let the user know
            std::cerr << "Error: could not open file: " << argv[i] << std::endl;
            exit(1);
        }

        std::string str;
        while (getline(infile, str)){ // Read a line from the file
            //std::cout << "Read Line: " << str << endl;  // Debug print
            str = clean(str); // remove comments, leading and trailing whitespace
            if (str == "") { //Ignore empty lines
                continue;
            }
            instructions.push_back(str); // Add instruction to list
            
            // *** CHECK IF IN STATIC PART OF FILE ****
            if (str == ".data") {
                //std::cout << "Entering .data section" << endl;  // Debug print
                in_static = true;
                continue;
            }
            if (str == ".text") {
                //std::cout << "Entering .text section" << endl;  // Debug print
                in_static = false;
                continue;
            }

            if (str == ".globl main") {
                continue;
            }

            if (str == ".align 2") {
                continue;
            }
            
            // Process static labels and instructions
            if (in_static) {
                //std::cout << "Processing static memory line: " << str << endl; // Debug
                size_t colon_pos = str.find(":");
                if (colon_pos != std::string::npos) { // Check if label is present
                    string label = str.substr(0, colon_pos); // label is everything up until colon
                    static_labels[label] = static_instruction_offset; // add to labels map and store offset (increments by 4)
                    string static_inst_str = str.substr(colon_pos + 1); // +1 to get instructions part of line (including .word or .asciiz)

                    size_t word_pos = static_inst_str.find(".word");
                    size_t asciiz_pos = static_inst_str.find(".asciiz");

                    if (word_pos != std::string::npos) {
                        static_inst_str = static_inst_str.substr(word_pos + 6); // +6 to skip .word
                        std::vector<std::string> static_terms = split(static_inst_str, WHITESPACE+",()"); // split instruction into terms (0 index is first value)

                        static_instruction_offset += (static_terms.size() * 4); // increment offset by 4 times number of values in .word
                        static_instructions.push_back(static_inst_str); // add instruction to list
                    }
                    else if (asciiz_pos != std::string::npos) {
                        static_inst_str = static_inst_str.substr(asciiz_pos + 8); // +8 to skip .asciiz
                        string stripped_str = strip_quotes(static_inst_str); // strip quotes from string
                        static_instruction_offset += (stripped_str.length() * 4); // increment offset by number of characters * 4 (4 bytes per character)
                        string ascii_decimal_str = ""; // string to hold ascii decimal values
                        for (char c : stripped_str) {
                            int ascii_val = c; // get ascii value of character
                            ascii_decimal_str += (std::to_string(ascii_val) + " "); // convert char to ascii value and add to string
                        }
                        static_inst_str = ".asciiz " + ascii_decimal_str; // update instruction string to include ascii decimal values
                        //cout << "Ascii Decimal String: " << ascii_decimal_str << endl;
                        static_instructions.push_back(static_inst_str); // add instruction to list (incldues .asciiz in str)
                    } 
                    
                    //std::cout << "Static Label: " << label << " -> Address: " << static_labels[label] << endl;
                    //std::cout << "Static Instruction Offset: " << static_instruction_offset << endl;
                }
            }
            // Process instruction labels
            else {
                //std::cout << "Processing instruction line: " << str << endl; // Debug
                size_t colon_pos = str.find(":");
                if (colon_pos != std::string::npos) { // Check if label is present
                    string label = str.substr(0, colon_pos); // label is everything up until colon
                    instruction_labels[label] = instruction_count; // add to labels map and store instruction count
                    //std::cout << "Instruction Label: " << label << " -> Line: " << instruction_labels[label] << endl;
                    instruction_count--; // decrement instruction count
                }
                instruction_count++; // increment instruction count
                continue;
            }
        }
        infile.close(); // Close the file
    }

    static_labels["_END_OF_STATIC_MEMORY_"] = static_instruction_offset;

    //cout << "Instructions collected: " << endl;
    for (const auto& instr : instructions) {
        //cout << instr << endl;
    }

    //cout << "Static instructions collected: " << endl;
    for (const auto& s_instr : static_instructions) {
        //cout << s_instr << endl;
    }


    // Debug: Print label mappings
    for (const auto& pair : instruction_labels) {
        //cout << "Instruction Label: " << pair.first << " -> Line " << pair.second << endl;
    }
    for (const auto& pair : static_labels) {
        cout << "Static Label: " << pair.first << " -> Address " << pair.second << endl;
    }
    


    /** Phase 2
     * Process all static memory, output to static memory file
     * TODO: All of this
     */
    int static_memory_value;
    for (std::string inst : static_instructions) {
        std::vector<std::string> terms = split(inst, WHITESPACE+",()");
        for (int i = 0; i < terms.size(); i++) { //change to index 1 to skip over .word or .asciiz
            if (std::all_of(terms[i].begin(), terms[i].end(), ::isdigit)) { // from std documentation
                cout << "static memory terms[i] = " << terms[i] << endl;
                static_memory_value = stoi(terms[i]);
            }
            else {
                static_memory_value = instruction_labels[terms[i]] * 4;
            }
            write_binary(static_memory_value, static_outfile);
            //cout << "Writing to static memory: " << static_memory_value << endl;
        }
    }


    /** Phase 3
     * Process all instructions, output to instruction memory file
     * TODO: Almost all of this, it only works for adds
     */
    

    // before looping throught the instructions vector we need to clear it of all lines that are not instructions
    // this allows for our branch instructions to work properly
    removeNonInstructionLines(instructions);

     for (int i = 0; i < instructions.size(); i++) {
        std::vector<std::string> terms = split(instructions[i], WHITESPACE+",()");
        std::string inst_type = terms[0];
        std::string instruction = terms[0];
        
        //std::cout << "Line " << i << ": " << instructions[i] << std::endl;

        //*** R type instructions 
    if (inst_type == "jr") {
        int result = encode_Rtype(0, registers[terms[1]], 0, 0, 0, 8);
        write_binary(result, inst_outfile);
    }

    if (inst_type == "jalr") {
        // two term jalr that stores the second term from the command into rd
        if (terms.size() > 2) {
            int result = encode_Rtype(0, registers[terms[1]], 0, registers[terms[2]], 0, 9);
            write_binary(result, inst_outfile);
        }

        // one term jalr that stores ra into rd
        int result = encode_Rtype(0, registers[terms[1]], 0, 31, 0, 9); // ra's address is 31
        write_binary(result, inst_outfile);
    }

        // if R type 3 registers
        if(inst_type == "add" || inst_type == "and" || inst_type == "sub" ||
        inst_type == "or" || inst_type == "nor" || inst_type == "xor" || inst_type == "slt") {
            int rd = registers[terms[1]];
            int rs = registers[terms[2]];
            int rt = registers[terms[3]];

            int result = processRType3(instruction, rs, rt, rd);
            write_binary(result, inst_outfile);
        }

        // if R type 2 registers
        if(inst_type == "mult" || inst_type == "div") {
            int rs = registers[terms[1]];
            int rt = registers[terms[2]];

            int result = processRType2(instruction, rs, rt);
            write_binary(result, inst_outfile);
        }
        
        // if R type 1 register
        if(inst_type == "mflo" || inst_type == "mfhi") {
            int rd = registers[terms[1]];

            int result = processRType1(instruction, rd);
            write_binary(result, inst_outfile);
        }
        
        // if R type shift 
        if (inst_type == "sll" || inst_type == "srl") {
            int rd = registers[terms[1]];
            int rs = registers[terms[2]];
            cout << "sll srl terms[3] = " << terms[3] << endl;
            int shamt = std::stoi(terms[3]);

            int result = processRTypeShift(instruction, rd, rs, shamt);
            write_binary(result, inst_outfile);
        }

    
        // *** I type instructions ***
        if (inst_type == "addi") {
            cout << "addi terms[3] = " << terms[3] << endl;
            int imm = std::stoi(terms[3]);
            // check if immediate is too large
            if (imm > 0xFFFF || imm < -0x8000) {
                int temp_register = handleLargeImmediate(imm, inst_outfile);
                // convert to add
                int add_result = encode_Rtype(0, registers[terms[2]], temp_register, registers[terms[1]], 0, 32);
                write_binary(add_result, inst_outfile);
            }
            else {
                int result = encode_Itype(8, registers[terms[2]], registers[terms[1]], imm & 0xFFFF);
                write_binary(result, inst_outfile);
            }
        }

        if (inst_type == "lw") {
            cout << "lw terms[2] = " << terms[2] << endl;
            int imm = std::stoi(terms[2]);
            int result = encode_Itype(35, registers[terms[3]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        if (inst_type == "sw") {
            cout << "sw terms[2] = " << terms[2] << endl;
            int imm = std::stoi(terms[2]);
            int result = encode_Itype(43, registers[terms[3]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        if (inst_type == "la") {
            std::string label = terms[2];
            int term = static_labels[label];
            int result = encode_Itype(8, 0, registers[terms[1]], term);
            write_binary(result, inst_outfile);
        }

        // **** instructions for stars *****
        if (inst_type == "andi"){
            int imm = std::stoi(terms[3]);
            int result = encode_Itype(12, registers[terms[2]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }
        
        if (inst_type == "ori"){
            cout << "ori terms[3] = " << terms[3] << endl;
            int imm = std::stoi(terms[3]);
            int result = encode_Itype(13, registers[terms[2]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        if (inst_type == "xori"){
            int imm = std::stoi(terms[3]);
            int result = encode_Itype(14, registers[terms[2]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }
        
        if (inst_type == "lui"){
            cout << "lui terms[3] = " << terms[3] << endl;
            int imm = std::stoi(terms[3]);
            int result = encode_Itype(15, registers[terms[2]], registers[terms[1]], imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }
        if (inst_type == "beq"){
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i+1);
            int result = encode_Itype(4, registers[terms[1]], registers[terms[2]], offset & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        if (inst_type == "bne"){
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i+1);
            int result = encode_Itype(5, registers[terms[1]], registers[terms[2]], offset & 0xFFFF);
            write_binary(result, inst_outfile);
        }

            // *** J type instructions ***
        if (inst_type == "j"){
            int result = encode_Jtype(2, instruction_labels[terms[1]]);
            write_binary(result, inst_outfile);
        }

        if (inst_type == "jal"){
            int result = encode_Jtype(3, instruction_labels[terms[1]]);
            write_binary(result, inst_outfile);
        }

        // syscall
        if (inst_type == "syscall"){
            write_binary(53260, inst_outfile);
        }


        // **** psuedoinstructions ****

        // move: mov $t0, $t1 –> copies value from one register to another, in this case copying $t1 to $t0
        // implementation:
        // add $t0, $t1, $0 –> adds contents of $t1 + 0, storing result in $t0
        if (inst_type == "mov") {
            int result = encode_Rtype(0, registers[terms[2]], 0, registers[terms[1]], 0, 32);
            write_binary(result, inst_outfile);
        }

        // load immediate: li $t0, 10 –> loads the immediate, 10, into $t0
        // implementation:
        // addi $t0, $0, 10 –> this will effectively add the same immediate into $t0 also
        if (inst_type == "li") {
            cout << "li terms[2] = " << terms[2] << endl;
            int imm = std::stoi(terms[2]);
            int result = encode_Itype(8, registers[terms[1]], 0, imm & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        // set if greater than or equal: sge $t0, $s0, $s1 –> $t0 = 1 if $s0 >= $s1, $t0 = 0 otherwise
        // implementation:
        // slt $t0, $s0, $s1     –> $t0 = 1 if $s0 < $s1, $t0 = 0 if $s0 >= $s1
        // xori $t0, $t0, 1      –> xori will make $t0 = 1 if it equals 0. So, $t0 = 1 if $s0 >= $s1, $t0 = 0 otherwise
        if (inst_type == "sge") {
            int result1 = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 42);
            write_binary(result1, inst_outfile);
            int result2 = encode_Itype(14, registers[terms[1]], registers[terms[1]], 1 & 0xFFFF);
            write_binary(result2, inst_outfile);
        }

        // set if greater than: sgt $t0, $s0, $s1 –> $t0 = 1 if $s0 > $s1, $t0 = 0 otherwise
        // implementation:
        // slt $t0, $s1, $s0     –> $t0 = 1 if $s1 < $s0, $t0 = 0 if $s1 >= $s0
        if (inst_type == "sgt") {
            int result = encode_Rtype(0, registers[terms[2]], registers[terms[1]], registers[terms[3]], 0, 42);
            write_binary(result, inst_outfile);
        }

        // set if less than or equal: sle $t0, $s0, $s1 –> $t0 = 1 if $s0 <= $s1, $t0 = 0 otherwise
        // implementation:
        // slt $t0, $s1, $s0     –> $t0 = 1 if $s1 < $s0, $t0 = 0 if $s0 <= $s1
        // xori $t0, $t0, 1      –> xori will make $t0 = 1 if it initially equals 0. So, $t0 = 1 if $s0 <= $s1, $t0 = 0 otherwise
        if (inst_type == "sle") {
            int result1 = encode_Rtype(0, registers[terms[3]], registers[terms[2]], registers[terms[1]], 0, 42);
            write_binary(result1, inst_outfile);
            int result2 = encode_Itype(14, registers[terms[1]], registers[terms[1]], 1 & 0xFFFF);
            write_binary(result2, inst_outfile);
        }

        // set if equal: seq $t0, $s0, $s1 -> $t0 = 1 if $t1 == $t2, $t0 = 0 otherwise
        // implementation:
        // xor $t0, $s0, $s1    # $t0 = 0 if $s0 == $s1
        // xori $t0, $t0, 1     # xori will make $t0 = 1 if it initially equals 0. So, $t0 = 1 if $s0 == $s1, $t0 = 0 otherwise
        if (inst_type == "seq") {
            int result1 = encode_Rtype(0, registers[terms[2]], registers[terms[3]], registers[terms[1]], 0, 38);
            write_binary(result1, inst_outfile);
            int result2 = encode_Itype(14, registers[terms[1]], registers[terms[1]], 1 & 0xFFFF);
            write_binary(result2, inst_outfile);
        }

        // branch if greater than or equal: bge $s0, $s1, label –> if $s0 >= $s1, branch to label
        // implementation:
        // slt $t0, $s0, $s1      # $t0 = 1 if $s0 < $s1, otherwise $t0 = 0
        // beq $t0, $zero, label  # if $t0 == 0 then $s0 >= $s1 then branch
        if (inst_type == "bge") {
            int result1 = encode_Rtype(0, registers[terms[1]], registers[terms[2]], registers["t0"], 0, 42);
            write_binary(result1, inst_outfile);
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i+1);
            int result = encode_Itype(4, registers["t0"], 0, offset & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        // branch if greater than: bgt $s0, $s1, label –> if $s0 > $s1, branch to label
        // implementation:
        // slt $t0, $s1, $s0      # $t0 = 1 if $s0 > $s1, otherwise $t0 = 0
        // bne $t0, $zero, label  # if $t0 == 1 then $s0 > $s1 then branch
        if (inst_type == "bgt") {
            int result1 = encode_Rtype(0, registers[terms[2]], registers[terms[1]], registers["t0"], 0, 42);
            write_binary(result1, inst_outfile);
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i + 1);
            int result = encode_Itype(5, registers["t0"], 0, offset & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        // branch if less than or equal: ble $s0, $s1, label –> if $s0 <= $s1 then branch to label
        // implementation:
        // slt $t0, $s1, $s0    –> $t0 = 1 if $s1 < $s0, otherwise $t0 = 0
        // beq $t0, $0, label   –> if $t0 == 0 then $s0 <= $s1 then branch
        if (inst_type == "ble") {
            int result1 = encode_Rtype(0, registers[terms[2]], registers[terms[1]], registers["t0"], 0, 42);
            write_binary(result1, inst_outfile);
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i + 1);
            int result = encode_Itype(4, registers["t0"], 0, offset & 0xFFFF);
            write_binary(result, inst_outfile);
        }

        // branch if less than: blt $s0, $s1, label –> if $s0 < $s1 then branch to label
        // implementation:
        // slt $t0, $s0, $s1    –> $t0 = 1 if $s0 < $s1, otherwise $t0 = 0
        // bne $t0, $0, label   –> if $t0 == 1 then $s0 < $s1 then branch
        if (inst_type == "blt") {
            int result1 = encode_Rtype(0, registers[terms[1]], registers[terms[2]], registers["t0"], 0, 42);
            write_binary(result1, inst_outfile);
            int label_line = instruction_labels[terms[3]];
            int offset = label_line - (i + 1);
            int result2 = encode_Itype(5, registers["t0"], 0, offset & 0xFFFF);
            write_binary(result2, inst_outfile);
        }
        

        // absolute value: abs $s1, $s0 –> take the absolute value of s0 and store in s1
        // implementation:
        // slt   $t0, $s0, $zero        –> if $s0 < 0 then $t0 is
        // sub   $t0, $zero, $t0        –> if $t0 == 1, then $t0 becomes -1 which is a bit string of all 1s, otherwise $t0 will remain 0
        // xor   $s1, $s0, $t0          –> if $s0 negative, then $t0 is all 1s, so store all 0s in $s0 as 1s in $s1; this is like flipping the bit when converting a number from negative to positive
        // sub   $s1, $s1, $t0          –> add -1 after flipping the bit
        if (inst_type == "abs"){
            int result1 = encode_Rtype(0, registers[terms[2]], 0, registers["t0"], 0, 42);
            write_binary(result1, inst_outfile);
            int result2 = encode_Rtype(0, 0, registers["t0"], registers["t0"], 0, 34);
            write_binary(result2, inst_outfile);
            int result3 = encode_Rtype(0, registers[terms[2]], registers["t0"], registers[terms[1]], 0, 38);
            write_binary(result3, inst_outfile);
            int result4 = encode_Rtype(0, registers[terms[1]], registers["t0"], registers[terms[1]], 0, 34);
            write_binary(result4, inst_outfile);
        }

    }
}

#endif
