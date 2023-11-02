module w_ptr_full #(
  parameter int unsigned ADDR_WIDTH = 8
) (
  input                       clk_w_i,
  input                       rst_w_ni,
  input      [ADDR_WIDTH  :0] r2w_ptr_i,
  input                       w_en_i,
  output reg                  w_full_o,
  output     [ADDR_WIDTH-1:0] w_addr_o,
  output reg [ADDR_WIDTH  :0] w_ptr_o
);

  reg  [ADDR_WIDTH:0] w_bin;
  wire [ADDR_WIDTH:0] w_gray_next, w_bin_next;

  // GRAYSTYLE2 pointer
  always @(posedge clk_w_i or negedge rst_w_ni)
    if   (!rst_w_ni) {w_bin, w_ptr_o} <= 0;
    else             {w_bin, w_ptr_o} <= {w_bin_next, w_gray_next};

  // Memory write-address pointer (okay to use binary to address memory)
  assign w_addr_o  = w_bin[ADDR_WIDTH-1:0];

  assign w_bin_next  = w_bin + (w_en_i & ~w_full_o);
  assign w_gray_next = (w_bin_next>>1) ^ w_bin_next;

  //------------------------------------------------------------------
  // Simplified version of the three necessary full-tests:
  // assign wfull_val=((wgnext[ADDR_WIDTH]   !=wq2_rptr[ADDR_WIDTH]  ) &&
  //                  (wgnext[ADDR_WIDTH-1]  !=wq2_rptr[ADDR_WIDTH-1]) &&
  //                  (wgnext[ADDR_WIDTH-2:0]==wq2_rptr[ADDR_WIDTH-2:0]));
  //------------------------------------------------------------------
  logic  w_full_next;
  assign w_full_next =  (w_gray_next=={~r2w_ptr_i[ADDR_WIDTH  :ADDR_WIDTH-1],
                                        r2w_ptr_i[ADDR_WIDTH-2:0           ]});

  always @(posedge clk_w_i or negedge rst_w_ni)
    if   (!rst_w_ni) w_full_o <= 1'b0;
    else             w_full_o <= w_full_next;
endmodule
