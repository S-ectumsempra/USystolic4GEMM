module PE_array(

    input                                                                           clk,
    input                                                                           resetn,

    // Weight and Input
    input           [`COLUMN_NUM-1:0][`BINARY_WEIGHT_BITWIDTH-2:0]                  weight_abs_stream,
    input           [`COLUMN_NUM-1:0]                                               weight_sign_stream,
    input           [`ROW_NUM-1:0][`BINARY_INPUT_BITWIDTH-2:0]                      input_abs_stream,
    input           [`ROW_NUM-1:0]                                                  input_sign_stream,

    // Random Number
    input           [`ROW_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]                 b_w_rand_stream,
    input           [`ROW_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]                 b_i_rand_stream,

    // Output
    output  logic   [`COLUMN_NUM-1:0][`BINARY_OUTPUT_BITWIDTH-1:0]                  b_output_stream,

    // Reg Ctrl Logic
    input           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 vector_weight_reg_en, vector_weight_reg_r0w1,
    input           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 vector_input_reg_en, vector_input_reg_r0w1,
    input           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 vector_rand_num_reg_en, vector_rand_num_reg_r0w1,
    input           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 vector_output_num_reg_en, vector_output_num_reg_r0w1,

    // M_end
    input           [`ROW_NUM-1:0][`M_END_BITWIDTH-1:0]                             M_end
);

    // Weight and Input
    logic           [`ROW_NUM:0][`COLUMN_NUM-1:0][`BINARY_WEIGHT_BITWIDTH-2:0]      vector_b_weight_abs;
    logic           [`ROW_NUM:0][`COLUMN_NUM-1:0]                                   vector_b_weight_sign;
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 u_input_abs;
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0]                                 u_input_sign;

    // Random Number
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]b_w_rand_num_passby;
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0][`BINARY_RANDOM_NUM_BITWIDTH-1:0]b_i_rand_num_passby;

    // Partial Sum
    logic           [`ROW_NUM:0][`COLUMN_NUM-1:0][`BINARY_OUTPUT_BITWIDTH-1:0]      b_output_passby;

    // M_end
    logic           [`ROW_NUM-1:0][`COLUMN_NUM-1:0][`M_END_BITWIDTH-1:0]            M_end_inter;
    
    assign          vector_b_weight_abs[0] = weight_abs_stream;                     // weight_abs streams in from the top side
    assign          vector_b_weight_sign[0] = weight_sign_stream;                   // weight_sign streams in from the top side
    assign          b_output_stream = b_output_passby[0];                           // output stream out to the top side

    // PE array
    genvar r,c;
    generate
        for (r = 0; r < `ROW_NUM; r++)begin
            for (c = 0; c < `COLUMN_NUM; c++) begin
                if (c == 0)begin
                    PE_edge(.clk(clk),
                            .resetn(resetn),
                            // Weight and Input
                            .b_weight_abs(vector_b_weight_abs[r][c]),
                            .b_weight_sign(vector_b_weight_sign[r][c]),
                            .b_weight_abs_reg(vector_b_weight_abs[r+1][c]),
                            .b_weight_sign_reg(vector_b_weight_sign[r+1][c]),
                            .b_input_abs(input_abs_stream[r]),
                            .b_input_sign(input_abs_stream[r]),
                            .u_input_abs(u_input_abs[r][c]),
                            .u_input_sign(u_input_sign[r][c]),
                            // Random Number
                            .b_w_rand_num_passby(b_w_rand_stream[r]),
                            .b_w_rand_num_reg(b_w_rand_num_passby[r][c]),
                            .b_i_rand_num_passby(b_i_rand_stream[r]),
                            .b_i_rand_num_reg(b_i_rand_num_passby[r][c]),
                            .b_output_passby(b_output_passby[r+1][c]),
                            .b_output_reg(b_output_passby[r][c]),
                            // Reg Ctrl Logic
                            .weight_reg_en(vector_weight_reg_en[r][c]), .weight_reg_r0w1(vector_weight_reg_r0w1[r][c]),
                            .input_reg_en(vector_input_reg_en[r][c]), input_reg_r0w1(vector_input_reg_r0w1[r][c]),
                            .rand_num_reg_en(vector_rand_num_reg_en[r][c]), rand_num_reg_r0w1(vector_rand_num_reg_r0w1[r][c]),
                            .output_num_reg_en(vector_output_num_reg_en[r][c]), output_num_reg_r0w1(vector_output_num_reg_r0w1[r][c]),
                            // M_end
                            .M_end(M_end[r]),
                            .M_end_reg(M_end_inter[r][c])
                        );
                end else begin
                    PE_inner(.clk(clk),
                            .resetn(resetn),
                            // Weight and Input
                            .b_weight_abs(vector_b_weight_abs[r][c]),
                            .b_weight_sign(vector_b_weight_sign[r][c]),
                            .b_weight_abs_reg(vector_b_weight_abs[r+1][c]),
                            .b_weight_sign_reg(vector_b_weight_sign[r+1][c]),
                            .u_input_abs(u_input_abs[r][c]),
                            .u_input_sign(u_input_sign[r][c]),
                            .u_input_abs_reg(u_input_abs[r][c+1]),
                            .u_input_sign_reg(u_input_sign[r][c+1]),
                            // Random Number
                            .b_w_rand_num_passby(b_w_rand_num_passby[r][c]),
                            .b_w_rand_num_reg(b_w_rand_num_passby[r][c+1]),
                            .b_i_rand_num_passby(b_i_rand_num_passby[r][c]),
                            .b_i_rand_num_reg(b_w_rand_num_passby[r][c+1]),
                            .b_output_passby(b_output_passby[r+1][c]),
                            .b_output_reg(b_output_passby[r][c]),
                            // Reg Ctrl Logic
                            .weight_reg_en(vector_weight_reg_en[r][c]), .weight_reg_r0w1(vector_weight_reg_r0w1[r][c]),
                            .input_reg_en(vector_input_reg_en[r][c]), input_reg_r0w1(vector_input_reg_r0w1[r][c]),
                            .rand_num_reg_en(vector_rand_num_reg_en[r][c]), rand_num_reg_r0w1(vector_rand_num_reg_r0w1[r][c]),
                            .output_num_reg_en(vector_output_num_reg_en[r][c]), output_num_reg_r0w1(vector_output_num_reg_r0w1[r][c]),
                            // M_end
                            .M_end(M_end_inter[r][c]),
                            .M_end_reg(M_end_inter[r][c+1])
                        );
                end
            end
        end 
    endgenerate 

endmodule