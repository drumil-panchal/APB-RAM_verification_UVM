`include "uvm_macros.svh"
import uvm_pkg::*;



///configuration of environment
class apb_config extends uvm_object;
    `uvm_object_utils(apb_config)
    
    function new(input string path = "apb_config");
        super.new(path);
    endfunction
    
    uvm_active_passive_enum agent_type = UVM_ACTIVE;
endclass



typedef enum bit [1:0] {read_d=0, write_d=1, rst=2} oper_mode;



///transaction///
class transaction extends uvm_sequence_item;
    
    function new(input string path = "transaction");
        super.new(path);
    endfunction
    
    rand oper_mode op;
    rand logic [31:0] PWDATA;
    rand logic [31:0] PADDR;
    
    logic PWRITE;
    logic PREADY;
    logic PSLVERR;
    logic [31:0] PRDATA;
    
    `uvm_object_utils_begin(transaction)
    `uvm_field_int (PWRITE, UVM_ALL_ON)
    `uvm_field_int (PWDATA, UVM_ALL_ON)
    `uvm_field_int (PADDR, UVM_ALL_ON)
    `uvm_field_int (PREADY, UVM_ALL_ON)
    `uvm_field_int (PSLVERR, UVM_ALL_ON)
    `uvm_field_int (PRDATA, UVM_ALL_ON)
    `uvm_field_enum (oper_mode, op, UVM_DEFAULT)
    `uvm_object_utils_end
    
    constraint addr_c {PADDR<31;}           ///for checking normal write mode
    constraint addr_c_err {PADDR > 31;}     ///for generating SLV error
endclass



///generator///

///write sequence
class write_data extends uvm_sequence#(transaction);
    `uvm_object_utils(write_data)
    
    transaction t;
    
    function new(input string path = "write_data");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(1); //enables 1st constraint
                t.addr_c_err.constraint_mode(0); //disables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = write_d;
                finish_item(t);
            end
    endtask
endclass

///read reqeunce
class read_data extends uvm_sequence#(transaction);
    `uvm_object_utils(read_data)
    
    transaction t;
    
    function new(input string path = "read_data");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(1); //enables 1st constraint
                t.addr_c_err.constraint_mode(0); //disables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = read_d;
                finish_item(t);
            end
    endtask
endclass

///write and then read sequence
class write_read extends uvm_sequence#(transaction);
    `uvm_object_utils(write_read)
    
    transaction t;
    
    function new(input string path = "write_read");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(1); //enables 1st constraint
                t.addr_c_err.constraint_mode(0); //disables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = write_d;
                finish_item(t);
                
                start_item(t);
                    assert(t.randomize());
                    t.op = read_d;
                finish_item(t);
            end
    endtask
endclass

//write bulk data and read it
class writeb_readb extends uvm_sequence#(transaction);
    `uvm_object_utils(writeb_readb)
    
    transaction t;
    
    function new(input string path = "writeb_readb");
        super.new(path);
    endfunction
    
    virtual task body();
    
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(1); //enables 1st constraint
                t.addr_c_err.constraint_mode(0); //disables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = write_d;
                finish_item(t);
            end
            
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(1); //enables 1st constraint
                t.addr_c_err.constraint_mode(0); //disables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = read_d;
                finish_item(t);
            end
    endtask
endclass

//slv error for write operation
class write_err extends uvm_sequence#(transaction);
    `uvm_object_utils(write_err)
    
    transaction t;
    
    function new(input string path = "write_err");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(0); //disables 1st constraint
                t.addr_c_err.constraint_mode(1); //enables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = write_d;
                finish_item(t);
            end
    endtask
endclass

///slv error for read operation
class read_err extends uvm_sequence#(transaction);
    `uvm_object_utils(read_err)
    
    transaction t;
    
    function new(input string path = "read_err");
        super.new(path);
    endfunction
    
    virtual task body();
        repeat(15)
            begin
                t = transaction :: type_id :: create("t");
                
                t.addr_c.constraint_mode(0); //disables 1st constraint
                t.addr_c_err.constraint_mode(1); //enables 2nd constraint
                
                start_item(t);
                    assert(t.randomize());
                    t.op = read_d;
                finish_item(t);
            end
    endtask
endclass

class reset_dut extends uvm_sequence#(transaction);
  `uvm_object_utils(reset_dut)
  
  transaction tr;

  function new(string name = "reset_dut");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(15)
      begin
        tr = transaction::type_id::create("tr");
        tr.addr_c.constraint_mode(1);
        tr.addr_c_err.constraint_mode(0);
        
        start_item(tr);
        assert(tr.randomize);
        tr.op = rst;
        finish_item(tr);
      end
  endtask
  

endclass



///driver///
class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)
    
    transaction t;
    virtual apb_if vif;
    
    function new(input string path = "driver", uvm_component parent = null);
        super.new(path, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        t = transaction :: type_id :: create("t");
        if(!uvm_config_db #(virtual apb_if) :: get(this, "", "vif", vif))
            `uvm_error("DRV", "Unable to access interface")
    endfunction
    
    task reset_dut();
        repeat(5)
            begin
                vif.presetn <= 1'b0;
                vif.paddr <= 'h0;
                vif.pwdata <= 'h0;
                vif.pwrite <= 'b0;
                vif.psel <= 'b0;
                vif.penable <= 'b0;
                `uvm_info("DRV", "system reset", UVM_MEDIUM);
                @(posedge vif.pclk);
            end
    endtask
    
    task drive();
        reset_dut();
        
        forever begin
            seq_item_port.get_next_item(t);
                
                if(t.op == rst)
                    begin
                        vif.presetn <= 1'b0;
                        vif.paddr <= 'h0;
                        vif.pwdata <= 'h0;
                        vif.pwrite <= 'b0;
                        vif.psel <= 'b0;
                        vif.penable <= 'b0;                     
                    end
                    
                else if(t.op == write_d)
                    begin
                        vif.presetn <= 1'b1;
                        vif.paddr <= t.PADDR;
                        vif.pwdata <= t.PWDATA;
                        vif.pwrite <= 1'b1;     //write mode
                        vif.psel <= 1'b1;
                        @(posedge vif.pclk);
                        vif.penable <= 1'b1;
                        `uvm_info("DRV", $sformatf("mode:%0s | addr=%0d | wdata=%0d | rdata=%0d | slverr=%0d", t.op.name(), t.PADDR, t.PWDATA, t.PRDATA, t.PSLVERR), UVM_NONE)
                        @(negedge vif.pready);
                        vif.penable <= 1'b0;
                        t.PSLVERR = vif.pslverr;
                    end
                    
                else if(t.op == read_d)
                    begin
                        vif.presetn <= 1'b1;
                        vif.paddr <= t.PADDR;
                        vif.pwrite <= 1'b0;     //read mode
                        vif.psel <= 1'b1;
                        @(posedge vif.pclk);
                        vif.penable <= 1'b1;
                        `uvm_info("DRV", $sformatf("mode:%0s | addr=%0d | wdata=%0d | rdata=%0d | slverr=%0d", t.op.name(), t.PADDR, t.PWDATA, t.PRDATA, t.PSLVERR), UVM_NONE)
                        @(negedge vif.pready);
                        vif.penable <= 1'b0;
                        t.PRDATA = vif.prdata;
                        t.PSLVERR = vif.pslverr;
                    end                 
                
            seq_item_port.item_done();
        end
    endtask
    
    virtual task run_phase(uvm_phase phase);
        drive();
    endtask
endclass



///monitor///
class monitor extends uvm_monitor;
    `uvm_component_utils(monitor)
    
    transaction t;
    uvm_analysis_port #(transaction) send;
    virtual apb_if vif;
    
    function new(input string path = "monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction 
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        t = transaction :: type_id :: create("t");
        send = new("send", this);
        if(!uvm_config_db #(virtual apb_if) :: get(this, "", "vif", vif))
            `uvm_error("MON", "Unable to access interface");
    endfunction
    
    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.pclk);
            
            if(!vif.presetn)
                begin
                    t.op = rst;
                    `uvm_info("MON", "System reset detected", UVM_NONE)
                    send.write(t);
                end
                
            else if(vif.presetn && vif.pwrite)
                begin
                    @(negedge vif.pready);
                    t.op = write_d;
                    t.PWDATA = vif.pwdata;
                    t.PADDR = vif.paddr;
                    t.PSLVERR = vif.pslverr;
                    `uvm_info("MON", $sformatf("data write: addr=%0d | data=%0d | slverr=%0d", t.PADDR, t.PWDATA, t.PSLVERR), UVM_NONE)
                    send.write(t);
                end
                
            else if(vif.presetn && !vif.pwrite)
                begin
                    @(negedge vif.pready);
                    t.op = read_d;
                    t.PADDR = vif.paddr;
                    t.PRDATA = vif.prdata;
                    t.PSLVERR = vif.pslverr;
                    `uvm_info("MON", $sformatf("read write: addr=%0d | data=%0d | slverr=%0d", t.PADDR, t.PWDATA, t.PSLVERR), UVM_NONE)
                    send.write(t);
                end
        end
    endtask
endclass



///scoreboard///
class sco extends uvm_scoreboard;
    `uvm_component_utils(sco)
    
    uvm_analysis_imp #(transaction, sco) recv;
    bit [31:0] arr[32] = '{default:0};  //temp variable to store write data
    bit [31:0] addr = 0;                //temp variable to store address
    bit [31:0] data_rd = 0;             //temp variable to store read_data
    
    function new(input string path = "monitor", uvm_component parent = null);
        super.new(path, parent);
    endfunction    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        recv = new("recv", this);
    endfunction
    
    virtual function void write(transaction t);
        
        if(t.op == rst)
            begin
                `uvm_info("SCO", "System reset detected", UVM_NONE)
            end
            
        else if(t.op == write_d)
            begin
            
                if(t.PSLVERR == 1'b1)
                    begin
                        `uvm_info("SCO", " SLV error during write operation", UVM_NONE)
                    end
                    
                 else
                    begin
                        arr[t.PADDR] = t.PWDATA;
                        `uvm_info("SCO", $sformatf("Write op: addr=%0d | wdata=%0d | arr_w=%0d", t.PADDR, t.PWDATA, arr[t.PADDR]), UVM_NONE)
                    end 
            end
            
        else if(t.op == read_d)
            begin
            
                if(t.PSLVERR == 1'b1)
                    begin
                        `uvm_info("SCO", " SLV error during read operation", UVM_NONE)
                    end
                    
                else
                    begin
                        data_rd = arr[t.PADDR];
                        if(data_rd == t.PRDATA)
                            `uvm_info("SCO", $sformatf("Data matched: addr=%0d | rdata=%0d", t.PADDR, t.PRDATA), UVM_NONE)
                            
                        else
                            `uvm_info("SCO", $sformatf("Test failed: addr=%0d | rdata=%0d | data_rd_arr", t.PADDR, t.PRDATA, data_rd), UVM_NONE)
                    end 
            end   
            
    $display("---------------------------------------------------------------------------------");       
    endfunction 
endclass



///agent///
class agent extends uvm_agent;
    `uvm_component_utils(agent)
    
    apb_config cfg;
    driver d;
    monitor m;
    uvm_sequencer #(transaction) seqr;
    
    function new(input string path = "agent", uvm_component parent = null);
        super.new(path, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        cfg = apb_config :: type_id :: create("cgf");
        m = monitor :: type_id :: create("m", this);
        
        if(cfg.agent_type == UVM_ACTIVE)
            begin
                d = driver :: type_id :: create("d", this);
                seqr = uvm_sequencer #(transaction) :: type_id :: create("seqr", this);
            end
    endfunction 
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(cfg.agent_type == UVM_ACTIVE)
            begin
                d.seq_item_port.connect(seqr.seq_item_export);
            end 
    endfunction
endclass



///environment///
class env extends uvm_env;
    `uvm_component_utils(env)
    
    agent a;
    sco s;
    
    function new(input string path = "env", uvm_component parent = null);
        super.new(path, parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a = agent :: type_id :: create("a", this);
        s = sco :: type_id :: create("s", this);
    endfunction 
    
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        a.m.send.connect(s.recv);
    endfunction     
endclass 



///test///
class test extends uvm_test;
    `uvm_component_utils(test)
    
    env e;
    write_data wd;
    read_data rd;
    write_read wr;
    writeb_readb wbrb;
    write_err we;
    read_err re;
    reset_dut rstd;
    
    
    function new(input string path = "test", uvm_component parent = null);
        super.new(path, parent);
    endfunction  
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        e = env :: type_id :: create("env", this);
        wd = write_data :: type_id :: create("wd");
        rd = read_data :: type_id :: create("rd");
        wr = write_read :: type_id :: create("wr");
        wbrb = writeb_readb :: type_id :: create("wbrb");
        we = write_err :: type_id :: create("we");
        re = read_err :: type_id :: create("re");
        rstd = reset_dut :: type_id :: create("rstd");
    endfunction   
    
    virtual task run_phase(uvm_phase phase);
        phase.raise_objection(this);
            wbrb.start(e.a.seqr);
            #20;
        phase.drop_objection(this);
    endtask      
endclass



///top///
module tb;
  apb_if vif();
  
  apb_ram dut (.presetn(vif.presetn), .pclk(vif.pclk), .psel(vif.psel), .penable(vif.penable), .pwrite(vif.pwrite), .paddr(vif.paddr), .pwdata(vif.pwdata), .prdata(vif.prdata), .pready(vif.pready), .pslverr(vif.pslverr));
  
  initial begin
    vif.pclk <= 0;
  end

   always #10 vif.pclk <= ~vif.pclk;

  initial begin
    uvm_config_db#(virtual apb_if)::set(null, "*", "vif", vif);
    run_test("test");
   end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule