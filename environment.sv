class environment extends uvm_env;
`uvm_component_utils(environment)
    agent agt;
    scoreboard sb;
    barrel_cfg cfg;
    env_cfg e_cfg;

    function new(string name= "environment", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(env_cfg)::get(this, "","env_cfg",e_cfg))
            `uvm_fatal("NOENVCFG","ENVIRONMENT CFG IS NOT WORKING")
        
        if(e_cfg.has_agents==1) begin  
            uvm_config_db #(barrel_cfg)::set(this, "agt*","barrel_cfg",e_cfg.cfg);
                agt = agent::type_id::create("agt", this);
        end

        if(e_cfg.has_scoreboard==1) begin  
            sb = scoreboard::type_id::create("sb", this);
        end
    endfunction
            
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(e_cfg.has_agents ==1 && e_cfg.has_scoreboard==1)
            agt.mon.mon_port.connect(sb.item_export.analysis_export); //connection btw mon and sb
    endfunction
endclass
