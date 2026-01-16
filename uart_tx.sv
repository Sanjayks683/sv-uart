module uart_tx #(
    parameter integer CLK_FREQ= 1_000_000,
    parameter integer BAUD_RATE= 9600
)(
    input logic clk,
    input logic rst,
    input logic[7:0] tx_data,
    input logic tx_start,
    output logic tx,
    output logic tx_done
);

localparam integer CLKS_PER_BIT= CLK_FREQ / BAUD_RATE;
localparam integer COUNT_WIDTH= (CLKS_PER_BIT<=1)? 1: $clog2(CLKS_PER_BIT);

typedef enum logic[1:0]{
    TX_IDLE,
    TX_START,
    TX_DATA,
    TX_STOP
} tx_state_t;

tx_state_t state;

logic [7:0] tx_shift;
logic [2:0] bit_count;
logic [COUNT_WIDTH-1:0] baud_count;

always_ff @(posedge clk)begin
    if(rst)begin
        state<= TX_IDLE;
        tx<= 1'b1;
        tx_done<= 1'b0;
        tx_shift<= 8'h00;
        bit_count<= 3'd0;
        baud_count<= '0;
    end
    else begin
        tx_done<= 1'b0;

        case(state)

        TX_IDLE: begin
            tx<= 1'b1;
            baud_count<= '0;
            bit_count<= 3'd0;

            if(tx_start) begin
                tx_shift<= tx_data;
                state<= TX_START;
            end
        end

        TX_START: begin
            tx<= 1'b0;
            if(baud_count== CLKS_PER_BIT-1) begin
                baud_count<= '0;
                state<= TX_DATA;
            end
            else begin
                baud_count<= baud_count+ 1'b1;
            end
        end

        TX_DATA: begin
            tx<= tx_shift[bit_count];
            if(baud_count== CLKS_PER_BIT-1) begin
                baud_count<='0;

                if(bit_count== 3'd7)begin
                    bit_count<= 3'd0;
                    state<= TX_STOP;
                end
                else begin
                    bit_count<= bit_count+ 1'b1;
                end
            end
            else begin
                baud_count<= baud_count+ 1'b1;
            end
        end

        TX_STOP: begin
            tx<= 1'b1;
            if(baud_count== CLKS_PER_BIT-1) begin
                baud_count<= '0;
                tx_done<= 1'b1;
                state<= TX_IDLE;
            end
            else begin
                baud_count<= baud_count+ 1'b1;
            end
        end

        default: begin
            state<= TX_IDLE;
            tx<= 1'b1;
        end
        endcase
    end
end
endmodule
