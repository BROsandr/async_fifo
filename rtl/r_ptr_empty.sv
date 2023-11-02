module r_ptr_empty #(
  parameter int unsigned ADDR_WIDTH = 8
) (
  input                       clk_r_i,
  input                       rst_r_ni,
  input      [ADDR_WIDTH  :0] w2r_ptr_i,
  input                       r_en_i,
  output reg                  r_empty_o,
  output     [ADDR_WIDTH-1:0] r_addr_o,
  output reg [ADDR_WIDTH  :0] r_ptr_o
);

  reg  [ADDR_WIDTH:0] r_bin;
  wire [ADDR_WIDTH:0] r_gray_next, r_bin_next;

  //-------------------
  // GRAYSTYLE2 pointer
  //-------------------
  always @(posedge clk_r_i or negedge rst_r_ni)
    if   (!rst_r_ni) {r_bin, r_ptr_o} <= 0;
    else             {r_bin, r_ptr_o} <= {r_bin_next, r_gray_next};

  // Memory read-address pointer (okay to use binary to address memory)
  assign r_addr_o     = r_bin[ADDR_WIDTH-1:0];

  assign r_bin_next  = r_bin + (r_en_i & ~r_empty_o);
  assign r_gray_next = (r_bin_next>>1) ^ r_bin_next;

  //---------------------------------------------------------------
  // FIFO empty when the next r_ptr == synchronized w_ptr or on reset
  //---------------------------------------------------------------
  logic r_empty_ff;
  logic r_empty_next;

  assign r_empty_next = (r_gray_next == w2r_ptr_i);

  always @(posedge clk_r_i or negedge rst_r_ni) begin
    if   (!rst_r_ni) r_empty_ff <= 1'b1;
    else             r_empty_ff <= r_empty_next;
  end

  assign r_empty_o = r_empty_ff;
endmodule
