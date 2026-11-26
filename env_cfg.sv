class env_cfg extends uvm_object;
    `uvm_object_utils(env_cfg)

    barrel_cfg cfg;
    bit has_agents =1;
    bit has_scoreboard=1;

    function new (string name="env_cfg");
        super.new(name);
    endfunction

endclass