class sequencer extends uvm_sequencer#(barrel_txn);
    `uvm_component_utils(sequencer)

    function new(string name ="sequncer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass 
