class uart_driver;

    mailbox gen2drv;

    virtual uart_if vif;

    int num_transactions;


    function new(
        mailbox gen2drv,
        virtual uart_if vif,
        int num_transactions
    );

        this.gen2drv = gen2drv;
        this.vif = vif;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        uart_transaction trans;

        repeat (num_transactions) begin

            // Get transaction
            gen2drv.get(trans);


            // Wait for safe edge
            @(negedge vif.clk);


            // Drive data
            vif.tx_data  <= trans.data;
            vif.tx_start <= 1'b1;


            // Keep tx_start asserted for one clock
            @(posedge vif.clk);

            #1;

            vif.tx_start <= 1'b0;


            // Wait until transmission actually starts
            wait (vif.tx_busy == 1'b1);


            // Wait until transmission completes
            wait (vif.tx_busy == 1'b0);


            $display(
                "DRIVER: Transmission completed for Data = %0h",
                trans.data
            );


            // Gap before next transaction
            @(negedge vif.clk);

        end

    endtask

endclass
