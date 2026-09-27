class uart_scoreboard;

    mailbox exp2scb;
    mailbox mon2scb;


    // Expected data from generator
    logic [7:0] expected_queue[$];


    int pass_count = 0;
    int fail_count = 0;
    int transaction_count = 0;


    function new(
        mailbox exp2scb,
        mailbox mon2scb
    );

        this.exp2scb = exp2scb;
        this.mon2scb = mon2scb;

    endfunction


    // =====================================================
    // COLLECT EXPECTED DATA
    // =====================================================

    task collect_expected();

        logic [7:0] expected_data;

        forever begin

            exp2scb.get(expected_data);

            expected_queue.push_back(expected_data);

            $display(
                "EXPECTED: Data = %0h Queue_Size = %0d",
                expected_data,
                expected_queue.size()
            );

        end

    endtask


    // =====================================================
    // COMPARE RX DATA WITH EXPECTED DATA
    // =====================================================

    task run();

        uart_transaction trans;

        logic [7:0] expected_data;


        forever begin

            // Wait for monitor
            mon2scb.get(trans);


            if (!trans.valid) begin

                $display(
                    "SCOREBOARD: Invalid transaction ignored"
                );

                continue;

            end


            transaction_count++;


            // Make sure expected data exists
            if (expected_queue.size() == 0) begin

                fail_count++;

                $display(
                    "UART FAIL: Received=%0h but no expected data",
                    trans.received_data
                );

                continue;

            end


            // Get expected data
            expected_data = expected_queue.pop_front();


            // Compare
            if (trans.received_data == expected_data) begin

                pass_count++;

                $display(
                    "UART PASS: Expected=%0h Actual=%0h",
                    expected_data,
                    trans.received_data
                );

            end

            else begin

                fail_count++;

                $display(
                    "UART FAIL: Expected=%0h Actual=%0h",
                    expected_data,
                    trans.received_data
                );

            end

        end

    endtask


    // =====================================================
    // FINAL REPORT
    // =====================================================

    function void report();

        $display("");
        $display("========================================");
        $display("       UART SCOREBOARD SUMMARY");
        $display("========================================");

        $display(
            "Transactions : %0d",
            transaction_count
        );

        $display(
            "PASS         : %0d",
            pass_count
        );

        $display(
            "FAIL         : %0d",
            fail_count
        );

        $display(
            "Remaining    : %0d",
            expected_queue.size()
        );

        $display("========================================");

    endfunction

endclass
