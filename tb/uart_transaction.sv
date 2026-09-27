class uart_transaction;

    // Data transmitted by UART
    rand logic [7:0] data;

    // Data received by UART
    logic [7:0] received_data;

    // Indicates valid received transaction
    logic valid;


    constraint valid_data {

        data inside {[8'd0:8'd255]};

    }

endclass
