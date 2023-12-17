module memory #(parameter A=6, W=8) (
  input               clk,
  input               write_enable,
  input       [A-1:0] InstAddress,
  input       [W-1:0] InputData,
  output logic[W-1:0] InstrOut);
	 
  logic[W-1:0] inst_rom[64];
    
  always_comb
  begin
    InstrOut = inst_rom[InstAddress];
  end

  always_ff @ (posedge clk)
  if(write_enable)
      inst_rom[InstAddress] = InputData;

endmodule