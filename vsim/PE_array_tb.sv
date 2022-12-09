`define CLK_PERIOD 10
`define BINARY_WEIGHT_BITWIDTH                      4
`define BINARY_INPUT_BITWIDTH                       4
`define BINARY_RANDOM_NUM_BITWIDTH                  3
`define BINARY_OUTPUT_BITWIDTH                      8
`define UNARY_WEIGHT_BITWIDTH                       2**(`BINARY_WEIGHT_BITWIDTH)
`define UNARY_INPUT_BITWIDTH                        2**(`BINARY_INPUT_BITWIDTH)
`define UNARY_RANDOM_NUM_BITWIDTH                   2**(`RANDOM_NUM_BITWIDTH)

module PE_array_test();

    logic                                                                           clk,
    logic                                                                           resetn,

    // Weight and Input
    logic           [`COLUMN_NUM-1:0][`BINARY_WEIGHT_BITWIDTH-2:0]                  weight_abs_stream,
    logic           [`COLUMN_NUM-1:0]                                               weight_sign_stream,
    logic           [`ROW_NUM-1:0][`BINARY_INPUT_BITWIDTH-2:0]                      input_abs_stream,
    logic           [`ROW_NUM-1:0]                                                  input_sign_stream,

    // Random Number
    logic           [`ROW_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]                 b_w_rand_stream,
    logic           [`ROW_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]                 b_i_rand_stream,

    // Output
    logic           [`COLUMN_NUM-1:0][`BINARY_OUTPUT_BITWIDTH-1:0]                  b_output_stream,

    // Reg Ctrl Logic
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 weight_reg_en, weight_reg_r0w1,
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 input_reg_en, input_reg_r0w1,
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 rand_num_reg_en, rand_num_reg_r0w1,
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 output_num_reg_en, output_num_reg_r0w1,

    // M_end
    logic           [`ROW_NUM-1:0][`M_END_BITWIDTH-1:0]                             M_end
    
    PE_array   PE_array(.clk(clk),
                        .resetn(resetn),
                        .weight_abs_stream(weight_abs_stream),
                        .weight_sign_stream(weight_sign_stream),
                        .input_abs_stream(input_abs_stream),
                        .input_sign_stream(input_sign_stream),
                        .b_w_rand_stream(b_w_rand_stream),
                        .b_i_rand_stream(b_i_rand_stream),
                        .b_output_stream(b_output_stream),
                        .weight_reg_en(weight_reg_en), 
                        .weight_reg_r0w1(weight_reg_r0w1),
                        .input_reg_en(input_reg_en), 
                        .input_reg_r0w1(input_reg_r0w1),
                        .rand_num_reg_en(rand_num_reg_en), 
                        .rand_num_reg_r0w1(rand_num_reg_r0w1),
                        .output_num_reg_en(output_num_reg_en), 
                        .output_num_reg_r0w1(output_num_reg_r0w1),
                        .M_end(M_end)
                        );

    always #(`CLK_PERIOD) clk = ~clk;
    
    initial begin

        clk = 0;
        resetn = 1;

        // Initialize Ctrl Signals
        weight_reg_en = '0;
        weight_reg_r0w1 = '0;
        input_reg_en = '0;
        input_reg_r0w1 = '0;
        rand_num_reg_en = '0;
        rand_num_reg_r0w1 = '0;
        output_num_reg_en = '0;
        output_num_reg_r0w1 = '0;
        M_end = '0;

        #1 resetn = 0;
        @(posedge clk); #1;
 
        // Weight Load from buffers to regs
        for(int=0; i<`ROW_NUM; i++)begin
            
            weight_abs_stream = ;
            weight_sign_stream = ;
            weight_reg_en[i] = {`COLUMN_NUM{1'b1}};
            weight_reg_r0w1[i] = {`COLUMN_NUM{1'b1}};

            @(posedge clk); #1;

        end
        
        weight_reg_r0w1 = '0;

        // Load Binary Input and Random Numbers
        for (int i=0; i<`INPUT_MATRIX_HEIGHT; i++)begin
            // Computation
            for (int j=0; j<`UNARY_WEIGHT_BITWIDTH; j++)begin // Compute Multiplication for `UNARY_WEIGHT_BITWIDTH cycles
                if(j == 0)begin
                    // Feed in input data
                    for(int j=0; j<`ROW_NUM; j++)begin               
                        input_reg_en[j][i] = 1'b1;
                        input_reg_r0w1[j][i] = 1'b1;
                    end
                    input_abs_stream = '0;
                    input_sign_stream = '0;
                end

                // Feed in w_random and i_random
                for(int k=0; k<`COLUMN_NUM; k++)begin               
                    rand_num_reg_en[k][0] = 1'b1;
                    rand_num_reg_r0w1[k][0] = 1'b1;
                end
                b_w_rand_stream = '0;
                b_i_rand_stream = '0;

                @(posedge clk); #1;
            end
        end
        
        // Partial Sum Passby
        for (int i=0; i<1; i++)begin // Accumulate the partial sum from neighbours on the multiplication result
            b_output_passby = {2'b0,{(`BINARY_OUTPUT_BITWIDTH-2){1'b1}}};         
            @(posedge clk); #1;
        end

        #1; $finish;

    end

    initial begin
        $dumpfile("PE_array.vcd");
	    $dumpvars(0, PE_array.dut);
    end

endmodule
