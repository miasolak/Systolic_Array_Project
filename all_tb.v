module all_tb;

    parameter M = 3;
    parameter N = 3;
    parameter DATA_WIDTH = 32;
    
    reg clk_i;
    reg reset_i;

    reg [N*DATA_WIDTH-1:0] a_i;     //sadrzi 3 registra u sebi kao 1 vektor
    reg [M*DATA_WIDTH-1:0] b_i;      
    reg [M*DATA_WIDTH-1:0] c_i;     
    wire [M*DATA_WIDTH-1:0] add_o;

    reg [31:0] a_array [0:M-1][0:N-1]; // M setova po N elemenata
    reg [31:0] b_array [0:N-1][0:M-1]; // N setova po M elemenata
    reg [31:0] c_array [0:M-1];

    integer counter1;
    integer counter2;
    
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
     //    #10
                for (j = 0; j < N; j = j + 1) begin
                    // A: učitavanje i pakovanje
                    $fscanf(a_file, "%d\n", a_val);
                    a_array[i][j] = a_val;              //a_array[0][0] = 10, a_array[0][1] = 11, a_array[0][2] = 12
            
                    $fscanf(b_file, "%d\n", b_val);
                    b_array[j][i] = b_val;
                end
//                 Pakovanje A vektora
//                for (k = 0; k < N; k = k + 1) begin: blabla
//                    a_i[(k+1)*DATA_WIDTH - 1 : k*DATA_WIDTH] = a_array[i][k];   //a_i = 101112
//                end
               
//                 Pakovanje B vektora
//                for (k = 0; k < M; k = k + 1) begin
//                    b_i[(k+1)*DATA_WIDTH - 1 : k*DATA_WIDTH] = b_array[i][k]; //buni se verilog za k?! - k must be rounded by constant expression
//                end
         end

            for (j = 0; j < M; j = j + 1) begin
                 $fscanf(c_file, "%d\n", c_val);
                 c_array[j] = c_val;
                // c_i[(j+1)*DATA_WIDTH - 1 : j*DATA_WIDTH] = c_val; verilog se bunio kad mu granice nisu odredjene za j?!
            end
                   
        $fclose(a_file);
        $fclose(b_file);
        $fclose(c_file);
        
    end
//        // ⏱️ CEKANJE 4 TAKTA
//    #40;

//    // 🔍 PROVERA — UNESI Tvoje očekivane vrednosti OVDE:
//    if (add_0_o === c_0_i) $display("PASS add_0_o tacan za iteraciju %0d: %d", i/3, add_0_o);
//    else $display("FAIL add_0_o netacan za iteraciju %0d: %d", i/3, add_0_o);

//    if (add_1_o === c_1_i) $display("PASS add_1_o tacan za iteraciju %0d: %d", i/3, add_1_o);
//    else $display("FAIL add_1_o netacan za iteraciju %0d: %d", i/3, add_1_o);

//    if (add_2_o === c_2_i) $display("PASS add_2_o tacan za iteraciju %0d: %d", i/3, add_2_o);
//    else $display("FAIL add_2_o netacan za iteraciju %0d: %d", i/3, add_2_o);
    
//    $fclose(c_file);

//        // 🕒 Pauza za propagaciju
//        #200;

//        $display("=== SIMULACIJA GOTOVA sad ===");
//        $finish;

    
    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            a_i <= 0;
            b_i <= 0;
            c_i <= 0;
            counter1 <= 0;
            counter2 <= 0;

        end else begin 
            if (counter1 < M) begin 
                for (k = 0; k < N; k = k + 1) begin
                    a_i[(k+1)*DATA_WIDTH - 1 : k*DATA_WIDTH] <= a_array[counter1][k];   //a_i = 101112
                end
            end
            
            if (counter2 < N) begin
                for (k = 0; k < M; k = k + 1) begin
                    b_i[(k+1)*DATA_WIDTH - 1 : k*DATA_WIDTH] <= b_array[k][counter2];
                end
            end
        end
        
            if (counter2 < N - 1) begin
                counter2 <= counter2 + 1;
            end else begin
                counter2 <= 0;
            if (counter1 < M - 1) begin
                counter1 <= counter1 + 1;
            end else begin
                $display("=== GOTOVO: Sve kombinacije obradjene ===");
                $finish;
        end
    end

    end        
   

endmodule