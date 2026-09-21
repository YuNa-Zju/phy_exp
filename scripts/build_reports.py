#!/usr/bin/env python3
"""用 XeLaTeX 构建实验报告；失败会返回非零状态，不打包过期 PDF。"""
import argparse
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def build_one(report: Path, root=ROOT):
    relative = report.relative_to(root / "experiments")
    public = root / "build/reports" / relative.with_suffix(".pdf")
    public.parent.mkdir(parents=True, exist_ok=True)
    public.unlink(missing_ok=True)
    logs = root / "build/logs" / relative.with_suffix(".log")
    logs.parent.mkdir(parents=True, exist_ok=True)
    temporary = root / "build/latex"
    temporary.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="report-", dir=temporary) as directory:
        command = ["latexmk", "-norc", "-xelatex", "-interaction=nonstopmode", "-halt-on-error",
                   "-file-line-error", "-no-shell-escape", f"-outdir={directory}", report.name]
        with logs.open("wb") as stream:
            try:
                result = subprocess.run(command, cwd=report.parent, stdout=stream, stderr=subprocess.STDOUT, timeout=300)
            except subprocess.TimeoutExpired:
                return str(relative), False
        pdf = Path(directory) / report.with_suffix(".pdf").name
        if result.returncode or not pdf.is_file():
            return str(relative), False
        shutil.copy2(pdf, public)
    return str(relative), True


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("reports", nargs="*", help="相对仓库根目录的报告路径；省略则构建全部")
    parser.add_argument("--jobs", type=int, default=2, help="并行编译数（默认 2）")
    parser.add_argument("--zip", action="store_true", help="全部所选报告成功后生成 build/reports.zip")
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error("--jobs 必须大于 0")
    reports = sorted(set((ROOT / p).resolve() for p in args.reports)) if args.reports else sorted((ROOT / "experiments").glob("*/report*.tex"))
    for report in reports:
        if not report.is_file() or not report.is_relative_to(ROOT / "experiments") or report.suffix != ".tex":
            parser.error("报告必须是 experiments/ 内存在的 .tex 文件")
    if not reports:
        parser.error("没有找到报告")
    if not shutil.which("latexmk") or not shutil.which("xelatex"):
        parser.error("请先安装含 latexmk 和 XeLaTeX 的 TeX Live / MacTeX")
    archive = ROOT / "build/reports.zip"
    archive.unlink(missing_ok=True)
    failed = []
    with ThreadPoolExecutor(max_workers=args.jobs) as executor:
        for name, ok in executor.map(build_one, reports):
            print(f"{'成功' if ok else '失败'}：{name}", flush=True)
            if not ok:
                failed.append(name)
    if failed:
        print(f"{len(failed)} 份报告编译失败；详见 build/logs/。未生成 ZIP。", file=sys.stderr)
        return 1
    if args.zip:
        with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as output:
            for report in reports:
                relative = report.relative_to(ROOT / "experiments").with_suffix(".pdf")
                output.write(ROOT / "build/reports" / relative, str(relative))
    print(f"{len(reports)} 份报告全部编译成功。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
