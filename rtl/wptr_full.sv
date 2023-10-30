module wptr_full #(
  parameter int unsigned ADDR_WIDTH = 8
) (
  input                       wclk,
  input                       wrst_n,
  input      [ADDR_WIDTH  :0] wq2_rptr,
  input                       winc,
  output reg                  wfull,
  output     [ADDR_WIDTH-1:0] waddr,
  output reg [ADDR_WIDTH  :0] wptr
);

  reg  [ADDR_WIDTH:0] wbin;
  wire [ADDR_WIDTH:0] wgraynext, wbinnext;

  // GRAYSTYLE2 pointer
  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) {wbin, wptr} <= 0;
    else         {wbin, wptr} <= {wbinnext, wgraynext};

  // Memory write-address pointer (okay to use binary to address memory)
  assign waddr     = wbin[ADDR_WIDTH-1:0];

  assign wbinnext  = wbin + (winc & ~wfull);
  assign wgraynext = (wbinnext>>1) ^ wbinnext;

  //------------------------------------------------------------------
  // Simplified version of the three necessary full-tests:
  // assign wfull_val=((wgnext[ADDR_WIDTH]   !=wq2_rptr[ADDR_WIDTH]  ) &&
  //                  (wgnext[ADDR_WIDTH-1]  !=wq2_rptr[ADDR_WIDTH-1]) &&
  //                  (wgnext[ADDR_WIDTH-2:0]==wq2_rptr[ADDR_WIDTH-2:0]));
  //------------------------------------------------------------------
  assign wfull_val =  (wgraynext=={~wq2_rptr[ADDR_WIDTH  :ADDR_WIDTH-1],
                                    wq2_rptr[ADDR_WIDTH-2:0         ]});

  always @(posedge wclk or negedge wrst_n)
    if (!wrst_n) wfull <= 1'b0;
    else         wfull <= wfull_val;
endmodule
