module uart_tx #(
    parameter CLK_PER_BIT = 50
)(
    input  logic clk,
    input  logic reset_n,
    input  logic [7:0] tx_data,
    input  logic tx_start,
    output logic tx,
    output logic tx_busy
);

    typedef enum logic [1:0] {IDLE, START, DATA, STOP} state_t;
    state_t state;

    logic [7:0] shift_reg;
    logic [2:0] bit_idx;
    integer clk_cnt;

    assign tx_busy = (state != IDLE);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state     <= IDLE;
            tx        <= 1;
            shift_reg <= 0;
            bit_idx   <= 0;
            clk_cnt   <= 0;
        end else begin
            case(state)
                IDLE: begin
                    tx <= 1;
                    if (tx_start) begin
                        shift_reg <= tx_data;
                        state     <= START;
                        clk_cnt   <= 0;
                    end
                end

                START: begin
                    tx <= 0;
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLK_PER_BIT-1) begin
                        state   <= DATA;
                        bit_idx <= 0;
                        clk_cnt <= 0;
                    end
                end

                DATA: begin
                    tx <= shift_reg[bit_idx];
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLK_PER_BIT-1) begin
                        clk_cnt <= 0;
                        if (bit_idx == 7)
                            state <= STOP;
                        else
                            bit_idx <= bit_idx + 1;
                    end
                end

                STOP: begin
                    tx <= 1;
                    clk_cnt <= clk_cnt + 1;
                    if (clk_cnt == CLK_PER_BIT-1)
                        state <= IDLE;
                end
            endcase
        end
    end

endmodule
