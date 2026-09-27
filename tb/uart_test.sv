module uart_test;

    // =====================================================
    // CONFIGURATION
    // =====================================================

    parameter int NUM_TRANSACTIONS = 20;
    parameter int CLKS_PER_BIT     = 16;


    // =====================================================
    // CLOCK
    // =====================================================

    logic clk;


    // =====================================================
    // UART INTERFACE
    // =====================================================

    uart_if vif();


    // Connect clock
    assign vif.clk = clk;


    // =====================================================
    // UART TX
    // =====================================================

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut_tx (

        .clk      (vif.clk),
        .rst      (vif.rst),

        .tx_data  (vif.tx_data),
        .tx_start (vif.tx_start),

        .tx       (vif.tx),
        .busy     (vif.tx_busy)

    );


    // =====================================================
    // TX → RX CONNECTION
    // =====================================================

    assign vif.rx = vif.tx;


    // =====================================================
    // UART RX
    // =====================================================

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) dut_rx (

        .clk      (vif.clk),
        .rst      (vif.rst),

        .rx       (vif.rx),

        .rx_data  (vif.rx_data),
        .rx_valid (vif.rx_valid),
        .busy     (vif.rx_busy)

    );


    // =====================================================
    // ENVIRONMENT
    // =====================================================

    uart_environment env;


    // =====================================================
    // CLOCK GENERATION
    // =====================================================

    initial begin

        clk = 1'b0;

        forever #5 clk = ~clk;

    end


    // =====================================================
    // TEST
    // =====================================================

    initial begin

        // Create environment
        env = new(
            vif,
            NUM_TRANSACTIONS
        );


        // Initial values
        vif.rst      = 1'b1;
        vif.tx_start = 1'b0;
        vif.tx_data  = 8'b0;


        // Hold reset
        repeat (3)
            @(posedge clk);


        // Release reset
        vif.rst = 1'b0;


        // Start verification environment
        env.run();


        // Wait for all transactions
        wait (env.scb.transaction_count == NUM_TRANSACTIONS);


        // Small delay
        #10;


        // Print scoreboard report
        env.report();


        // Finish simulation
        $finish;

    end

endmodule
