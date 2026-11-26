module top;
    import barrel_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    bit clk;
    initial forever #5 clk = ~clk;

    barrel_if INTF(clk);

    barrel_shifter DUT(.clk(clk),
                        .rst_n(INTF.rst_n),
                        .load(INTF.load),
                        .shift(INTF.shift),
                        .data_in(INTF.data_in),
                        .result(INTF.result),
                        .dir(INTF.dir));

    initial begin   
        `ifdef VCS
        $fsdbDumpvars(0,top);
  `endif

          uvm_config_db #(virtual barrel_if)::set(null,"*","barrel_if", INTF);
          //call run_test
          run_test("test");
        end
endmodule