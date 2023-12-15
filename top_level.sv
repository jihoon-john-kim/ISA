module TopLevel (

    input logic clk,
    input logic reset,

    output done
);

    //from instr mem
    // 876_543_210
    logic [8:0] mach_code;

    logic [2:0] opcode; //first  3 bits {876}
    logic [2:0] rd; //2nd 3 bits {543}
    logic [2:0] rs; //3rd 3 bits {210}

    logic [5:0] addr;//last 6 bits {543_210}

    //from comtrol
    logic jump_en;
    logic writeMem_en;
    logic readMem_en;
    logic twoReg_en;
    
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

    instr_ROM rom(
        .prog_ctr(p_ct),    // in
        .mach_code(mach_code) // out
    );

    //mach_code data handling
    assign opcode = mach_code[8:6]; 
    assign rd = mach_code[5:2];
    assign rs = mach_code[2:0];
    assign addr = mach_code[5:0];


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
    .clk (clk), .write_enable (writeMem_en), .InstAddress (addr), .InputData (data_outB), // in
    .InstrOut (mem_out) // out
    );

    assign data_in = (readMem_en) ? mem_out : alu_out;

    assign done = prog_ctr == 128;


endmodule