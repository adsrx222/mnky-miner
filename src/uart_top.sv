`include "uart_rx.sv"
`include "uart_tx.sv"

/* verilator lint_off UNUSEDSIGNAL */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off CASEINCOMPLETE */

module uart_top (
    input  logic clk,
    input  logic reset_n,

    // Top-level broadcast control
    input  logic start_midstate,
    input  logic start_broadcast,
    input  logic [255:0] midstate,
    input  logic [95:0]  data96,
    input  logic [31:0]  broadcast_value,
    output logic busy,

    // UART interface pins
    output logic tx,
    input  logic rx
);

    logic tx_start;
    logic [7:0] tx_data;
    logic tx_busy;

    uart_rx u_rx (
        .clk(clk),
        .reset_n(reset_n),
        .start_midstate(start_midstate),
        .start_broadcast(start_broadcast),
        .midstate(midstate),
        .data96(data96),
        .broadcast_value(broadcast_value),
        .busy(busy),

        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx_busy(tx_busy)
    );

    uart_tx #(.CLK_PER_BIT(50)) u_tx (
        .clk(clk),
        .reset_n(reset_n),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_busy(tx_busy)
    );

endmodule
/* verilator lint_on UNUSEDSIGNAL */
/* verilator lint_on UNDRIVEN */
/* verilator lint_on CASEINCOMPLETE */
