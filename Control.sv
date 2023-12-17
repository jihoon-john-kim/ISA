module control (
input [2:0] opcode,

output logic jump_en,
output logic writeMem_en,
output logic readMem_en,
output logic twoReg_en

);

always_comb begin
    jump_en = 0;
    writeMem_en = 0;
    readMem_en = 0;
    twoReg_en = 0;
   
	case(opcode)
        'b000 : readMem_en = 1;//lw 
        'b001 : writeMem_en = 1;//sw
        'b010 : jump_en = 1;//bnez
		'b011 : twoReg_en = 1; //xor rd rs
	 	'b100 : ; // inc rd [imm]
		'b101 : ; //shl
		'b110 : ; //shr
		'b111 : twoReg_en = 1;//and
	endcase
	
end


endmodule

