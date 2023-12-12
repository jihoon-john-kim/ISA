// Engineer: 
// 
// Create Date:    13:24:09 10/17/2016 
// Design Name: 
// Module Name:    reg_file 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 					  $clog2

import definitions::*;			  // includes package "definitions"
module reg_file #(parameter W=8, D=3)(
  input           clk,
                  two_reg,
  input  [ D-1:0] raddrB,
                  raddrC,
 //                 raddrD,
               
  input           writeFromMem,
  input  [ W-1:0] data_in,
//  input  [ W-1:0] data_in_mem,
  output logic [W-1:0] data_outA,
  output logic [W-1:0] data_outB,
  //output logic [W-1:0] data_outC,
  //output logic [W-1:0] data_outD,
//  output logic actBlockBit,
//  output logic [W-1:0]	memBlock,
// output logic [2:0] resultBlock
    );

// W bits wide [W-1:0] and 16 registers deep
logic [W-1:0] registers[16];

// combinational reads
always_comb //TODO: need to revise based on how clocking actually works
begin
  if(two_reg) 
  begin
	  data_outA = registers[raddrB];
	  data_outB = registers[raddrC];
    registers[raddrB] = data_in;
  end
  else if(writeFromMem)
    registers[0111] = data_in; //$t7
  else
  begin
    data_outA = registers[raddrB];
	  data_outB = rraddrC;
  end
//	data_outC = registers[raddrC]; //needed for SHRADD
//	data_outD = registers[raddrD]; //needed for SHRADD
//	actBlockBit = registers[rACT][0];
//	memBlock = registers[rMEM];
//	resultBlock = registers[rRES][2:0];
  

end
	
// sequential (clocked) writes
//always_ff @ (posedge clk)
//  if (write_en)
//    registers[waddr] <= (readMem) ? data_in_mem : data_in_alu;

endmodule