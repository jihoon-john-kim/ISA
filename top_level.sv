module TopLevel;

    //from instr mem
    // 012_345_679
    logic [2:0] opcode; //first  3 bits {012}
    logic [2:0] rd; //2nd 3 bits {345}
    logic [2:0] rs: //3rd 3 bits {678}

    logic [5:0] addr;//last 6 bits {345_678}

    //from comtrol
    bit jump_en;
    bit writeMem_en;
    bit readMem_en;
    bit twoReg_en;

    //output from ???
    bit clk;
    bit reset;

    
    control control(
    .opcode (opcode), //in
    .jump_en (jump_en), .writeMem_en (writeMem_en), .readMem_en (readMem_en), .twoReg_en (twoReg_en), //out
    );

    //pc 
    logic[9:0] p_inc = (jump_en) ? addr : 4;
    logic[9:0] p_ct;

    pc pc(
    .clk (clk),  .reset (reset), .pc_inc (p_inc),//in
    .p_ct (p_ct) //out
    );

    logic [7:0] data_outA;
    logic [7:0] data_outB;
    logic [7:0] data_in;

    reg_file reg (
    .clk (clk), .write_en (write_en), .two_reg (twoReg_en), //in bits
    .raddrB (rd), .raddrC (rs), .writeFromMem(readMem_en), .data_in(data_in), //in

    .data_outA (data_outA), .data_outB (data_outB), //out
    );

    logic [7:0] alu_out;
    logic [7:0] mem_out;

    ALU alu(          
    .OP (opcode), .INPUT_A (data_outA), .INPUT_B (data_outB), //in
    .OUT (alu_out), //out
    );
    

    memory mem (
    .write_enable (writeMem_en), .InstAddress (addr), .InputData (data_outB), // in
    .InstrOut (mem_out) // out
    );

    data_in = (readMem_en) ? mem_out : alu_out;




endmodule