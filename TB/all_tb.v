module all_tb;
    
    parameter M = 5;
    parameter N = 5;
    parameter DATA_WIDTH = 32;
    
    reg clk_i;
    reg reset_i;
    reg ready_i;
    reg ready_i_reg;

    reg [N*DATA_WIDTH-1:0] a_i;     //sadrzi 3 registra u sebi kao 1 vektor
    reg [M*DATA_WIDTH-1:0] b_i;      
    reg [M*DATA_WIDTH-1:0] c_i;     
    wire [M*DATA_WIDTH-1:0] add_o; // wire jer ga ne menjas u alwaysu - PROVERI - //sadrzi 3 registra u sebi kao 1 vektor

//    reg [31:0] a_array [0:M-1][0:N-1]; // M setova po N elemenata
//    reg [31:0] b_array [0:N-1][0:M-1]; // N setova po M elemenata
    reg [M*DATA_WIDTH-1:0] c_vector;        // vektor

    integer counter1;
    integer counter2;
    integer K;
    integer L;
    
    reg [N*DATA_WIDTH-1:0] temp_a;
    reg [M*DATA_WIDTH-1:0] temp_b;
    
    integer done = 0;
    
    reg [31:0] matrix_counter;
    reg load_new_matrix;
    integer cycle_counter = 0;
    reg [4:0] cycle_counter_reg;
    
    integer dummy1, dummy2, dummy3, dummy4, dummy5, dummy6;
    
    // Instanca top modula
    all #(.M(M), .N(N), .DATA_WIDTH(DATA_WIDTH)) dut (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .ready_i(ready_i),
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
    integer max;

    initial begin
        // Inicijalizacija signala
        clk_i = 0;
        reset_i = 0;
        
        a_i = {N*DATA_WIDTH{1'b0}};  // N × 32 bita nule
        b_i = {M*DATA_WIDTH{1'b0}};  // M × 32 bita nule

        #10 reset_i = 1;

        // Otvaranje fajlova
        a_file = $fopen("A.txt", "r");
        b_file = $fopen("B.txt", "r");
        c_file = $fopen("C.txt", "r");
       
        if (!a_file) begin
            $fatal(1, "Ne mogu da otvorim A.txt");
        end
        if (!b_file) begin
            $fatal(1, "Ne mogu da otvorim B.txt");
        end
        if (!c_file) begin
            $fatal(1, "Ne mogu da otvorim C.txt");
        end
        
         dummy1 = $fscanf(a_file, "%d\n", a_val);
         K = a_val;
         
         dummy2 = $fscanf(b_file, "%d\n", b_val);    //jel sme dummy kao rec svuda??
         L = b_val;
         
        
          
 
//        c_vector = 0;
//            for (j = 0; j < M; j = j + 1) begin
//                 dummy3 = $fscanf(c_file, "%d\n", c_val);        
//                 c_vector = c_vector | (c_val << (DATA_WIDTH * j));
//            end
                   
    //    $fclose(c_file);


    load_new_matrix = 0;
    counter1 = 0;
    counter2 = 0;
        
        if (M > N)
            max = M;
        else
            max = N;
        
        ready_i = 1;
    end
    

    always @(posedge clk_i or negedge reset_i) begin
        if (!reset_i) begin
            a_i <= 0;
            b_i <= 0;
            c_i <= 0;
            counter1 <= 0;
            counter2 <= 0;
            matrix_counter <= 0;
            cycle_counter <= 0;
            ready_i <= 0;

        end else begin 
        
        if (cycle_counter < max && matrix_counter < K) begin
            if (counter1 < M) begin             // jel treba da sklanjam ova dva countera??
                temp_a = 0;
                for (k = 0; k < N; k = k + 1) begin
                    dummy4 = $fscanf(a_file, "%d\n", a_val);
                    temp_a = temp_a | (a_val << (DATA_WIDTH * k));
                    //temp_a = (temp_a << DATA_WIDTH) | a_val;
                end
                a_i <= temp_a;
                counter1 <= counter1 + 1;
            end
            
            if (counter2 < N) begin
                temp_b = 0;
                for (k = 0; k < M; k = k + 1) begin
                    dummy5 = $fscanf(b_file, "%d\n", b_val);
                    temp_b = temp_b | (b_val << (DATA_WIDTH * k));
                end
                b_i <= temp_b;
                counter2 <= counter2 + 1;
            end
       end else begin
            a_i <= 0;
            b_i <= 0;
       end     
       
       if (matrix_counter < K+1)
         cycle_counter <= cycle_counter + 1;
       else
         cycle_counter <= 0;
         
       
        cycle_counter_reg <= cycle_counter;
         
          
        if (cycle_counter == max+N-1) begin
            cycle_counter <= 0;
            counter1 <= 0;
            counter2 <= 0;
            matrix_counter <= matrix_counter + 1; 
            
           if (matrix_counter == K)begin
            ready_i <= 0;
           
           end
        end
        

       
        if (cycle_counter_reg == max+N-1 && matrix_counter < K+1) begin
            if (c_vector == add_o) begin 
                $display("RAAADII");
            end else begin
                $display("Ne radi ");
            end
        end
           

        if (cycle_counter == 1) begin
            c_vector = 0;
            for (j = 0; j < M; j = j + 1) begin
                dummy6 = $fscanf(c_file, "%d\n", c_val);
                c_vector = c_vector | (c_val << (DATA_WIDTH * j));
            end
        end 
        

//            cycle_counter <= 0;
//        else 
//            ready_i <= 1;
   
        
      
       
//       if (matrix_counter == K) begin
//            $fclose(a_file);
//            $fclose(b_file);
//            $fclose(c_file);
//       end
  
      end  //if reset
            
    end //always

   

endmodule