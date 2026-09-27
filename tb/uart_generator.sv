class uart_generator;

    mailbox gen2drv;
    mailbox exp2scb;

    int num_transactions;


    function new(
        mailbox gen2drv,
        mailbox exp2scb,
        int num_transactions
    );

        this.gen2drv = gen2drv;
        this.exp2scb = exp2scb;
        this.num_transactions = num_transactions;

    endfunction


    task run();

        uart_transaction trans;

        repeat (num_transactions) begin

            trans = new();

            if (!trans.randomize()) begin

                $fatal(
                    1,
                    "UART transaction randomization failed"
                );

            end

            // Send complete transaction to driver
            gen2drv.put(trans);

            // Send expected data to scoreboard
            exp2scb.put(trans.data);

            $display(
                "GENERATOR: Data = %0h",
                trans.data
            );

        end

    endtask

endclass
