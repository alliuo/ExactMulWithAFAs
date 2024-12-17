
module RM8u1 (
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output wire [15:0] product
);

    wire [7:0] pp_hh, pp_hl, pp_lh, pp_ll;

    RM4uM MUL_HH (.a(a[7:4]), .b(b[7:4]), .out(pp_hh));
    RM4u4 MUL_HL (.a(a[7:4]), .b(b[3:0]), .out(pp_hl));
    RM4u4 MUL_LH (.a(a[3:0]), .b(b[7:4]), .out(pp_lh));
    RM4u1 MUL_LL (.a(a[3:0]), .b(b[3:0]), .out(pp_ll));

    // RCA stage 0
    wire [8:0] tmp_sum;
    rca_8bit ADD_0 (.a(pp_hl), .b(pp_lh), .cout(tmp_sum[8]), .sum(tmp_sum[7:0]));

    // RCA Stage 1
    wire       cla_cin;
    wire [2:0] carry;

    assign product[3:0] = pp_ll[3:0];
    HA RCA_HA0 (.a(tmp_sum[0]), .b(pp_ll[4]), .cout(cla_cin), .sum(product[4]));
    cla_8bit ADD_1 (.a(tmp_sum[8:1]), .b({{pp_hh[4:0]}, {pp_ll[7:5]}}), .cin(cla_cin), .cout(carry[0]), .sum(product[12:5]));
    HA RCA_HA1 (.a(pp_hh[5]), .b(carry[0]), .cout(carry[1]), .sum(product[13]));
    HA RCA_HA2 (.a(pp_hh[6]), .b(carry[1]), .cout(carry[2]), .sum(product[14]));
    assign product[15] = pp_hh[7] | carry[2];
    
endmodule    
