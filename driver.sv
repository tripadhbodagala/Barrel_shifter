class driver extends uvm_driver#(barrel_txn);
    `uvm_component_utils(driver)

    virtual barrel_if vif;
    barrel_cfg cfg;

    function new(string name="driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(barrel_cfg)::get(this,"","barrel_cfg",cfg))
            `uvm_fatal("NOCFG","CFG IS NOT WORKING IN DRVIER")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif=cfg.vif;
    endfunction 

    task run_phase(uvm_phase phase);
    //sample reset values
    @(vif.drv_cb);
    vif.drv_cb.rst_n <= 1;
    vif.drv_cb.load <= 0;
    vif.drv_cb.dir <= 0;
    vif.drv_cb.shift <= 0;
    vif.drv_cb.data_in <= 0;
    repeat(2) @(vif.drv_cb);
    //starting the forever loop to get the transaction from sequencer and drive it onto DUT
    forever begin
        seq_item_port.get_next_item(req);
        drive_dut(req);
        seq_item_port.item_done();
    end
    endtask
    //sampling all the data points from txn onto vif 
    task drive_dut(barrel_txn txn);
        @(vif.drv_cb);
        vif.drv_cb.rst_n <= txn.rst_n;
        vif.drv_cb.load <= txn.load;
        vif.drv_cb.dir <= txn.dir;
        vif.drv_cb.shift <= txn.shift;
        vif.drv_cb.data_in <= txn.data_in;
    endtask
endclass
    