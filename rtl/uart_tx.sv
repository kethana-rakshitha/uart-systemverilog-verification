module uart_tx #(
    parameter CLKS_PER_BIT = 4
)(
    input  logic       clk,
    input  logic       rst,

    input  logic       tx_start,
    input  logic [7:0] tx_data,

    output logic       tx,
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

    logic [7:0] data_reg;

    logic [$clog2(CLKS_PER_BIT)-1:0] bit_timer;

    logic [2:0] bit_index;


    // =====================================================
    // UART TRANSMITTER
    // =====================================================

    always_ff @(posedge clk) begin

        if (rst) begin

            state     <= IDLE;
            data_reg  <= 8'b0;
            bit_timer <= '0;
            bit_index <= '0;

            tx        <= 1'b1;
            busy      <= 1'b0;

        end

        else begin

            case (state)

                // =========================================
                // IDLE
                // =========================================

                IDLE: begin

                    tx        <= 1'b1;
                    busy      <= 1'b0;

                    bit_timer <= '0;
                    bit_index <= '0;


                    if (tx_start) begin

                        data_reg <= tx_data;

                        busy     <= 1'b1;
                        tx       <= 1'b0;

                        state    <= START;

                    end

                end


                // =========================================
                // START BIT
                // =========================================

                START: begin

                    tx   <= 1'b0;
                    busy <= 1'b1;


                    if (bit_timer == CLKS_PER_BIT-1) begin

                        bit_timer <= '0;
                        bit_index <= '0;

                        state <= DATA;

                    end

                    else begin

                        bit_timer <= bit_timer + 1'b1;

                    end

                end


                // =========================================
                // DATA BITS
                // =========================================

                DATA: begin

                    tx   <= data_reg[bit_index];
                    busy <= 1'b1;


                    if (bit_timer == CLKS_PER_BIT-1) begin

                        bit_timer <= '0;


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

                    tx   <= 1'b1;
                    busy <= 1'b1;


                    if (bit_timer == CLKS_PER_BIT-1) begin

                        bit_timer <= '0;

                        busy  <= 1'b0;
                        state <= IDLE;

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
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    bit_timer <= '0;
                    bit_index <= '0;

                end

            endcase

        end

    end

endmodule
