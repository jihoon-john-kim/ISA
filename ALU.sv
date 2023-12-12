// Engineer: 
// 
// Create Date:    2016.10.15
// Design Name: 
// Module Name:    ALU 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//   combinational (unclocked) ALU

import definitions::*;			  // includes package "definitions"
module ALU(          
  input [ 3:0] OP,				     // ALU opcode, part of microcode
  input [ 7:0] INPUT_A,			  // data inputs
               INPUT_B,

  output logic [7:0] OUT,		  // or:  output reg [7:0] OUT,
 

    );
	
	
  always_comb begin

	case(OP)
		'b011 : OUT = INPUT_A xor INPUT_B; //xor rd rs
	 	'b100 : OUT = INPUT_A + INPUT_B; // inc rd [imm]
		'b101 : OUT = INPUT_A <<<< INPUT_B; //shl
		'b110 : OUT = INPUT_A >>>> INPUT_B; //shr
		'b111 : OUT = INPUT_A and INPUT_B; //and
	endcase
	
	
	"""case(OUT)
	  16'b0 :   ZERO = 1'b1;
	  default : ZERO = 1'b0;
	endcase"""
	//$display("ALU Out %d \n",OUT);
  end

endmodule