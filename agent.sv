class agent extends uvm_agent;
    `uvm_component_utils(agent)

    driver drv;
    monitor mon;
    sequncer seqr;
    barrel_cfg cfg;

    //uvm_tlm_fifo#(barrel_txn) fifo_h;

    function new(string name="agent", uvm_component parent);
        super.new(name, parent);
       // fifo_h=new("fifo_h", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(barrel_cfg)::get(this, "", "barrel_cfg", cfg))
            `uvm_fatal("NOCFG", "config IS NOT WORKING")

        if(cfg.is_active==UVM_ACTIVE) begin
            drv=driver::type_id::create("drv", this);
            seqr=sequencer::type_id::create("seqr", this);
        end
        mon=monitor::type_id::create("mon", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
       if(cfg.is_active==UVM_ACTIVE) 
            /* seqr.put_port.connect(fifo_h.put_port);
                drv.get_port.connect(fifo_h.get_port);  alt method for data transfer from drv to seqr */ 
            drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction
endclass 
