class barrel_cfg extends uvm_object;
    `uvm_object_utils(barrel_cfg)

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    virtual barrel_if vif;
    function new (string name="barrel_cfg");
        super.new(name);
    endfunction
endclass
