module PC_LUT1 #(parameter D=9)(
  input       [5:0] addr,	   // target 4 values
  output logic[D-1:0] target);

  always_comb case(addr)
    000000: target = 7;   // loop
	default: target = 'b0;  // hold PC  
  endcase

endmodule