// Greg Stitt
// University of Florida

// This class defines a sequence to test each multiplier input. It simply
// creates random axi4_stream_seq_items.

`ifndef _MULT_SEQUENCE_SVH_
`define _MULT_SEQUENCE_SVH_

`include "uvm_macros.svh"
import uvm_pkg::*;

// Since the mult application does not require changing the default parameter values
// of the interface (other than the DATA_WIDTH), this class requires no changes.
class mult_sequence extends uvm_sequence #(axi4_stream_seq_item #(mult_tb_pkg::INPUT_WIDTH));
    `uvm_object_utils(mult_sequence)

    int num_tests;

    function new(string name = "mult_sequence");
        super.new(name);
        if (!uvm_config_db#(int)::get(this, "", "num_tests", num_tests)) `uvm_fatal("NO_NUM_TESTS", "num_tests not specified.");
    endfunction

    virtual task body();
        for (int i = 0; i < num_tests; i++) begin
            req = axi4_stream_seq_item#(mult_tb_pkg::INPUT_WIDTH)::type_id::create($sformatf("req%0d", i));
            wait_for_grant();

            // Create a custom distribution to ensure that we achieve 100% 
            // coverage, which requires testing with 0 and the maximum sized
            // values.
            //
            // IMPORTANT: Note that we are doing the randomization here instead
            // of in the sequence item class like before. The reason for this
            // is that the sequence item is AXI specific, so it doesn't make
            // sense to put application-specific constraints on the interface.
            void'(req.randomize() with {
                tdata dist {
                    '0                                      :/ 2,
                    '1                                      :/ 2,
                    [0 : 2 ** mult_tb_pkg::INPUT_WIDTH - 2] :/ 96
                };
            });
            
            send_request(req);
            wait_for_item_done();
        end
    endtask
endclass


`endif
