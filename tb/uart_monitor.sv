class uart_monitor;

    mailbox mon2scb;

    virtual uart_if vif;

    int num_transactions;


    function new(
        mailbox mon2scb,
        virtual uart_if vif,
        int num_transactions
    );

        this.mon2scb = mon2scb;
        this.vif = vif;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        uart_transaction trans;

        repeat (num_transactions) begin

            // Wait until RX produces a valid byte
            @(posedge vif.clk);

            wait (vif.rx_valid == 1'b1);


            // Capture received data
            trans = new();

            trans.received_data = vif.rx_data;
            trans.valid = 1'b1;


            // Send to scoreboard
            mon2scb.put(trans);


            $display(
                "MONITOR: Received Data = %0h",
                vif.rx_data
            );


            // Wait for rx_valid to return low
            @(posedge vif.clk);

        end

    endtask

endclass
