// Create Date:    2017.01.25 
// Design Name: 
// Module Name:    InstROM 
// Description: Verilog module -- instruction ROM 	
//
module instr_ROM #(parameter A=6, W=8) (
  input               write_enable,
  input       [A-1:0] InstAddress,
  input       [W-1:0] InputData,
  output logic[W-1:0] InstrOut);
	 
// need $readmemh or $readmemb to initialize all of the elements
// declare ROM array
  logic[W-1:0] inst_rom[64;
    
// read from it
  always_comb
  begin
    InstrOut = inst_rom[InstAddress];

    if(write_enable)
      inst_rom[InstAddress] = InputData;
  end

endmodule