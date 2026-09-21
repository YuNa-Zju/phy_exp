#!/usr/bin/env python3
"""检查实验入口、模板和 LaTeX 图片/输入文件引用，不要求安装 TeX。"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]


def uncomment(text):
    return re.sub(r"(?<!\\)%[^\n]*", "", text)


def check(root=ROOT):
    errors = []
    reports = sorted((root / "experiments").glob("*/report*.tex"))
    if not reports:
        errors.append("没有找到 experiments/*/report*.tex")
    for experiment in sorted((root / "experiments").iterdir()):
        if experiment.is_dir() and not (experiment / "report.tex").is_file():
            errors.append(f"{experiment.relative_to(root)}: 缺少 report.tex")
    for report in reports:
        text = uncomment(report.read_text(encoding="utf-8"))
        label = report.relative_to(root)
        if not re.search(r"\\documentclass(?:\[[^\]]*\])?\{\.\./\.\./templates/Report\}", text):
            errors.append(f"{label}: 模板路径应为 ../../templates/Report")
        if r"\settemplatedir{../../templates/}" not in text:
            errors.append(f"{label}: 缺少共享模板资源路径")
        for match in re.finditer(r"\\(?:includegraphics\*?(?:\[[^\]]*\])?|includepdf(?:\[[^\]]*\])?|input|include)\s*\{([^{}]+)\}", text):
            name = match[1]
            if "\\" in name:
                errors.append(f"{label}: 动态引用不能静态检查，请使用字面路径")
                continue
            image = match[0].startswith(r"\includegraphics")
            bases = [report.parent / name]
            if image:
                bases += [report.parent / "figures" / name, root / "templates/figures" / name]
            extensions = ("", ".pdf", ".png", ".jpg", ".jpeg", ".JPG") if image else ("", ".pdf") if match[0].startswith(r"\includepdf") else ("", ".tex")
            candidates = [Path(str(base) + ext) for base in bases for ext in extensions]
            if not any(p.is_file() and p.resolve().is_relative_to(root.resolve()) for p in candidates):
                line = text.count("\n", 0, match.start()) + 1
                errors.append(f"{label}:{line}: 找不到引用文件 {name}")
    for asset in ("Report.cls", "note.tex", "figures/浙江大学.pdf", "fonts/simsun.ttc", "fonts/simhei.ttf", "fonts/simkai.ttf", "fonts/simfang.ttf"):
        if not (root / "templates" / asset).is_file():
            errors.append(f"缺少 templates/{asset}")
    for error in errors:
        print(error)
    if not errors:
        print(f"结构检查通过：{len(reports)} 份报告，模板和有效图片引用均存在。")
    return bool(errors)


if __name__ == "__main__":
    sys.exit(check())
