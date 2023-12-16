module PC_LUT2 #(parameter D=9)(
  input       [ 1:0] addr,	   // target 4 values
  output logic[D-1:0] target);

  always_comb case(addr)
    000000: target = 7;     // loop
    000001: target = 174;   // noRecover
    000010: target = 180;   // yesRecover
    000011: target = 221;   // oIsFalse0
    000100: target = 242;   // tIsFalse0
    000101: target = 267;   // oIsFalse1
    000110: target = 290;   // fIsFalse0
    000111: target = 322;   // oIsFalse2
    001000: target = 348;   // tIsFalse1
    001001: target = 383;   // oIsFalse3
    001010: target = 423;   // eIsFalse0
    001011: target = 456;   // oIsFalse4
    001100: target = 477;   // tIsFalse2
    001101: target = 502;   // oIsFalse5
    001110: target = 525;   // fIsFalse1
    001111: target = 557;   // oIsFalse6
    010000: target = 583;   // tIsFalse3
    010001: target = 618;   // oIsFalse7
    010010: target = 658;   // insetRestBits
    010011: target = 690;   // excapeLoop
	default: target = 'b0;  // hold PC  
  endcase

endmodule