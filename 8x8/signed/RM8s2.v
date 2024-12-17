
module RM8s2 (
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output wire [15:0] product
);

    wire [7:0] pp_hh, pp_hl, pp_lh, pp_ll;

    RM4s0 MUL_HH (.a(a[7:4]), .b(b[7:4]), .out(pp_hh));
    RM4su2 MUL_HL (.s(a[7:4]), .u(b[3:0]), .out(pp_hl));
    RM4su2 MUL_LH (.s(b[7:4]), .u(a[3:0]), .out(pp_lh));
    RM4u6 MUL_LL (.a(a[3:0]), .b(b[3:0]), .out(pp_ll));

    // RCA stage 0
    wire [8:0] tmp_sum;
    rca_8bit ADD_0 (.a({~pp_hl[7], pp_hl[6:0]}), .b({~pp_lh[7], pp_lh[6:0]}), .cout(tmp_sum[8]), .sum(tmp_sum[7:0]));

    // RCA Stage 1
    wire [3:0] tmp_sum1;
    wire [2:0] carry1;
    assign tmp_sum1[0] = ~pp_hh[4];
    assign carry1[0] = pp_hh[4];
    assign tmp_sum1[1] = ~(pp_hh[5] ^ carry1[0]);
    assign carry1[1] = pp_hh[5] | carry1[0];
    assign tmp_sum1[2] = ~(pp_hh[6] ^ carry1[1]);
    assign carry1[2] = pp_hh[6] | carry1[1];
    assign tmp_sum1[3] = ~(~pp_hh[7] & carry1[2]);

    // RCA Stage 2
    wire       cla_cin;
    wire [2:0] carry;

    assign product[3:0] = pp_ll[3:0];
    HA RCA_HA0 (.a(tmp_sum[0]), .b(pp_ll[4]), .cout(cla_cin), .sum(product[4]));
    cla_8bit ADD_1 (.a(tmp_sum[8:1]), .b({tmp_sum1[0], pp_hh[3:0], pp_ll[7:5]}), .cin(cla_cin), .cout(carry[0]), .sum(product[12:5]));
    HA RCA_HA1 (.a(tmp_sum1[1]), .b(carry[0]), .cout(carry[1]), .sum(product[13]));
    HA RCA_HA2 (.a(tmp_sum1[2]), .b(carry[1]), .cout(carry[2]), .sum(product[14]));
    assign product[15] = tmp_sum1[3] & ~carry[2];
    
endmodule
