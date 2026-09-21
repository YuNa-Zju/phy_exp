#!/usr/bin/env python3
"""只检查/清空 .tex 中的学生姓名和学号；不修改程序、图片或 Git 历史。"""
import argparse
from dataclasses import dataclass
from datetime import datetime
import json
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
COMMAND = re.compile(r"\\(?:name|stuid|studentname|studentid)\b\s*(?:%[^\n]*\n\s*)?\{")
LABEL = re.compile(r"(?:姓名|同组人|同组同学|实验者|学号)[ \t]*[:：=][ \t]*([^\n\r，,；;。|{}]+)")
# 本仓库所属学校的常见学号格式。其他格式仍由身份字段检查覆盖。
STUDENT_ID = re.compile(r"(?<![\w.])3[0-9]{9}(?![\w.])")
PLACEHOLDERS = {"", "匿名", "已匿名", "已隐去", "待填写", "REDACTED", "<姓名>", "<学号>", "#1"}


@dataclass(frozen=True)
class Finding:
    start: int
    end: int
    rule: str
    replacement: str


def git(root: Path, *args: str) -> bytes:
    return subprocess.check_output(["git", "-C", str(root), *args], stderr=subprocess.PIPE)


def identity_fields(text: str):
    """平衡花括号，支持换行和嵌套格式命令；定义中的 #1 不视为姓名。"""
    for match in COMMAND.finditer(text):
        start = match.end()
        depth, cursor = 1, start
        while cursor < len(text) and depth:
            char = text[cursor]
            if char == "\\":
                cursor += 2
                continue
            if char == "%":
                end = text.find("\n", cursor)
                cursor = len(text) if end < 0 else end + 1
                continue
            if char == "{":
                depth += 1
            elif char == "}":
                depth -= 1
            cursor += 1
        if depth:
            yield Finding(start, len(text), "未闭合的身份字段（请手动修复）", "")
            continue
        end = cursor - 1
        if text[start:end].strip() not in PLACEHOLDERS:
            yield Finding(start, end, "非空身份字段", "")


def findings(text: str, terms=()) -> list[Finding]:
    result = list(identity_fields(text))
    for match in LABEL.finditer(text):
        if match[1].strip() not in PLACEHOLDERS | {r"\@name", r"\@stuid"}:
            result.append(Finding(match.start(1), match.end(1), "带标签的身份信息", "已隐去"))
    result.extend(Finding(m.start(), m.end(), "疑似学号", "REDACTED") for m in STUDENT_ID.finditer(text))
    for term in terms:
        result.extend(Finding(m.start(), m.end(), "本地敏感词", "已隐去") for m in re.finditer(re.escape(term), text))
    return sorted(result, key=lambda f: (f.start, -f.end))


def sanitize(text: str, terms=()) -> str:
    end, pieces = 0, []
    for item in findings(text, terms):
        if item.start < end:
            continue
        if "未闭合" in item.rule:
            raise ValueError("存在未闭合的身份字段，请先手动修复，未写入任何文件。")
        pieces.extend((text[end:item.start], item.replacement))
        end = item.end
    pieces.append(text[end:])
    return "".join(pieces)


def collect(root: Path, staged: bool):
    """工作区包括未跟踪文件；暂存区读取 blob，不读可能已经被修改的工作区副本。"""
    if staged:
        for record in git(root, "ls-files", "--stage", "-z").split(b"\0"):
            if not record:
                continue
            metadata, raw_path = record.split(b"\t", 1)
            mode, oid, stage = metadata.decode().split()
            if stage != "0":
                raise ValueError("暂存区存在未解决的合并冲突。")
            path = raw_path.decode("utf-8")
            if Path(path).suffix.lower() != ".tex" and ".private" not in Path(path).parts and not path.endswith(".local.json"):
                continue
            if mode not in {"100644", "100755"}:
                raise ValueError("不支持检查符号链接或子模块，请移除后重试。")
            yield path, git(root, "cat-file", "blob", oid)
    else:
        raw = git(root, "ls-files", "--cached", "--others", "--exclude-standard", "-z")
        for path in sorted(set(raw.decode("utf-8").split("\0")) - {""}):
            if Path(path).suffix.lower() != ".tex" and ".private" not in Path(path).parts and not path.endswith(".local.json"):
                continue
            target = root / path
            if not target.exists() and not target.is_symlink():
                continue
            if target.is_symlink() or root.resolve() not in target.resolve().parents:
                raise ValueError("不支持检查符号链接或仓库外路径。")
            yield path, target.read_bytes()


def decode_text(path: str, data: bytes):
    if Path(path).suffix.lower() != ".tex":
        return None
    if data.startswith((b"\xff\xfe", b"\xfe\xff")):
        raise ValueError("发现 UTF-16 文本，请转换为 UTF-8 后检查。")
    if b"\0" in data:
        raise ValueError("TeX 文件含 NUL 字节，无法作为 UTF-8 源码检查。")
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        raise ValueError("发现非 UTF-8 文件，无法检查；请转换文本编码或确认文件类型。") from None


def load_terms(root: Path):
    path = root / ".private/privacy-terms.json"
    if not path.exists():
        return set()
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict) or any(not isinstance(v, list) for v in data.values()):
        raise ValueError("本地敏感词文件应为 JSON 对象，值为字符串数组。")
    return {term for values in data.values() for term in values if isinstance(term, str) and term.strip()}


def run(root: Path, staged=False, fix=False) -> int:
    entries = list(collect(root, staged))
    terms = load_terms(root)
    texts = {}
    blocked = False
    for path, raw in entries:
        if ".private" in Path(path).parts or path.endswith((".local.tex", ".local.json")):
            print("禁止提交本地私有文件（路径不回显）。")
            blocked = True
            continue
        text = decode_text(path, raw)
        if text is not None:
            texts[path] = (text, raw)
            # 本次扫描发现的姓名还会用于检查正文、注释和文件名。
            for item in identity_fields(text):
                value = text[item.start:item.end].strip()
                if re.fullmatch(r"[\u3400-\u9fff]{2,5}|[A-Za-z][A-Za-z .'-]{1,60}|[0-9]{6,14}", value):
                    terms.add(value)
    count, updates = 0, {}
    for path, _ in entries:
        if findings(path, terms) or STUDENT_ID.search(Path(path).stem):
            print("文件名中发现身份信息（路径不回显），请手动重命名并修正引用。")
            blocked = True
    for path, (text, raw) in texts.items():
        matches = findings(text, terms)
        for item in matches:
            line = text.count("\n", 0, item.start) + 1
            safe_path = path
            for term in sorted(terms, key=len, reverse=True):
                safe_path = safe_path.replace(term, "[已隐去]")
            safe_path = re.sub(r"3[0-9]{9}", "[已隐去]", safe_path)
            print(f"{safe_path}:{line}: {item.rule}")
        count += len(matches)
        if matches and fix:
            updates[path] = (sanitize(text, terms).encode("utf-8"), raw)
    if fix and updates:
        backup = root / ".private/privacy-backups" / datetime.now().strftime("%Y%m%d-%H%M%S-%f")
        backup.mkdir(parents=True, mode=0o700)
        for path, (_, raw) in updates.items():
            destination = backup / path
            destination.parent.mkdir(parents=True, exist_ok=True)
            destination.write_bytes(raw)
        for path, (clean, _) in updates.items():
            (root / path).write_bytes(clean)
        print(f"已匿名化 {len(updates)} 个 .tex 文件；原件备份至 .private/privacy-backups/。")
        print("请审阅修改，然后重新 git add；脚本不会自动更改暂存区。")
        return 1 if blocked else 0
    print(f"已检查 {len(texts)} 个 .tex 文件；程序、其他文本、图片及 PDF 均不检查。")
    return 1 if count or blocked else 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--check", action="store_true", help="只检查（默认）")
    action.add_argument("--fix", action="store_true", help="备份后匿名化工作区 .tex")
    parser.add_argument("--staged", action="store_true", help="检查将被提交的整个暂存区快照")
    args = parser.parse_args()
    if args.staged and args.fix:
        parser.error("--staged 只用于检查；先 --fix，再 git add。")
    try:
        return run(ROOT, args.staged, args.fix)
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        # 外部命令异常可能包含路径或身份信息，不直接回显。
        print(f"检查未完成（{type(error).__name__}）；请检查 Git 状态、UTF-8 编码及本地敏感词配置。", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
