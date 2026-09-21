#!/usr/bin/env python3
"""从共享模板创建实验目录，仅依赖 Python 标准库。"""
import argparse
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def create_experiment(root: Path, name: str, preview: bool = False) -> Path:
    # 名称同时进入目录与 LaTeX 参数；禁止路径跳转、控制字符和 TeX 命令。
    if not re.fullmatch(r"[\w\u3400-\u9fff（）() ·-]+", name) or name != name.strip():
        raise ValueError("名称只能包含中英文、数字、空格、括号、短横线和下划线，且不能有首尾空格。")
    if len(name) > 70:
        raise ValueError("实验名称请控制在 70 个字符以内。")
    parent = root / "experiments"
    if parent.is_symlink():
        raise ValueError("experiments 不能是符号链接。")
    template = (root / "templates/report.tex").read_text(encoding="utf-8")
    template = template.replace(r"\exname{}", r"\exname{" + name.replace("_", r"\_") + "}", 1)
    if preview:
        template = template.replace(r"\documentclass[]", r"\documentclass[yuxi]", 1)
    destination = parent / name
    destination.mkdir(parents=True, exist_ok=False)
    for sub in ("analysis", "data", "figures/diagrams", "figures/plots", "figures/photos"):
        folder = destination / sub
        folder.mkdir(parents=True)
        (folder / ".gitkeep").touch()
    (destination / "report.tex").write_text(template, encoding="utf-8")
    (destination / "README.md").write_text(
        f"# {name}\n\n"
        "报告入口为 `report.tex`。原理图放 `figures/diagrams/`，拟合与结果图放 "
        "`figures/plots/`，实验照片放 `figures/photos/`。数据文件放 `data/`，"
        "处理程序放 `analysis/`。\n\n"
        "公开报告的姓名、学号字段保持为空；提交方法见仓库根目录 README。\n",
        encoding="utf-8",
    )
    return destination


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("name", help="实验名称（含空格时请加引号）")
    parser.add_argument("--preview", action="store_true", help="生成预习报告")
    args = parser.parse_args()
    try:
        destination = create_experiment(ROOT, args.name, args.preview)
    except (OSError, ValueError) as error:
        print(f"创建失败：{error}", file=sys.stderr)
        return 1
    print(f"已创建：{destination.relative_to(ROOT)}/report.tex")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
