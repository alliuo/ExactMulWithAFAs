import os
import shutil
from itertools import product
import creat_scripts


def GenerateTestBenchs(output_dir, mul_name_list, sign_type):
    """
    Generate the testbenchs for 2x2 multipliers
    """
    for mul_name in mul_name_list:
        code = """
`timescale 1ns / 1ps

module top_sim();
    wire [7:0] out;
    reg  [3:0] a;
    reg  [3:0] b;"""
        if sign_type == 'su':
            code += f"""
    {mul_name} top (.s(a), .u(b), .out(out));
"""
        else:
            code += f"""
    {mul_name} top (.a(a), .b(b), .out(out));
"""
        code += """
    initial
    begin
        `ifdef DUMP_VPD
                $vcdpluson();
        `endif
        a = {$random}%16;
        b = {$random}%16;
        #1000000
        `ifdef DUMP_VPD
                $vcdplusoff();
        `endif
        $finish;
    end

    always
    begin
        forever #1   begin b = {$random}%16;end
    end
    always
    begin
        forever #1   begin a = {$random}%16;end
    end

endmodule
"""
        out_path = os.path.join(output_dir, f'{mul_name}_tb.v')
        with open(out_path, 'w') as f:
            f.write(code)
        print(f'Generated {out_path}')


def CodeFullAdder(uncared_inputs, input_names, input_valuses):
    code = ""
    for input in range(2**3):
        if input in uncared_inputs:
            output = input_valuses[uncared_inputs.index(input)]
        else:
            output = input%2 + input//2%2 + input//4
        code += f"({{{input_names[0]}, {input_names[1]}, {input_names[2]}}} == 3'b{bin(input)[2:].zfill(3)}) ? 2'b{bin(output)[2:].zfill(2)} : "
        if not (input == 2**3-1):
            code += "(\n                              "
        else:
            code += ("2'b0" + ')'*(2**3-1) + ";\n")
    return code


def CodeU(output_dir):
    """
    Generate RTL code for all unsigned 4x4 multipliers
    """
    uncared_input0 = [7]
    uncared_input1 = [7]
    uncared_input2 = [3]
    uncared_input3 = [7]
    uncared_input4 = [3, 7]
    combinations = list(product([0, 1, 2, 3], repeat=6)) # 4=len(uncared_input0)+len(uncared_input1)+len(uncared_input2)
    name_list = []

    for combination in combinations:
        name = 'mul4_' + str(len(name_list))
        name_list.append(name)
        code = f"""
module {name} (
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

    assign {{cout3, sum3}} = """
        code += CodeFullAdder(uncared_input0, ['pp_hh[1]', 'pp_hl[3]', 'pp_lh[3]'], [combination[0]])
        code += """
    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    assign {cout0, sum0} = """
        code += CodeFullAdder(uncared_input1, ['pp_hl[0]', 'pp_lh[0]', 'pp_ll[2]'], [combination[1]])
        code += """
    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};
    HA      RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    assign {carry1, out[4]} = """
        code += CodeFullAdder(uncared_input2, ['sum2', 'cout1', 'carry0'], [combination[2]])
        code += "    assign {carry2, out[5]} = "
        code += CodeFullAdder(uncared_input3, ['sum3', 'cout2', 'carry1'], [combination[3]])
        code += "    assign {carry3, out[6]} = "
        code += CodeFullAdder(uncared_input4, ['pp_hh[2]', 'cout3', 'carry2'], combination[4:])
        code += """    assign out[7] = pp_hh[3] | carry3;

endmodule
"""
        out_path = os.path.join(output_dir, f'{name}.v')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')
    return name_list
    

def CodeS(output_dir):
    """
    Generate RTL code for all signed 4x4 multipliers
    """
    uncared_input0 = [7]
    uncared_input1 = [3]
    uncared_input2 = [7]
    uncared_input3 = [1, 3, 7]
    combinations = list(product([0, 1, 2, 3], repeat=6))
    name_list = []

    for combination in combinations:
        name = 'mul4s_' + str(len(name_list))
        name_list.append(name)
        code = f"""
module {name} (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [7:0] out
);
    // PP coding
    wire [1:0] ah, bh, al, bl;
    wire [3:0] pp_hh, pp_hl, pp_lh, pp_ll;

    assign ah = a[3:2];
    assign al = a[1:0];
    assign bh = b[3:2];
    assign bl = b[1:0];

    mul2_signed CODE_HH (.a(ah), .b(bh), .out(pp_hh));
    mul2_su     CODE_HL (.s(ah), .u(bl), .out(pp_hl));
    mul2_su     CODE_LH (.s(bh), .u(al), .out(pp_lh));
    mul2_acc    CODE_LL (.a(al), .b(bl), .out(pp_ll));

    // PP reduction
    wire cout4, sum4, cout3, sum3, cout2, sum2, cout1, sum1, cout0, sum0;

    assign cout4 = pp_hh[2];
    assign sum4 = ~pp_hh[2];
    FA   FA3 (.a(pp_hh[1]), .b(~pp_hl[3]), .cin(~pp_lh[3]), .cout(cout3), .sum(sum3));
    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    assign {{cout0, sum0}} = """
        code += CodeFullAdder(uncared_input0, ['pp_hl[0]', 'pp_lh[0]', 'pp_ll[2]'], [combination[0]])
        code += """
    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};

    HA       RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    assign {carry1, out[4]} = """
        code += CodeFullAdder(uncared_input1, ['sum2', 'cout1', 'carry0'], [combination[1]])
        code += "    assign {carry2, out[5]} = "
        code += CodeFullAdder(uncared_input2, ['sum3', 'cout2', 'carry1'], [combination[2]])
        code += "    assign {carry3, out[6]} = "
        code += CodeFullAdder(uncared_input3, ['sum4', 'cout3', 'carry2'], combination[3:])
        code += """    assign out[7] = ~(~pp_hh[3] & (cout4 | carry3));

endmodule
"""
        out_path = os.path.join(output_dir, f'{name}.v')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')
    return name_list


def CodeSU(output_dir):
    """
    Generate RTL code for signedxunsigned 4x4 multipliers
    """
    uncared_input0 = [7]
    uncared_input1 = [3]
    uncared_input2 = [3]
    uncared_input3 = [3, 5, 7]
    combinations = list(product([0, 1, 2, 3], repeat=6))
    name_list = []

    for combination in combinations:
        name = 'mul4su_' + str(len(name_list))
        name_list.append(name)
        code = f"""
module {name} (
    input  wire [3:0] s,
    input  wire [3:0] u,
    output wire [7:0] out
);
    // PP coding
    wire [1:0] ah, bh, al, bl;
    wire [3:0] pp_hh, pp_hl, pp_lh, pp_ll;

    assign ah = s[3:2];
    assign al = s[1:0];
    assign bh = u[3:2];
    assign bl = u[1:0];

    mul2_su  CODE_HH (.s(ah), .u(bh), .out(pp_hh));
    mul2_su  CODE_HL (.s(ah), .u(bl), .out(pp_hl));
    mul2_acc CODE_LH (.a(bh), .b(al), .out(pp_lh));
    mul2_acc CODE_LL (.a(al), .b(bl), .out(pp_ll));

    // PP reduction
    wire sum5, cout4, sum4, cout3, sum3, cout2, sum2, cout1, sum1, cout0, sum0;

    assign sum5 = ~pp_hh[3] ^ ~pp_hl[3];
    HA       HA4 (.a(pp_hh[2]), .b(pp_hl[3]),                 .cout(cout4), .sum(sum4));
    FA   FA3 (.a(pp_hh[1]), .b(pp_hl[3]), .cin(pp_lh[3]), .cout(cout3), .sum(sum3));
    FA   FA2 (.a(pp_hh[0]), .b(pp_hl[2]), .cin(pp_lh[2]), .cout(cout2), .sum(sum2));
    FA   FA1 (.a(pp_hl[1]), .b(pp_lh[1]), .cin(pp_ll[3]), .cout(cout1), .sum(sum1));
    assign {{cout0, sum0}} = """
        code += CodeFullAdder(uncared_input0, ['pp_hl[0]', 'pp_lh[0]', 'pp_ll[2]'], [combination[0]])
        code += """
    // Carry propagate adder
    wire carry0, carry1, carry2, carry3;

    assign out[2:0] = {sum0, {pp_ll[1:0]}};

    HA       RCA_HA  (.a(sum1), .b(cout0), .cout(carry0), .sum(out[3]));
    assign {carry1, out[4]} = """
        code += CodeFullAdder(uncared_input1, ['sum2', 'cout1', 'carry0'], [combination[1]])
        code += "    assign {carry2, out[5]} = "
        code += CodeFullAdder(uncared_input2, ['sum3', 'cout2', 'carry1'], [combination[2]])
        code += "    assign {carry3, out[6]} = "
        code += CodeFullAdder(uncared_input3, ['sum4', 'cout3', 'carry2'], combination[3:])
        code += """    assign out[7] = sum5 | cout4 | carry3;

endmodule
"""
        out_path = os.path.join(output_dir, f'{name}.v')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')
    return name_list


def GenerateAll(target_path, sign_type):
    rtl_path = target_path + '/rtl'
    tb_path = target_path + '/tb'
    dc_step1_path = target_path + '/dc_step1'
    dc_step2_path = target_path + '/dc_step2'
    makefile_path = target_path + '/makefile'

    if os.path.exists(target_path):
        shutil.rmtree(target_path)
    os.makedirs(target_path)
    os.mkdir(rtl_path)
    os.mkdir(tb_path)
    os.mkdir(dc_step1_path)
    os.mkdir(dc_step2_path)
    os.mkdir(makefile_path)

    if sign_type == 'u':
        name_list = CodeU(rtl_path)
    elif sign_type == 's':
        name_list = CodeS(rtl_path)
    elif sign_type == 'su':
        name_list = CodeSU(rtl_path)
    else:
        return

    GenerateTestBenchs(tb_path, name_list, sign_type)
    iter_num = creat_scripts.GenerateVCSMakefile(makefile_path, name_list)
    creat_scripts.GenerateDCScript1(dc_step1_path, name_list)
    creat_scripts.GenerateDCScript2(dc_step2_path, name_list)
    creat_scripts.GenerateRUNScript(target_path, name_list, iter_num)


if __name__ == '__main__':
    GenerateAll('./syn/opt4x4u', 'u')
    GenerateAll('./syn/opt4x4s', 's')
    GenerateAll('./syn/opt4x4su', 'su')
