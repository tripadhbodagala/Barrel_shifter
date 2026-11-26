interface barrel_if(input bit clk);
    logic rst_n,load, dir;
    logic [1:0] shift;
    logic [4:0] data_in;
    logic [4:0] result;

    clocking drv_cb@(posedge clk);
        default input #1 output #1;
        output rst_n, load, dir, shift, data_in;
        input result;
    endclocking
    clocking mon_cb@(posedge clk);
       default input #1 output #1;
        input rst_n, load, dir, shift, data_in;
        input result;
    endclocking 

    modport drv_mp(clocking drv_cb);
    modport mon_mp(clocking mon_cb);
endinterface