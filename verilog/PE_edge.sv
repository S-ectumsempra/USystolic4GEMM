module PE_edge(

    input                                                                           clk,
    input                                                                           resetn,

    // Weight and Input
    input           [`BINARY_WEIGHT_BITWIDTH-2:0]                                   b_weight_abs,
    input                                                                           b_weight_sign,
    output  logic   [`BINARY_WEIGHT_BITWIDTH-2:0]                                   b_weight_abs_reg,
    output  logic                                                                   b_weight_sign_reg,
    input           [`BINARY_INPUT_BITWIDTH-2:0]                                    b_input_abs,
    input                                                                           b_input_sign,
    output  logic                                                                   u_input_abs,
    output  logic                                                                   u_input_sign,

    // Random Number
    input           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_w_rand_num_passby,
    output  logic   [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_w_rand_num_reg,
    input           [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_i_rand_num_passby,
    output  logic   [`BINARY_RANDOM_NUM_BITWIDTH-1:0]                               b_i_rand_num_reg,

    // Partial Sum
    input           [`BINARY_OUTPUT_BITWIDTH-1:0]                                   b_output_passby,
    output  logic   [`BINARY_OUTPUT_BITWIDTH-1:0]                                   b_output_reg,

    // Reg Ctrl Logic
    input                                                                           weight_reg_en, weight_reg_r0w1,
    input                                                                           input_reg_en, input_reg_r0w1,
    input                                                                           rand_num_reg_en, rand_num_reg_r0w1,
    input                                                                           output_num_reg_en, output_num_reg_r0w1,

    // M_end
    input           [`M_END_BITWIDTH-1:0]                                           M_end,
    output  logic   [`M_END_BITWIDTH-1:0]                                           M_end_reg

);

    logic                                                                           bit_mult_sign, u_weight_abs, bit_mult;
    logic           [`BINARY_OUTPUT_BITWIDTH-1:0]                                   next_b_output_reg;
    logic           [`BINARY_INPUT_BITWIDTH-2:0]                                    b_input_abs_reg;
    logic                                                                           b_input_sign_reg;

    always begin
        
        u_weight_abs = (b_weight_abs_reg > b_w_rand_num_reg)? 1'b1 : 1'b0;
        u_input_abs = (b_input_abs_reg > b_i_rand_num_reg)? 1'b1 : 1'b0;
        u_input_sign = b_input_sign;
        bit_mult_sign = u_input_sign ^ b_weight_sign_reg;
        bit_mult =  u_input_abs & u_weight_abs;

        next_b_output_reg = b_output_reg;

        if (M_end == 2'b01) begin
            if(bit_mult == 1 & bit_mult_sign == 0)begin
                next_b_output_reg = b_output_reg + 'd1;
            end else if(bit_mult == 1 & bit_mult_sign == 1)begin
                next_b_output_reg = b_output_reg - 'd1;
            end
        end else if(M_end == 2'b10) begin
            next_b_output_reg  = b_output_reg + b_output_passby;
        end

    end

    always @(posedge clk or negedge resetn) begin
        if(resetn == 0)begin
            {b_weight_sign_reg,b_weight_abs_reg}    <=  '0;
            {b_input_sign_reg,b_input_abs_reg}      <=  '0;
            {b_w_rand_num_reg,b_i_rand_num_reg}     <=  '0;
            b_output_reg                            <=  '0;
            M_end_reg                               <=  '0;
        end else begin
            if(weight_reg_en & weight_reg_r0w1)begin
                {b_weight_sign_reg,b_weight_abs_reg}    <=  {b_weight_sign,b_weight_abs};
            end
            if(input_reg_en & input_reg_r0w1)begin
                {b_input_sign_reg,b_input_abs_reg}      <=  {u_input_sign,u_input_abs};
            end
            if(rand_num_reg_en & rand_num_reg_r0w1)begin
                {b_w_rand_num_reg,b_i_rand_num_reg}     <=  {b_w_rand_num_passby,b_i_rand_num_passby};
            end
            if(output_num_reg_en & output_num_reg_r0w1)begin
                b_output_reg                            <=  next_b_output_reg;
            end
            M_end_reg                                   <=  M_end;
        end
    end

endmodule




