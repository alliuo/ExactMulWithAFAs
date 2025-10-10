# Exact Multiplier with Approximate Full Adders

## File Structure
```text
./
├── AFA/                   # Approximate full adders (AFAs)
├── units/                 # Submodules for building multipliers
├── 2x2/                   # 2x2 multipliers
├── 4x4/                   # 4x4 multipliers
│   ├── unsigned/
│   ├── signed/
│   └── signedxunsigned/
├── 8x8/                   # 8x8 multipliers
│   ├── unsigned/
│   └── signed/
└── src/                   # 4x4 multiplier optimization using synthesis tools
    ├── script_template/   # Example of synthesis script templates
    ├── create_rtl.py      # Generate Verilog codes for 4x4 multipliers
    ├── create_scripts.py  # Generate synthesis scripts based on templates
    └── main.py            # Generate all files
```

## Description
Exact recursive multipliers designed based on customized approximate full adders (AFAs). 

[RM4uM](4x4/unsigned/RM4uM.v), [RM4sM](4x4/signed/RM4sM.v), and [RM4suM](4x4/signedxunsigned/RM4suM.v) are manually designed 4x4 multipliers, while the other 4x4 multipliers are designed based on synthesis tools. Note that the synthesis tool–based multipliers depend on the specific process library and design constraints; therefore, the optimal solution would vary across different environments. The multipliers presented here are the Pareto-optimal designs obtained under our experimental setup.

The 8x8 multipliers are constructed by exhaustively traversing all possible combinations of Pareto-optimal 4×4 multipliers. The results presented here are the Pareto-optimal 8×8 multipliers identified under our experimental setup.

To design multipliers based on synthesis tools, modify the provided [script_template](src/script_template) to suit your specific environment, and execute
```bash
cd src
python main.py
```
Then all candidate multipliers and their synthesis scripts are generated. By synthesizing and comparing these candidates, the Pareto-optimal multipliers can be identified.

## Citation
If you use these multipliers in your research, please refer the following paper:

A. Liu et al., "Low-Power Multiplier Designs by Leveraging Correlations of 2×2 Encoded Partial Products," in IEEE Transactions on Computers, doi: 10.1109/TC.2025.3604478.

```bibtex
@article{liu2025low,
  title={Low-Power Multiplier Designs by Leveraging Correlations of 2$\times$2 Encoded Partial Products},
  author={Liu, Ao and Liu, Siting and Wang, Hui and Wang, Qin and Lombardi, Fabrizio and Mao, Zhigang and Jiang, Honglan},
  journal={IEEE Transactions on Computers},
  year={2025},
  volume={74},
  number={11},
  pages={3888-3896},
  publisher={IEEE},
  doi={10.1109/TC.2025.3604478}}

