/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off CASEINCOMPLETE */

module uart_rx #(
    parameter MIDSTATE_W = 256,
    parameter DATA_W     = 96
)(
    input  logic clk,
    input  logic reset_n,
    input  logic start_midstate,
    input  logic start_broadcast,
    input  logic [MIDSTATE_W-1:0] midstate,
    input  logic [DATA_W-1:0]     data96,
    input  logic [31:0]           broadcast_value,
    output logic busy,

    output logic [7:0] tx_data,
    output logic       tx_start,
    input  logic       tx_busy
);

    typedef enum logic [1:0] {IDLE, SEND, WAIT} state_t;
    state_t state;

    logic [351:0] shift_reg;
    logic [5:0]   byte_count;
    logic [5:0]   total_bytes;

    assign tx_data  = shift_reg[351:344];
    assign tx_start = (state == SEND && !tx_busy);

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state       <= IDLE;
            shift_reg   <= 0;
            byte_count  <= 0;
            total_bytes <= 0;
            busy        <= 0;
        end else begin
            case(state)
                IDLE: begin
                    busy <= 0;
                    if (start_midstate) begin
                        shift_reg   <= {midstate, data96};
                        total_bytes <= 44;
                        byte_count  <= 0;
                        busy        <= 1;
                        state       <= SEND;
                    end else if (start_broadcast) begin
                        shift_reg   <= {320'b0, broadcast_value};
                        total_bytes <= 4;
                        byte_count  <= 0;
                        busy        <= 1;
                        state       <= SEND;
                    end
                end

                SEND: begin
                    if (!tx_busy) begin
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    if (!tx_busy) begin
                        shift_reg  <= shift_reg << 8;
                        byte_count <= byte_count + 1;
                        if (byte_count + 1 == total_bytes)
                            state <= IDLE;
                        else
                            state <= SEND;
                    end
                end
            endcase
        end
    end

endmodule
/* verilator lint_on UNUSEDSIGNAL */
/* verilator lint_on UNDRIVEN */
/* verilator lint_on CASEINCOMPLETE */
