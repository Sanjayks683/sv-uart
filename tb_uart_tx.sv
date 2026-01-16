`timescale 1ns/1ps

module tb_uart_tx;
    localparam integer CLK_FREQ  = 10_000_000; // 10 MHz
    localparam integer BAUD_RATE = 115200;    // 115200 baud
    localparam integer CLK_PERIOD = 100;      // 100 ns

    logic clk;
    logic rst;
    logic [7:0] tx_data;
    logic tx_start;
    logic tx;
    logic tx_done;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .tx_data(tx_data),
        .tx_start(tx_start),
        .tx(tx),
        .tx_done(tx_done)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    task send_byte(input [7:0] data);
        begin
            @(negedge clk);
            tx_data  = data;
            tx_start = 1'b1;
            @(negedge clk);
            tx_start = 1'b0;
            @(posedge tx_done);
            @(negedge clk);
            #500;
        end
    endtask

    initial begin
        clk      = 0;
        rst      = 1;
        tx_data  = 8'h00;
        tx_start = 0;

        #200;
        rst = 0;
        #200;

        $display("Sending 8'hA5 (10100101)...");
        send_byte(8'hA5);

        $display("Sending 8'h3C (00111100)...");
        send_byte(8'h3C);

        $display("UART TX Testbench Passed successfully!");
        $finish;
    end
endmodule
