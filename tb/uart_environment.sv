class uart_environment;

    mailbox gen2drv;
    mailbox exp2scb;
    mailbox mon2scb;


    virtual uart_if vif;


    uart_generator  gen;
    uart_driver     drv;
    uart_monitor    mon;
    uart_scoreboard scb;


    int num_transactions;


    function new(
        virtual uart_if vif,
        int num_transactions
    );

        this.vif = vif;
        this.num_transactions = num_transactions;


        // Create mailboxes
        gen2drv = new();
        exp2scb = new();
        mon2scb = new();


        // Create generator
        gen = new(
            gen2drv,
            exp2scb,
            num_transactions
        );


        // Create driver
        drv = new(
            gen2drv,
            vif,
            num_transactions
        );


        // Create monitor
        mon = new(
            mon2scb,
            vif,
            num_transactions
        );


        // Create scoreboard
        scb = new(
            exp2scb,
            mon2scb
        );

    endfunction


    task run();

        fork

            gen.run();

            drv.run();

            mon.run();

            scb.collect_expected();

            scb.run();

        join_none

    endtask


    function void report();

        scb.report();

    endfunction

endclass
