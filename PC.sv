// program counter example
module pc (
  input	clk,
  input reset,
  input branch_enable,

  input [9:0] target;
   
  """input ZERO,					//STATUS flags
  input LESS,
  
  input REG_JMP,				//JMP activated flags
  input ZERO_JMP,						
  input LESS_JMP,
  input MAGIC_JMP,
  input E_JMP_ACTIVE,
  input E_JMP_READY,
  input [5:0] JMP_DIST,
  input [1:0] MAGIC,"""
  
  output logic[9:0] p_ct);

  always_ff @(posedge clk) 
		if(reset)
			p_ct <= 0;
	"""	else if (MAGIC_JMP)
			p_ct <= p_ct + {MAGIC, 1'b1};
		else if (E_JMP_ACTIVE & E_JMP_READY)
			p_ct <= p_ct + 2'b10;"""
    else if (branch_enable)
      p_ct <= target;
		else
			p_ct <= p_ct + 4;//((REG_JMP | (ZERO & ZERO_JMP) | (LESS & LESS_JMP)) ? {JMP_DIST[5], JMP_DIST[5], JMP_DIST[5], JMP_DIST[5], JMP_DIST} : 1'b1); 
			
endmodule