module reg_file #(parameter W=8, D=3)(
  input           clk,
                  two_reg,
  input  [ D-1:0] raddrB,
                  raddrC,               
  input           writeFromMem,
  input  [ W-1:0] data_in,
  output logic [W-1:0] data_outA,
  output logic [W-1:0] data_outB
    );

logic [W-1:0] registers[16];
  
always_comb 
begin
  if(two_reg) 
  begin
	  data_outA = registers[raddrB];
	  data_outB = registers[raddrC];
  end
 
  else
  begin
    data_outA = registers[raddrB];
	  data_outB = raddrC;
  end
end
	
always_ff @ (posedge clk)
  if(writeFromMem)
    registers[111] = data_in; 
  else
    registers[raddrB] = data_in;
endmodule