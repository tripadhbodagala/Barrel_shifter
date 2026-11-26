class barrel_txn extends uvm_sequence_item;
    `uvm_object_utils(barrel_txn)
    bit clk;
    rand bit rst_n,load,dir;
    rand bit [1:0] shift;
    rand bit[4:0] data_in;
    bit [4:0] result;
    function new (string name="barrel_txn");
        super.new(name);
    endfunction

function void do_print(uvm_printer printer);
    super.do_print(printer);
        printer.print_field("rst_n",this.rst_n,1,UVM_BIN);
        printer.print_field("load",this.load,1,UVM_BIN);
        printer.print_field("dir",this.dir,1,UVM_BIN);
        printer.print_field("shift",this.shift,2,UVM_BIN);
        printer.print_field("data_in",this.data_in,5,UVM_BIN);
       printer.print_field("result",this.result,5,UVM_BIN); 
endfunction

endclass