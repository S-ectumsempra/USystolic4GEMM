`define CLK_PERIOD 10
`define BINARY_WEIGHT_BITWIDTH                      4
`define BINARY_INPUT_BITWIDTH                       4
`define BINARY_RANDOM_NUM_BITWIDTH                  3
`define BINARY_OUTPUT_BITWIDTH                      8
`define UNARY_WEIGHT_BITWIDTH                       2**(`BINARY_WEIGHT_BITWIDTH)
`define UNARY_INPUT_BITWIDTH                        2**(`BINARY_INPUT_BITWIDTH)
`define UNARY_RANDOM_NUM_BITWIDTH                   2**(`RANDOM_NUM_BITWIDTH)

module PE_inner_tb();

    logic                                                                           clk;
    logic                                                                           resetn;

    // Weight and Input
    logic           [`BINARY_WEIGHT_BITWIDTH-2:0]                                   b_weight_abs;
    logic                                                                           b_weight_sign;
    logic           [`BINARY_WEIGHT_BITWIDTH-2:0]                                   b_weight_abs_reg;
    logic                                                                           b_weight_sign_reg;
    logic                                                                           u_input_abs;
    logic                                                                           u_input_sign;
    logic                                                                           u_input_abs_reg;
    logic                                                                           u_input_sign_reg;

    // Random Number
    logic           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_w_rand_num_passby;
    logic           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_w_rand_num_reg;
    logic           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_i_rand_num_passby;
    logic           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_i_rand_num_reg;

    // Partial Sum
    logic           [`BINARY_OUTPUT_BITWIDTH-1:0]                                   b_output_passby;
    logic           [`BINARY_OUTPUT_BITWIDTH-1:0]                                   b_output_reg;

    // Reg Ctrl Logic
    logic                                                                           weight_reg_en, weight_reg_r0w1;
    logic                                                                           input_reg_en, input_reg_r0w1;
    logic                                                                           rand_num_reg_en, rand_num_reg_r0w1;
    logic                                                                           output_num_reg_en, output_num_reg_r0w1;

    // M_end
    logic           [`M_END_BITWIDTH-1:0]                                           M_end;
    logic           [`M_END_BITWIDTH-1:0]                                           M_end_reg;

    PE_inner PE_inner(  .clk(clk),
                        .resetn(resetn),
                        // Weight and Input
                        .b_weight_abs(b_weight_abs),
                        .b_weight_sign(b_weight_sign),
                        .b_weight_abs_reg(b_weight_abs_reg),
                        .b_weight_sign_reg(b_weight_sign_reg),
                        .u_input_abs(u_input_abs),
                        .u_input_sign(u_input_sign),
                        .u_input_abs_reg(u_input_abs_reg),
                        .u_input_sign_reg(u_input_sign_reg),
                        // Random Number
                        .b_w_rand_num_passby(b_w_rand_num_passby),
                        .b_w_rand_num_reg(b_w_rand_num_reg),
                        .b_i_rand_num_passby(b_i_rand_num_passby),
                        .b_i_rand_num_reg(b_i_rand_num_reg),
                        // Partial Sum
                        .b_output_passby(b_output_passby),
                        .b_output_reg(b_output_reg),
                        // Reg Ctrl Logic
                        .weight_reg_en(weight_reg_en), 
                        .weight_reg_r0w1(weight_reg_r0w1),
                        .input_reg_en(input_reg_en), 
                        .input_reg_r0w1(input_reg_r0w1),
                        .rand_num_reg_en(rand_num_reg_en), 
                        .rand_num_reg_r0w1(rand_num_reg_r0w1),
                        .output_num_reg_en(output_num_reg_en), 
                        .output_num_reg_r0w1(output_num_reg_r0w1),
                        // M_end
                        .M_end(M_end),
                        .M_end_reg(M_end_reg)
                        );

    always #(`CLK_PERIOD) clk = ~clk;
    
    initial begin

        clk = 0;
        resetn = 1;

        // Ctrl Signal
        weight_reg_en = '0;
        weight_reg_r0w1 = '0;
        input_reg_en = '0;
        input_reg_r0w1 = '0;
        rand_num_reg_en = '0;
        rand_num_reg_r0w1 = '0;
        output_num_reg_en = '0;
        output_num_reg_r0w1 = '0;
        M_end = 1'b0;

        #1 resetn = 0;
        @(posedge clk); #1;
 
        // Weight Load:
        b_weight_abs = {(`BINARY_WEIGHT_BITWIDTH-1){1'b1}};
        b_weight_sign = 1'b0;
        weight_reg_en = 1'b1;
        weight_reg_r0w1 = 1'b1;

        @(posedge clk); #1;

        weight_reg_r0w1 = 1'b0;

        for (int i=0; i<`UNARY_WEIGHT_BITWIDTH; i++)begin // Compute Multiplication for 8 cycles
            // Input Load:
            u_input_abs = 1'b1;
            u_input_sign = 1'b0;
            input_reg_en = '1;
            input_reg_r0w1 = '1;

            // Random Number Load:
            b_w_rand_num_passby = {`BINARY_RANDOM_NUM_BITWIDTH{1'b0}};
            b_i_rand_num_passby = {`BINARY_RANDOM_NUM_BITWIDTH{1'b0}};

            if(i == `UNARY_WEIGHT_BITWIDTH-1) M_end = 1;

            @(posedge clk); #1;
        end

        // Partial Sum Passby
        for (int i=0; i<1; i++)begin // Accumulate the partial sum from neighbours on the multiplication result
            b_output_passby = {2'b0,{(`BINARY_OUTPUT_BITWIDTH-2){1'b1}}};         
            @(posedge clk); #1;
        end

        #1; $finish;

    end

    initial begin
        $dumpfile("PE_inner.vcd");
	    $dumpvars(0, PE_inner.dut);
    end

endmodule