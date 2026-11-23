import os
import math


def GenerateTestBenchs(output_dir, mul_name_list, sign_type):
    """
    Generate the testbenchs for vcs simulation
    """
    with open('./script_template/testbench_template.v', 'r') as f:
        template = f.read()

    for mul_name in mul_name_list:
        if sign_type == 'su':
            code = template.format(UNIT_NAME=mul_name, INPUT0='s', INPUT1='u')
        else:
            code = template.format(UNIT_NAME=mul_name, INPUT0='a', INPUT1='b')
        out_path = os.path.join(output_dir, f'{mul_name}_tb.v')
        with open(out_path, 'w') as f:
            f.write(code)
        print(f'Generated {out_path}')


def GenerateVCSMakefile(output_dir, mul_name_list):
    """
    Generate the makefie for vcs simulation
    The simulation is used to generate the back-annotated switching activity file
    """
    with open('./script_template/makefile.template', 'r') as f:
        template = f.read()

    batch_size = 1000
    iter_num = math.ceil(len(mul_name_list) / batch_size)
    for i in range(iter_num):
        units_str = ' '.join(mul_name_list[i * batch_size:(i + 1) * batch_size])
        if(i == 0):
            code = template.format(SAIF_DIR='rm -rf ./saif; mkdir ./saif; ', UNITS=units_str)
        else:
            code = template.format(SAIF_DIR='', UNITS=units_str)
        code = code.replace(r'\t', '\t')
        out_path = os.path.join(output_dir, f'makefile{i}')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')
    return iter_num


def GenerateDCScript1(output_dir, mul_name_list):
    """
    Generate scripts for DC synthesis
    """
    with open('./script_template/dc_step1_template.tcl', 'r') as f:
        template = f.read()
    for mul_name in mul_name_list:
        code = template.format(UNIT_NAME=mul_name)
        out_path = os.path.join(output_dir, f'{mul_name}_step1.tcl')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')


def GenerateDCScript2(output_dir, mul_name_list):
    """
    Generate scripts for DC synthesis
    """
    with open('./script_template/dc_step2_template.tcl', 'r') as f:
        template = f.read()
    for mul_name in mul_name_list:
        code = template.format(UNIT_NAME=mul_name)
        out_path = os.path.join(output_dir, f'{mul_name}_step2.tcl')
        with open(out_path, 'w') as fout:
            fout.write(code)
        print(f'Generated {out_path}')


def GenerateRUNScript(output_dir, mul_name_list, iter_num):
    """
    The shell script used to run the synthesis
    """
    code = f"""
#!/bin/bash

for unit in {' '.join(mul_name_list)}
do
    rm -rf ./run
    mkdir run
    cd run
    dc_shell -f ../dc_step1/${{unit}}_step1.tcl
    cd ..
done

for file in {' '.join(['makefile'+str(i) for i in range(iter_num)])}
do
    mv ./makefile/${{file}} ./vcs/makefile
    cd vcs
    make regress
    cd ..
done

for unit in {' '.join(mul_name_list)}
do
    rm -rf ./run
    mkdir run
    cd run
    dc_shell -f ../dc_step2/${{unit}}_step2.tcl
    cd ..
done
"""
    out_path = os.path.join(output_dir, 'run.sh')
    with open(out_path, 'w') as fout:
        fout.write(code)
    print(f'Generated {out_path}')

