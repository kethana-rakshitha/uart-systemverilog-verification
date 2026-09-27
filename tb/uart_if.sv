interface uart_if;

    logic clk;
    logic rst;

    // =====================================================
    // TX SIDE
    // =====================================================

    logic [7:0] tx_data;
    logic       tx_start;
    logic       tx;
    logic       tx_busy;


    // =====================================================
    // RX SIDE
    // =====================================================

    logic       rx;
    logic [7:0] rx_data;
    logic       rx_valid;
    logic       rx_busy;


    // =====================================================
    // ASSERTIONS
    // =====================================================

    // TX must be HIGH when idle

    property p_tx_high_when_idle;

        @(posedge clk)
        disable iff (rst)
        !tx_busy |-> tx;

    endproperty


    assert property (p_tx_high_when_idle)

        else $error(
            "UART ASSERTION FAILED: TX is LOW while idle"
        );


    // =====================================================
    // RX VALID MUST HAVE KNOWN DATA
    // =====================================================

    property p_rx_valid_known_data;

        @(posedge clk)
        disable iff (rst)
        rx_valid |-> !$isunknown(rx_data);

    endproperty


    assert property (p_rx_valid_known_data)

        else $error(
            "UART ASSERTION FAILED: RX_DATA is unknown"
        );


endinterface
