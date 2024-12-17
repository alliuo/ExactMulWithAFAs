module rca_8bit (
    input  wire [7:0] a,
    input  wire [7:0] b,
    output wire       cout,
    output wire [7:0] sum 
);
    // RCA
    wire [6:0] rca_c;

    HA HA0 (.a(a[0]), .b(b[0]),                 .cout(rca_c[0]), .sum(sum[0]));
    FA FA0 (.a(a[1]), .b(b[1]), .cin(rca_c[0]), .cout(rca_c[1]), .sum(sum[1]));
    FA FA1 (.a(a[2]), .b(b[2]), .cin(rca_c[1]), .cout(rca_c[2]), .sum(sum[2]));
    FA FA2 (.a(a[3]), .b(b[3]), .cin(rca_c[2]), .cout(rca_c[3]), .sum(sum[3]));
    FA FA3 (.a(a[4]), .b(b[4]), .cin(rca_c[3]), .cout(rca_c[4]), .sum(sum[4]));
    FA FA4 (.a(a[5]), .b(b[5]), .cin(rca_c[4]), .cout(rca_c[5]), .sum(sum[5]));
    FA FA5 (.a(a[6]), .b(b[6]), .cin(rca_c[5]), .cout(rca_c[6]), .sum(sum[6]));
    FA FA6 (.a(a[7]), .b(b[7]), .cin(rca_c[6]), .cout(cout),     .sum(sum[7]));
    
endmodule
