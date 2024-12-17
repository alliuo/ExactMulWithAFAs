
module RM4u5 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] out
);
    // PP coding
    wire [1:0] ah, al, bh, bl;
    wire [3:0] pp_hh, pp_hl, pp_lh, pp_ll;

    assign ah = a[3:2];
    assign al = a[1:0];
    assign bh = b[3:2];
    assign bl = b[1:0];

    mul2_acc CODE_HH (.a(ah), .b(bh), .out(pp_hh));
    mul2_acc CODE_HL (.a(ah), .b(bl), .out(pp_hl));
    mul2_acc CODE_LH (.a(al), .b(bh), .out(pp_lh));
    mul2_acc CODE_LL (.a(al), .b(bl), .out(pp_ll));

    // PP reduction
    wire cout3, sum3, cout2, sum2, cout1, sum1, cout0, sum0;

    assign {cout3, sum3} = ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b000) ? 2'b00 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b001) ? 2'b01 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b010) ? 2'b01 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b011) ? 2'b10 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b100) ? 2'b01 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b101) ? 2'b10 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b110) ? 2'b10 : (
                              ({pp_hh[1], pp_hl[3], pp_lh[3]} == 3'b111) ? 2'b00 : 2'b0)))))));

    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    assign {cout0, sum0} = ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b000) ? 2'b00 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b001) ? 2'b01 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b010) ? 2'b01 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b011) ? 2'b10 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b100) ? 2'b01 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b101) ? 2'b10 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b110) ? 2'b10 : (
                              ({pp_hl[0], pp_lh[0], pp_ll[2]} == 3'b111) ? 2'b00 : 2'b0)))))));

    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};
    HA      RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    assign {carry1, out[4]} = ({sum2, cout1, carry0} == 3'b000) ? 2'b00 : (
                              ({sum2, cout1, carry0} == 3'b001) ? 2'b01 : (
                              ({sum2, cout1, carry0} == 3'b010) ? 2'b01 : (
                              ({sum2, cout1, carry0} == 3'b011) ? 2'b00 : (
                              ({sum2, cout1, carry0} == 3'b100) ? 2'b01 : (
                              ({sum2, cout1, carry0} == 3'b101) ? 2'b10 : (
                              ({sum2, cout1, carry0} == 3'b110) ? 2'b10 : (
                              ({sum2, cout1, carry0} == 3'b111) ? 2'b11 : 2'b0)))))));
    assign {carry2, out[5]} = ({sum3, cout2, carry1} == 3'b000) ? 2'b00 : (
                              ({sum3, cout2, carry1} == 3'b001) ? 2'b01 : (
                              ({sum3, cout2, carry1} == 3'b010) ? 2'b01 : (
                              ({sum3, cout2, carry1} == 3'b011) ? 2'b10 : (
                              ({sum3, cout2, carry1} == 3'b100) ? 2'b01 : (
                              ({sum3, cout2, carry1} == 3'b101) ? 2'b10 : (
                              ({sum3, cout2, carry1} == 3'b110) ? 2'b10 : (
                              ({sum3, cout2, carry1} == 3'b111) ? 2'b00 : 2'b0)))))));
    assign {carry3, out[6]} = ({pp_hh[2], cout3, carry2} == 3'b000) ? 2'b00 : (
                              ({pp_hh[2], cout3, carry2} == 3'b001) ? 2'b01 : (
                              ({pp_hh[2], cout3, carry2} == 3'b010) ? 2'b01 : (
                              ({pp_hh[2], cout3, carry2} == 3'b011) ? 2'b11 : (
                              ({pp_hh[2], cout3, carry2} == 3'b100) ? 2'b01 : (
                              ({pp_hh[2], cout3, carry2} == 3'b101) ? 2'b10 : (
                              ({pp_hh[2], cout3, carry2} == 3'b110) ? 2'b10 : (
                              ({pp_hh[2], cout3, carry2} == 3'b111) ? 2'b01 : 2'b0)))))));
    assign out[7] = pp_hh[3] | carry3;

endmodule
