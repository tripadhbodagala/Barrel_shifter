class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    
    uvm_analysis_port #(barrel_txn) mon_port;
    virtual barrel_if vif;
    barrel_cfg cfg;

    function new(string name="monitor", uvm_component parent);
        super.new(name, parent);
        mon_port=new("mon_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(barrel_cfg)::get(this,"","barrel_cfg",cfg))
            `uvm_fatal("NOCFG", "NO CONFIG IN MONIOR")
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vif=cfg.vif;
    endfunction

  /*  task run_phase(uvm_phase phase);


    endtask */

endclass

