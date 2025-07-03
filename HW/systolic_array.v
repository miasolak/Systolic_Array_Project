`timescale 1ns / 1ps

module systolic_array #(
    parameter M = 3,
    parameter N = 3,
    parameter DATA_WIDTH = 32
)(
    input wire clk_i,
    input wire reset_i,
    input wire ready_i,
    input wire [N*DATA_WIDTH-1:0] a_i, 
    input wire [M*DATA_WIDTH-1:0] b_i,
   
    output wire [M*DATA_WIDTH-1:0] add_o,
    output wire en_x_o
);
    // Enable signals from Control_Logic
    wire en_a_i, en_b_i;
    
    // Control logic instance
    control_logic #(
        .M(M),
        .N(N)
    )control_logic_inst (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .ready_i(ready_i),
        .en_a_o(en_a_i),
        .en_b_o(en_b_i),
        .en_x_o(en_x_o)
    );


    // Input packed into arrays
    wire [DATA_WIDTH-1:0] a_in [0:N-1]; 
    wire [DATA_WIDTH-1:0] b_in [0:M-1];
    
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : unpack_a
            assign a_in[i] = a_i[(i+1)*DATA_WIDTH - 1 : i*DATA_WIDTH];
        end
    endgenerate
    
    generate
        for (i = 0; i < M; i = i + 1) begin : unpack_b
            assign b_in[i] = b_i[(i+1)*DATA_WIDTH - 1 : i*DATA_WIDTH];
        end
    endgenerate
  
    // 2D interconnect wires between PEs
    wire signed [DATA_WIDTH-1:0] a_wire [0:N-1][0:M];     
    wire signed [DATA_WIDTH-1:0] b_wire [0:N][0:M-1];
    wire signed [DATA_WIDTH-1:0] x_wire [0:N][0:M-1];
    wire signed [DATA_WIDTH-1:0] add_out [0:N-1][0:M-1];

    // PE array generation
    generate
        for (i = 0; i < N; i = i + 1) begin : row
            for (j = 0; j < M; j = j + 1) begin : col
                PE pe_inst (
                    .clk_i(clk_i),
                    .reset_i(reset_i),
                    .en_a_i(en_a_i),
                    .en_b_i(en_b_i),
                    .en_x_i(en_x_o),

                    .a_i(a_wire[i][j]),
                    .b_i(b_wire[i][j]),
                    .x_i(x_wire[i][j]),

                    .a_o(a_wire[i][j+1]),
                    .b_o(b_wire[i+1][j]),
                    .add_o(x_wire[i+1][j])
                );

                assign add_out[i][j] = x_wire[i+1][j];
            end
        end
    endgenerate

    // Input connections for first column and row
    generate
        for (i = 0; i < N; i = i + 1) begin : a_input
            assign a_wire[i][0] = a_in[i];
        end
    endgenerate

    generate
        for (j = 0; j < M; j = j + 1) begin : b_input
            assign b_wire[0][j] = b_in[j];
        end
    endgenerate

    generate
        for (j = 0; j < M; j = j + 1) begin : x_input 
            assign x_wire[0][j] = 32'd0;
        end
    endgenerate
    
    // Final output connections
    generate
        for(j = 0; j < M; j = j + 1) begin : add_output
            assign add_o[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH] = add_out[N-1][j];  
        end
    endgenerate

endmodule
