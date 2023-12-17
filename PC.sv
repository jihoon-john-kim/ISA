module pc (
  input	clk,
  input reset,
  input branch_enable,

  input [9:0] target,  
  output logic[9:0] p_ct);

  always_ff @(posedge clk) 
		if(reset)
			p_ct <= 0;
    	else if (branch_enable)
      		p_ct <= target;
		else
			p_ct <= p_ct + 4;
			
endmodule