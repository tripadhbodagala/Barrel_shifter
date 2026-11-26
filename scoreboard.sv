class scoreboard extends uvm_scoreboard;
    `uvm_component_utils(scoreboard)

    uvm_tlm_analysis_fifo #(barrel_txn) item_export;

    bit [4:0] expected;    // reference model output
    bit [4:0] din;         // inputs stored from the PREVIOUS sample
    bit [1:0] shift;
    bit       load, dir;
    bit       rst;         // holds rst_n (active low)

    int pass_cnt, fail_cnt;

    covergroup barrel_cg;
        option.per_instance = 1;
        option.comment      = "barrel shifter coverage";

        shift_cp : coverpoint shift { bins high = {[2:3]}; bins low = {[0:1]}; }
        load_cp  : coverpoint load  { bins high = {1};     bins low = {0}; }
        dir_cp   : coverpoint dir   { bins right = {1};    bins left = {0}; }  // 1 = right, 0 = left
        rst_cp   : coverpoint rst   { bins high = {1};     bins low = {0}; }

        dout_cp  : coverpoint expected { bins low    = {[0:10]};
                                         bins middle = {[11:20]};
                                         bins high   = {[21:31]}; }

        din_cp   : coverpoint din { bins empty  = {0};
                                    bins low    = {[1:10]};
                                    bins middle = {[11:20]};
                                    bins high   = {[21:30]};
                                    bins full   = {31}; }
    endgroup

    function new(string name = "scoreboard", uvm_component parent);
        super.new(name, parent);
        barrel_cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_export = new("item_export", this);
    endfunction

    task run_phase(uvm_phase phase);
        barrel_txn txn;
        forever begin
            item_export.get(txn);
            ref_model(txn);
        end
    endtask

    // Monitor at edge N gives: inputs for edge N + result from BEFORE edge N.
    // So: predict from the inputs stored last time, compare, then store this sample's inputs.
    function void ref_model(barrel_txn txn);

        // 1. PREDICT
        if (!txn.rst_n || !rst)            // async reset: rst_n low now (or last cycle) -> result already 0
            expected = '0;
        else if (load)
            expected = din;
        else if (dir)                      // dir = 1 -> right shift
            expected = expected >> shift;
        else                               // dir = 0 -> left shift
            expected = expected << shift;
        // 2. COMPARE
        if (expected == txn.result) begin
            pass_cnt++;
            `uvm_info("PASS", $sformatf("expected=%b actual=%b | pass count=%0d",
                                        expected, txn.result, pass_cnt), UVM_LOW)
        end
        else begin
            fail_cnt++;
            `uvm_error("FAIL", $sformatf("expected=%b actual=%b | prev inputs: rst_n=%0b load=%0b dir=%0b shift=%0d din=%b | fail count=%0d",
                                         expected, txn.result, rst, load, dir, shift, din, fail_cnt))
        end

        // 3. STORE this sample's inputs for the next prediction
        din   = txn.data_in;
        shift = txn.shift;
        load  = txn.load;
        rst   = txn.rst_n;
        dir   = txn.dir;

        // 4. COVERAGE on every sample, not only on a pass
        barrel_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SB_REPORT", $sformatf(
            "\n========== SCOREBOARD ==========\n  pass count : %0d\n  fail count : %0d\n  coverage   : %.2f%%\n  RESULT     : %s\n================================",
            pass_cnt, fail_cnt, barrel_cg.get_inst_coverage(),
            (fail_cnt == 0) ? "TEST PASSED" : "TEST FAILED"), UVM_NONE)
    endfunction

endclass