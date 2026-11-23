import os
from create_scripts import *
from create_rtl import *


def GenerateAll(target_path, sign_type):
    rtl_path = os.path.join(target_path, 'rtl')
    tb_path = os.path.join(target_path, 'tb')
    dc_step1_path = os.path.join(target_path, 'dc_step1')
    dc_step2_path = os.path.join(target_path, 'dc_step2')
    makefile_path = os.path.join(target_path, 'makefile')
    vcs_path = os.path.join(target_path, 'vcs')

    for path in (rtl_path, tb_path, dc_step1_path, dc_step2_path, makefile_path,
                 vcs_path, os.path.join(target_path, 'mapped'), os.path.join(target_path, 'out')):
        os.makedirs(path, exist_ok=True)

    if sign_type == 'u':
        name_list = CodeU(rtl_path)
    elif sign_type == 's':
        name_list = CodeS(rtl_path)
    elif sign_type == 'su':
        name_list = CodeSU(rtl_path)
    else:
        return

    GenerateDCScript1(dc_step1_path, name_list)
    GenerateTestBenchs(tb_path, name_list, sign_type)
    iter_num = GenerateVCSMakefile(makefile_path, name_list)
    GenerateDCScript2(dc_step2_path, name_list)
    GenerateRUNScript(target_path, name_list, iter_num)


if __name__ == '__main__':
    GenerateAll('./syn/opt4x4u', 'u')
    GenerateAll('./syn/opt4x4s', 's')
    GenerateAll('./syn/opt4x4su', 'su')
