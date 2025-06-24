`timescale 1ns / 1ps

module all #(parameter M = 3, N = 3, DATA_WIDTH = 32) (
    input wire clk_i,
    input wire reset_i,
    input wire ready_i,

    input wire [N*DATA_WIDTH-1:0] a_i,      //a_i = 3 * 32 bita je velicina VEKTORA a_i
    input wire [M*DATA_WIDTH-1:0] b_i,

//    input wire [31:0] a_0_i,
//    input wire [31:0] a_1_i,
//    input wire [31:0] a_2_i,

//    input wire [31:0] b_0_i,
//    input wire [31:0] b_1_i,
//    input wire [31:0] b_2_i,
    
    output wire [M*DATA_WIDTH-1:0] add_o
    
//    output wire [31:0] add_0_o,
//    output wire [31:0] add_1_o,
//    output wire [31:0] add_2_o
);

    wire en_a_i, en_b_i, en_x_i;

    fsm
    #(
        .M(M),
        .N(N)
    )fsm_logic
    (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .ready_i(ready_i),
        .en_a_o(en_a_i),
        .en_b_o(en_b_i),
        .en_x_o(en_x_i)
    );


    // Ulazi spakovani u lokalne nizove
    wire [DATA_WIDTH-1:0] a_in [0:N-1]; //ovo je NIZ od 3 elementa, svaki sirine 32 bita: vektor a_in0 - 32bitni, a_in1, a_in2
    wire [DATA_WIDTH-1:0] b_in [0:M-1];
    
    genvar i, j;
    generate
        for (i = 0; i < N; i = i + 1) begin : unpack_a
            assign a_in[i] = a_i[(i+1)*DATA_WIDTH - 1 : i*DATA_WIDTH];
        end
    endgenerate
    
    
    //assign a_in[0] = a_i[31 : 0];
    //assign a_in[1] = a_i[63 : 32];
    //assign a_in[2] = a_i[95 : 64];

    //    assign a_in[0] = a_0_i; //!!!!!         //ide samo do prve kolone a-ova
    //    assign a_in[1] = a_1_i;
    //    assign a_in[2] = a_2_i;
    
    generate
        for (i = 0; i < M; i = i + 1) begin : unpack_b
            assign b_in[i] = b_i[(i+1)*DATA_WIDTH - 1 : i*DATA_WIDTH];
        end
    endgenerate

        
    //    assign b_in[0] = b_0_i;
    //    assign b_in[1] = b_1_i;
    //    assign b_in[2] = b_2_i;
    
    
    // 2D žice za povezivanje PE-ova
    wire [DATA_WIDTH-1:0] a_wire [0:N-1][0:M];    //ide do svakog PE-a       VIDI JEL PRVO N ILI M??
    wire [DATA_WIDTH-1:0] b_wire [0:N][0:M-1];
    wire [DATA_WIDTH-1:0] x_wire [0:N][0:M-1];
    wire [DATA_WIDTH-1:0] add_out [0:N-1][0:M-1];

    generate
        for (i = 0; i < N; i = i + 1) begin : row
            for (j = 0; j < M; j = j + 1) begin : col
                PE pe_inst (
                    .clk_i(clk_i),
                    .reset_i(reset_i),
                    .en_a_i(en_a_i),
                    .en_b_i(en_b_i),
                    .en_x_i(en_x_i),

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

    // Ulaz a ide nadesno po redu
    generate
        for (i = 0; i < N; i = i + 1) begin : a_input
            assign a_wire[i][0] = a_in[i];
        end
    endgenerate

    // Ulaz b ide nadole po koloni
    generate
        for (j = 0; j < M; j = j + 1) begin : b_input
            assign b_wire[0][j] = b_in[j];
        end
    endgenerate

    // Ulaz x ide nadole po koloni, sve nule
    generate
        for (j = 0; j < M; j = j + 1) begin : x_input 
            assign x_wire[0][j] = 32'd0;
        end
    endgenerate
    
     // Sumirani izlazi po koloni
    generate
        for(j = 0; j < M; j = j + 1) begin : add_output
            assign add_o[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH] = add_out[N-1][j];  
        end
    endgenerate
    
//    // Sumirani izlazi po koloni
//    assign add_0_o = add_out[M-1][0];
//    assign add_1_o = add_out[M-1][1];
//    assign add_2_o = add_out[M-1][2];

endmodule


//sto nije moglo a wire[][] direktno na a_i_0 a ne na a[]????