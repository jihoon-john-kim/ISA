module ALU(          
  input [ 3:0] OP,				     // ALU opcode, part of microcode
  input [ 7:0] INPUT_A,			  // data inputs
               INPUT_B,
  output logic [7:0] OUT		  // or:  output reg [7:0] OUT,
 );
	
  always_comb begin
	case(OP)
		'b011 : OUT = INPUT_A ^ INPUT_B; //xor rd rs
	 	'b100 : OUT = INPUT_A + INPUT_B; // inc rd [imm]
		'b101 : OUT = INPUT_A << INPUT_B; //shl
		'b110 : OUT = INPUT_A >>> INPUT_B; //shr
		'b111 : OUT = INPUT_A & INPUT_B; //and
	endcase
  end

endmodule