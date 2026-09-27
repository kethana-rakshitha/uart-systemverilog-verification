module uart_rx #(
    parameter CLKS_PER_BIT = 4
)(
    input  logic       clk,
    input  logic       rst,

    input  logic       rx,

    output logic [7:0] rx_data,
    output logic       rx_valid,
    output logic       busy
);

    // =====================================================
    // STATES
    // =====================================================

    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } state_t;

    state_t state;


    // =====================================================
    // INTERNAL REGISTERS
    // =====================================================

    logic [$clog2(CLKS_PER_BIT)-1:0] bit_timer;

    logic [2:0] bit_index;

    logic [7:0] data_reg;


    // =====================================================
    // UART RECEIVER
    // =====================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            state     <= IDLE;

            bit_timer <= '0;
            bit_index <= '0;

            data_reg  <= 8'b0;
            rx_data   <= 8'b0;

            rx_valid  <= 1'b0;
            busy      <= 1'b0;

        end

        else begin

            // rx_valid is a one-clock pulse
            rx_valid <= 1'b0;


            case (state)

                // =========================================
                // IDLE
                // =========================================

                IDLE: begin

                    busy      <= 1'b0;
                    bit_timer <= '0;
                    bit_index <= '0;


                    // Detect possible START bit
                    if (rx == 1'b0) begin

                        busy      <= 1'b1;
                        bit_timer <= '0;

                        state <= START;

                    end

                end


                // =========================================
                // START BIT
                // =========================================

                START: begin

                    busy <= 1'b1;


                    // Wait until middle of START bit
                    if (bit_timer == (CLKS_PER_BIT/2)-1) begin

                        if (rx == 1'b0) begin

                            // Valid START bit
                            bit_timer <= '0;
                            bit_index <= '0;

                            state <= DATA;

                        end

                        else begin

                            // False start
                            state <= IDLE;
                            busy  <= 1'b0;

                        end

                    end

                    else begin

                        bit_timer <= bit_timer + 1'b1;

                    end

                end


                // =========================================
                // DATA BITS
                // =========================================

                DATA: begin

                    busy <= 1'b1;


                    // Wait one complete bit period
                    if (bit_timer == CLKS_PER_BIT-1) begin

                        bit_timer <= '0;

                        // Sample current data bit
                        data_reg[bit_index] <= rx;


                        if (bit_index == 3'd7) begin

                            state <= STOP;

                        end

                        else begin

                            bit_index <= bit_index + 1'b1;

                        end

                    end

                    else begin

                        bit_timer <= bit_timer + 1'b1;

                    end

                end


                // =========================================
                // STOP BIT
                // =========================================

                STOP: begin

                    busy <= 1'b1;


                    if (bit_timer == CLKS_PER_BIT-1) begin

                        bit_timer <= '0;

                        // STOP bit should be HIGH
                        if (rx == 1'b1) begin

                            rx_data  <= data_reg;
                            rx_valid <= 1'b1;

                        end

                        state <= IDLE;
                        busy  <= 1'b0;

                    end

                    else begin

                        bit_timer <= bit_timer + 1'b1;

                    end

                end


                // =========================================
                // DEFAULT
                // =========================================

                default: begin

                    state     <= IDLE;
                    bit_timer <= '0;
                    bit_index <= '0;

                    rx_data   <= '0;
                    rx_valid  <= 1'b0;
                    busy      <= 1'b0;

                end

            endcase

        end

    end

endmodule
