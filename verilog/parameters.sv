// PE related
`define BINARY_WEIGHT_BITWIDTH                      4
`define BINARY_INPUT_BITWIDTH                       4
`define BINARY_RANDOM_NUM_BITWIDTH                  3
`define BINARY_OUTPUT_BITWIDTH                      8
`define UNARY_WEIGHT_BITWIDTH                       2**(`BINARY_WEIGHT_BITWIDTH)
`define UNARY_INPUT_BITWIDTH                        2**(`BINARY_INPUT_BITWIDTH)
`define UNARY_RANDOM_NUM_BITWIDTH                   2**(`RANDOM_NUM_BITWIDTH)
`define M_END_BITWIDTH                              2
// PE Array related
`define COLUMN_NUM      10
`define ROW_NUM         15