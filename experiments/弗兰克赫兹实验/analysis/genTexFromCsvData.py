#=======================
#用于将csv数据转换为LaTeX表格
#=======================

from pathlib import Path
import pandas as pd

EXPERIMENT = Path(__file__).resolve().parents[1]

df = pd.read_csv(EXPERIMENT / "data/data.csv",
                 header=None)  # 不把第一行当作表头
U = df.iloc[:, 0].tolist()
I = df.iloc[:, 1].tolist()

n_per_row = 10  # 每行显示10个数据
rows = []

for i in range(0, len(U), n_per_row):
    u_slice = U[i:i + n_per_row]
    i_slice = I[i:i + n_per_row]
    u_line = " & ".join(f"{u:.2f}" for u in u_slice)
    i_line = " & ".join(f"{i:.2f}" for i in i_slice)
    rows.append((u_line, i_line))

# === 拼接 LaTeX longtable ===
latex = r"""\begin{longtable}{C{.10\textwidth}*{10}{C{.06\textwidth}}}
\caption{手动测量的$I_A \sim U_{G_2K}$数据}
\label{shoudongceliang}\\
\toprule
"""

for u_line, i_line in rows:
    latex += f"$U_{{G_2K}}(\\si{{V}})$ & {u_line} \\\\\n"
    latex += r"\midrule" + "\n"
    latex += f"$I_A(\\times 10^{{-8}}\\si{{A}})$ & {i_line} \\\\\n"
    latex += r"\midrule" + "\n"

latex += r"\bottomrule" + "\n" + r"\end{longtable}"

# === 写入文件 ===
with open(EXPERIMENT / 'data/shoudongceliang_table.tex', 'w', encoding='utf-8') as f:
    f.write(latex)

print("LaTeX表格已生成：shoudongceliang_table.tex")
