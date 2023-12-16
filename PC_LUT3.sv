module PC_LUT3 #(parameter D=9)(
  input       [ 1:0] addr,	   // target 4 values
  output logic[D-1:0] target);

  always_comb case(addr)
    000000: target = 10;     // loop
    000001: target = 30;   // skip1
    000010: target = 39;   // skip2
    000011: target = 48;   // skip3
    000100: target = 56;   // skip4
    000101: target = 61;   // skip5
    000110: target = 64;   // skip6
    000111: target = 71;   // skip7
    001000: target = 78;   // skip8
    001001: target = 85;   // skip9
    001010: target = 91;   // skip10
    001011: target = 108;   // skip11
    001100: target = 116;   // skip12
    001101: target = 125;   // skip13
    001110: target = 133;   // skip14
    001111: target = 138;   // skip15
    010000: target = 141;   // skip16
	default: target = 'b0;  // hold PC  
  endcase

endmodule