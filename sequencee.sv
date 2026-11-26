// ===================== base: 4 simple helper tasks =====================
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


// ===================== Scenario 1: load, then left, then right =====================
class seq_basic extends base_seq;
    `uvm_object_utils(seq_basic)
    function new(string name = "seq_basic"); super.new(name); endfunction

    task body();
        reset_item();
        repeat (10) begin
            load_item($urandom_range(1, 31));
            shift_item(0, $urandom_range(1, 3));   // left shift

            load_item($urandom_range(1, 31));
            shift_item(1, $urandom_range(1, 3));   // right shift
        end
    endtask
endclass


// ===================== Scenario 2: left then immediately right =====================
class seq_dir_toggle extends base_seq;
    `uvm_object_utils(seq_dir_toggle)
    function new(string name = "seq_dir_toggle"); super.new(name); endfunction

    task body();
        reset_item();
        repeat (15) begin
            load_item($urandom_range(1, 31));
            shift_item(0, $urandom_range(1, 3));   // left
            shift_item(1, $urandom_range(1, 3));   // right, no new load
            shift_item(0, $urandom_range(1, 3));   // left again
            shift_item(1, $urandom_range(1, 3));   // right again
        end
    endtask
endclass


// ===================== Scenario 3: corner cases + random =====================
class seq_corner extends base_seq;
    `uvm_object_utils(seq_corner)
    function new(string name = "seq_corner"); super.new(name); endfunction

    task body();
        reset_item();

        // a) load priority: load = 1 while dir and shift are also set
        repeat (10) begin
            req = barrel_txn::type_id::create("req");
            start_item(req);
            req.rst_n   = 1;
            req.load    = 1;
            req.dir     = $urandom_range(0, 1);
            req.shift   = $urandom_range(1, 3);   // non-zero, but must be ignored
            req.data_in = $urandom_range(1, 31);
            finish_item(req);
        end

        // b) maximum shift = 3
        load_item(5'b11111);  shift_item(0, 3);   // expect 11000
        load_item(5'b11111);  shift_item(1, 3);   // expect 00011
        load_item(5'b00001);  shift_item(0, 3);   // expect 01000
        load_item(5'b10000);  shift_item(1, 3);   // expect 00010

        // c) shift = 0 : result must not change
        load_item(5'b10101);
        shift_item(0, 0);
        shift_item(1, 0);

        // d) fully random for many cycles
        repeat (300) random_item();
    endtask
endclass


// ===================== runs all three (used by your current test) =====================
class sequencee extends base_seq;
    `uvm_object_utils(sequencee)
    function new(string name = "sequencee"); super.new(name); endfunction

    task body();
        seq_basic      s1;
        seq_dir_toggle s2;
        seq_corner     s3;

        s1 = seq_basic::type_id::create("s1");
        s2 = seq_dir_toggle::type_id::create("s2");
        s3 = seq_corner::type_id::create("s3");

        s1.start(m_sequencer);
        s2.start(m_sequencer);
        s3.start(m_sequencer);
    endtask
endclass

/*class sequencee extends uvm_sequence #(barrel_txn);
    `uvm_object_utils(sequencee)

    function new(string name = "sequencee");
        super.new(name);
    endfunction
   task body();
            req = barrel_txn::type_id::create("req");
            start_item(req);
            if (!req.randomize() with {rst_n == 0;})            
            `uvm_fatal("SEQ", "rst randomization failed")
            finish_item(req);

            start_item(req);
            if(!req.randomize() with {rst_n==1; load == 1;})
            `uvm_fatal("SEQ", "load randomization failed")
            finish_item(req);

            repeat(20) begin
            start_item(req);
            if(!req.randomize() with {rst_n==1; load ==0;})
            `uvm_fatal("SEQ", "data randomization failed")
            finish_item(req);
            end
    endtask 
endclass */