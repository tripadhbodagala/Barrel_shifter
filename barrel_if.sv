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

     property rst_n_1;
        @(posedge clk && negedge rst_n)
        !rst_n |=> result == 0;
    endproperty

    property load_1;
        @(posedge clk) disable iff(!rst_n);
        load |=> result == data_in;
    endproperty

    property shift_left;
        @(posedge clk) disable iff(!rst_n);
        (!load && dir == 0) |=> result ==($past(shift)==2'b00)?$past(result):
        ($past(shift)==2'b01)?{$past(result[3:0]),1'b0}:
        ($past(shift)==2'b10)?{$past(result[2:0]),2'b00}:
        {$past(result[1:0]),3'b000};
    endproperty

    property shift_right;
        @(posedge clk) disable iff(!rst_n);
        (!load && dir == 1) |=> result ==($past(shift)==2'b00)?$past(result):
        ($past(shift)==2'b01)?{1'b0,$past(result[4:1])}:
        ($past(shift)==2'b10)?{2'b00,$past(result[4:2])}:
        {3'b000,$past(result[4:3])};
    endproperty
endinterface
