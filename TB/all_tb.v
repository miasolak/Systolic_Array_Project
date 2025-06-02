module all_tb;

    parameter M = 3;
    parameter N = 3;
    parameter DATA_WIDTH = 32;
    
    reg clk_i;
    reg reset_i;

    reg [N*DATA_WIDTH-1:0] a_i;     //sadrzi 3 registra u sebi kao 1 vektor
    reg [M*DATA_WIDTH-1:0] b_i;      
    reg [M*DATA_WIDTH-1:0] c_i;     
    wire [M*DATA_WIDTH-1:0] add_o; // wire jer ga ne menjas u alwaysu - PROVERI - //sadrzi 3 registra u sebi kao 1 vektor

    reg [31:0] a_array [0:M-1][0:N-1]; // M setova po N elemenata
    reg [31:0] b_array [0:N-1][0:M-1]; // N setova po M elemenata
    reg [M*DATA_WIDTH-1:0] c_vector;        // vektor

    integer counter1;
    integer counter2;
    
    reg [N*DATA_WIDTH-1:0] temp_a;
    reg [M*DATA_WIDTH-1:0] temp_b;
    
    integer done = 0;
    
    // Instanca top modula
    all #(M, N, DATA_WIDTH) dut (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .a_i(a_i),
        .b_i(b_i),
        .add_o(add_o)
    );

    // Clock generacija
    always #5 clk_i = ~clk_i;

    // 🟡 Deklaracije za čitanje iz fajla
    integer a_file, b_file, c_file;
    integer a_val, b_val, c_val;
   // integer i, j;
    integer i, j;
    integer k;

    initial begin
        // Inicijalizacija signala
        clk_i = 0;
        reset_i = 0;
        
        a_i = {N*DATA_WIDTH{1'b0}};  // N × 32 bita nule
        b_i = {M*DATA_WIDTH{1'b0}};  // M × 32 bita nule

        #10 reset_i = 1;

        // Otvaranje fajlova
        a_file = $fopen("C:/Vivado/Systolic_Array/A.txt", "r");
        b_file = $fopen("C:/Vivado/Systolic_Array/B.txt", "r");
        c_file = $fopen("C:/Vivado/Systolic_Array/C.txt", "r");
       
        if (!a_file || !b_file) begin
            $fatal("Ne mogu da otvorim A.txt ili B.txt");
        end
        
         for (i = 0; i < M; i = i + 1) begin
                for (j = 0; j < N; j = j + 1) begin
                    // A: učitavanje i pakovanje
                    $fscanf(a_file, "%d\n", a_val);
                    a_array[i][j] = a_val;              //a_array[0][0] = 3, a_array[1][0] = 6, a_array[2][0] = 9
            
                    $fscanf(b_file, "%d\n", b_val);
                    b_array[i][j] = b_val;
                end
         end
        
        c_vector = 0;
            for (j = 0; j < M; j = j + 1) begin
                 $fscanf(c_file, "%d\n", c_val);
                 //c_vector = (c_val << (DATA_WIDTH * (M - 1 - j))) | c_vector;
                 c_vector = c_vector | (c_val << (DATA_WIDTH * j));
                 //c_vector = (c_vector << DATA_WIDTH) | c_val;
            end
                   
        $fclose(a_file);
        $fclose(b_file);
        $fclose(c_file);
        
    end

    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            a_i <= 0;
            b_i <= 0;
            c_i <= 0;
            counter1 <= 0;
            counter2 <= 0;

        end else begin 
               if (counter1 < M) begin
                temp_a = 0;
                    for (k = 0; k < N; k = k + 1) begin
                        temp_a = (temp_a << DATA_WIDTH) | a_array[counter1][N - 1 - k];
                        //temp_a = (temp_a << DATA_WIDTH) | a_array[counter1][k];     //FOR ODJEDNOM (non-blocking) !!!
                    end
                a_i <= temp_a;
          //  counter1 <= counter1 + 1;                                           //BROJAC NA CLOCK (blocking) !!!
            end
            counter1 <= counter1 + 1;
            if (counter2 < N) begin
                temp_b = 0;
                for (k = 0; k < M; k = k + 1) begin
                    temp_b = (temp_b << DATA_WIDTH) | b_array[counter2][N - 1 - k];
                    //temp_b = (temp_b << DATA_WIDTH) | b_array[counter2][k];
                end
                b_i <= temp_b;
//                counter2 <= counter2 + 1;
            end
            counter2 <= counter2 + 1;
            
            if (counter1 == 6 && done != 1) begin
                done = 1;
                $display("=== Provera ===");
                if (c_vector == add_o) begin
                    $display("Radi.");
                end else begin
                    $display("Ne radi.");
                end
            end
//            for (j = 0; j < M; j = j + 1) begin
//                if (c_array[j] == add_o[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH]) begin
//                    printf("Radi.");
//                end
//            end
            
            
//            for (j = 0; j < M; j = j + 1) begin
//                 $fscanf(c_file, "%d\n", c_val);
//                 c_array[j] = c_val;
//                // c_i[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH] = c_val; verilog se bunio kad mu granice nisu odredjene za j?!
//            end
            
            
            
            
        end
      end
    
   

endmodule