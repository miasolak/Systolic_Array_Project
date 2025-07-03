module systolic_array_tb;
    
    parameter M = 14;
    parameter N = 16;
    parameter DATA_WIDTH = 32;
    
    reg clk_i;
    reg reset_i;
    reg ready_i;
    wire en_x_o;
    
    //Input and output
    reg [N*DATA_WIDTH-1:0] a_i;    
    reg [M*DATA_WIDTH-1:0] b_i;      
    reg [M*DATA_WIDTH-1:0] c_i;     
    wire [M*DATA_WIDTH-1:0] add_o; 
    reg [M*DATA_WIDTH-1:0] c_vector;       

    integer counter1;
    integer counter2;
    integer K, L;
    integer j, k;
    integer max;
    
    reg [N*DATA_WIDTH-1:0] temp_a;
    reg [M*DATA_WIDTH-1:0] temp_b;
     
    reg [31:0] matrix_counter;
    integer cycle_counter = 0;
    reg [32:0] cycle_counter_reg;
    wire data_read_single;
    reg   en_x_dly;
  
    
    // File I/O 
    integer a_file, b_file, c_file;
    integer a_val, b_val, c_val;
    integer dummy1, dummy2, dummy3, dummy4, dummy5;
    integer seed = 32'hABCD1234;
    
    // Instantiate DUT
    systolic_array #(
        .M(M),
        .N(N),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .ready_i(ready_i),
        .a_i(a_i),
        .b_i(b_i),
        .add_o(add_o),
        .en_x_o(en_x_o)
    );

    // Generating clock
    always #5 clk_i = ~clk_i;

    assign data_read_single = en_x_o & ~en_x_dly;
    

    
    initial begin
        // Initializing signals
        clk_i = 0;
        reset_i = 0;
        
        a_i = {N*DATA_WIDTH{1'b0}};  
        b_i = {M*DATA_WIDTH{1'b0}}; 

        #10 reset_i = 1;

        // Opening files
        a_file = $fopen("A.txt", "r");
        b_file = $fopen("B.txt", "r");
        c_file = $fopen("C.txt", "r");
       
        if (!a_file) begin
            $fatal(1, "Can't open file A.txt.");
        end
        if (!b_file) begin
            $fatal(1, "Can't open file B.txt.");
        end
        if (!c_file) begin
            $fatal(1, "Can't open file C.txt");
        end
        
        dummy1 = $fscanf(a_file, "%d\n", a_val);
        K = a_val;
         
        dummy2 = $fscanf(b_file, "%d\n", b_val);  
        L = b_val;

        ready_i = 1;
        counter1 = 0;
        counter2 = 0;
        
        if (M > N)
            max = M;
        else
            max = N;
        
        ready_i = 1;
    end
    
    // Main testbench loop
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
        
        // Loading A and B vectors from files        
        if (cycle_counter < max && matrix_counter < K) begin
            if (counter1 < M) begin         
                temp_a = 0;
                for (k = 0; k < N; k = k + 1) begin
                    dummy3 = $fscanf(a_file, "%d\n", a_val);
                    temp_a = temp_a | (a_val << (DATA_WIDTH * k));
                end
                a_i <= temp_a;
                counter1 <= counter1 + 1;
            end
            
            // Load expected result
            if (counter2 < N) begin
                temp_b = 0;
                for (k = 0; k < M; k = k + 1) begin
                    dummy4 = $fscanf(b_file, "%d\n", b_val);
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
         
        // Prepare next matrix 
        if (cycle_counter == max+N-1) begin
            cycle_counter <= 0;
            counter1 <= 0;
            counter2 <= 0;
            matrix_counter <= matrix_counter + 1; 
           if (matrix_counter == K)begin
            ready_i <= 0;
           end
        end
        

        // Check result        
        if (cycle_counter_reg == max+N-1 && matrix_counter < K+1) begin
            if (c_vector == add_o) begin 
                $display("It works!!!");
            end else begin
                $display("It doesn't work!!!");
            end
        end
           

        if (cycle_counter == 1) begin
            c_vector = 0;
            for (j = 0; j < M; j = j + 1) begin
                dummy5 = $fscanf(c_file, "%d\n", c_val);
                c_vector = c_vector | (c_val << (DATA_WIDTH * j));
            end
        end 
        
        
        
//        //ready signal
//        if (ready_i == 0)
//            ready_i <= $random(seed) % 2;  // random
//        else if (data_read_single == 1)
//            ready_i <= $random(seed) % 2;
        

        en_x_dly <= en_x_o;
        
  
        end  //from reset
            
    end //from always

   

endmodule