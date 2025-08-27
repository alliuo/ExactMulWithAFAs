`timescale 1ns / 1ps

module top_sim();
    wire [7:0] out;
    reg  [3:0] a;
    reg  [3:0] b;

    {UNIT_NAME} top (.{INPUT0}(a), .{INPUT1}(b), .out(out));
    
    initial
    begin
        `ifdef DUMP_VPD
                $vcdpluson();
        `endif
        a = {{$random}}%16;
        b = {{$random}}%16;
        #1000000
        `ifdef DUMP_VPD
                $vcdplusoff();
        `endif
        $finish;
    end

    always
    begin
        forever #1   begin b = {{$random}}%16;end
    end
    always
    begin
        forever #1   begin a = {{$random}}%16;end
    end

endmodule