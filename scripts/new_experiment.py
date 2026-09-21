#!/usr/bin/env python3
"""从共享模板新建报告；已有实验自动追加编号，不覆盖旧报告。"""
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
    if destination.is_symlink():
        raise ValueError("实验目录不能是符号链接。")
    destination.mkdir(parents=True, exist_ok=True)
    if (destination / "figures").is_symlink():
        raise ValueError("实验资源目录不能是符号链接。")
    for sub in ("analysis", "data", "figures/diagrams", "figures/plots", "figures/photos"):
        folder = destination / sub
        if folder.is_symlink():
            raise ValueError("实验资源目录不能是符号链接。")
        folder.mkdir(parents=True, exist_ok=True)
        if not any(folder.iterdir()):
            (folder / ".gitkeep").touch()

    numbers = []
    for entry in destination.iterdir():
        if entry.name == "report.tex":
            numbers.append(1)
        elif match := re.fullmatch(r"report-([0-9]+)\.tex", entry.name):
            numbers.append(int(match[1]))
    number = max(numbers, default=0) + 1
    while True:
        report = destination / ("report.tex" if number == 1 else f"report-{number:02d}.tex")
        try:
            # 排他创建：即使同时运行两次，也不会覆盖另一个进程的新文件。
            with report.open("x", encoding="utf-8") as stream:
                stream.write(template)
            break
        except FileExistsError:
            number += 1

    try:
        with (destination / "README.md").open("x", encoding="utf-8") as stream:
            stream.write(
                f"# {name}\n\n"
                "报告按 `report.tex`、`report-02.tex` 等依次编号。原理图放 `figures/diagrams/`，"
                "结果图放 `figures/plots/`，实验照片放 `figures/photos/`。\n\n"
                "使用方法见[仓库 README](../../README.md)。\n"
            )
    except FileExistsError:
        pass  # 保留已有的实验说明。
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("name", help="实验名称（含空格时请加引号）")
    parser.add_argument("--preview", action="store_true", help="生成预习报告")
    args = parser.parse_args()
    try:
        report = create_experiment(ROOT, args.name, args.preview)
    except (OSError, ValueError) as error:
        print(f"创建失败：{error}", file=sys.stderr)
        return 1
    print(f"已创建：{report.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
