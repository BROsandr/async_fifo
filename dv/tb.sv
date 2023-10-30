timeunit      1ns;
timeprecision 1ps;

module tb;

  parameter DATA_WIDTH = 8;
  parameter ADDR_WIDTH = 6;

  wire [DATA_WIDTH-1:0] data_out;
  wire                  full;
  wire                  empty;
  reg [DATA_WIDTH-1:0]  data_in;
  reg                   w_en, wclk, wrst_n;
  reg                   r_en, rclk, rrst_n;

// START declaration of behavioral model
  wire [DATA_WIDTH-1:0] beh_data_out;
  wire                  beh_full;
  wire                  beh_empty;
  reg [DATA_WIDTH-1:0]  beh_data_in;
  reg                   beh_w_en;
  reg                   beh_r_en;

  beh_async_fifo #(
    .DSIZE (DATA_WIDTH),
    .ASIZE (ADDR_WIDTH)
  ) beh_async_fifo (
    .rclk,
    .wclk,
    .rrst_n,
    .wrst_n,
    .rdata (beh_data_out),
    .wdata (beh_data_in),
    .winc (beh_w_en),
    .rinc (beh_r_en),
    .wfull (beh_full),
    .rempty (beh_empty)
  );
// END declaration of behavioral model

  sva_async_full_fifo : assert property (
    @(posedge wclk) disable iff (!wrst_n)
    beh_full == full
  ) else begin
    $error("beh_full != full");
  end

  sva_async_empty_fifo : assert property (
    @(posedge rclk) disable iff (!rrst_n)
    beh_empty == empty
  ) else begin
    $error("beh_empty != empty");
  end

  // Queue to push data_in
  reg [DATA_WIDTH-1:0] wdata, tmp_data;
  logic                tmp_w_en, tmp_r_en;

  async_fifo #(
    .data_t (logic [DATA_WIDTH-1:0]),
    .DEPTH  (32)
  ) async_fifo (
    .wclk,
    .wrst_n,
    .rclk,
    .rrst_n,
    .winc (w_en),
    .rinc (r_en),
    .wdata (data_in),
    .rdata (data_out),
    .wfull (full),
    .rempty (empty)
  );

  always #10ns wclk = ~wclk;
  always #35ns rclk = ~rclk;
  
  initial begin
    wclk <= 1'b0;
    wrst_n <= 1'b0;
    w_en <= 1'b0;
    data_in <= 0;

    beh_w_en    <= 1'b0;
    beh_data_in <= 0;

    repeat(10) @(posedge wclk);
    wrst_n <= 1'b1;

    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge wclk iff !beh_full);
        tmp_w_en = (i%2 == 0)? 1'b1 : 1'b0;
        beh_w_en <= tmp_w_en;
        w_en     <= tmp_w_en;
        if (beh_w_en) begin
          tmp_data = $urandom;
          beh_data_in <= tmp_data;
          data_in     <= tmp_data;
        end
      end
      #50;
    end
  end

  initial begin
    rclk <= 1'b0;
    rrst_n <= 1'b0;
    r_en <= 1'b0;
    beh_r_en <= 1'b0;

    repeat(20) @(posedge rclk);
    rrst_n <= 1'b1;

    repeat(2) begin
      for (int i=0; i<30; i++) begin
        @(posedge rclk iff !beh_empty);
        tmp_r_en = (i%2 == 0)? 1'b1 : 1'b0;
        beh_r_en <= tmp_r_en;
        r_en     <= tmp_r_en;
        if (beh_r_en) begin
          wdata = beh_data_out;
          if(data_out !== wdata) $error("Time = %0t: Comparison Failed: expected wr_data = %h, rd_data = %h", $time, wdata, data_out);
          else $display("Time = %0t: Comparison Passed: wr_data = %h and rd_data = %h",$time, wdata, data_out);
        end
      end
      #50;
    end

    $finish;
  end
  
  initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
  end
endmodule
