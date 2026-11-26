class base_seq extends uvm_sequence #(barrel_txn);
    `uvm_object_utils(base_seq)

    function new(string name = "base_seq");
        super.new(name);
    endfunction

    // reset for one clock
    task reset_item();
        req = barrel_txn::type_id::create("req");
        start_item(req);
        req.rst_n   = 0;
        req.load    = 0;
        req.dir     = 0;
        req.shift   = 0;
        req.data_in = 0;
        finish_item(req);
    endtask

    // load = 1 : result should become d
    task load_item(bit [4:0] d);
        req = barrel_txn::type_id::create("req");
        start_item(req);
        req.rst_n   = 1;
        req.load    = 1;
        req.dir     = 0;
        req.shift   = 0;
        req.data_in = d;
        finish_item(req);
    endtask

    // load = 0 : shift result. d = 0 left, 1 right ; s = shift amount
    task shift_item(bit d, bit [1:0] s);
        req = barrel_txn::type_id::create("req");
        start_item(req);
        req.rst_n   = 1;
        req.load    = 0;
        req.dir     = d;
        req.shift   = s;
        req.data_in = $urandom;   // ignored by the DUT when load = 0
        finish_item(req);
    endtask

    // everything random (no reset)
    task random_item();
        req = barrel_txn::type_id::create("req");
        start_item(req);
        if (!req.randomize() with {rst_n == 1;})
            `uvm_fatal("SEQ", "randomization failed")
        finish_item(req);
    endtask
endclass
