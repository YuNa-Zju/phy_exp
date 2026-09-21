import contextlib
import io
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import build_reports
import new_experiment
import privacy


def tex(command, value):
    # 用运行时组装的虚构信息测试，避免测试源文件本身成为扫描命中项。
    return chr(92) + command + "{" + value + "}"


class PrivacyTextTests(unittest.TestCase):
    def test_nested_and_multiline_fields(self):
        text = tex("name", "\n" + tex("textbf", "演示同学") + "\n") + tex("stuid", "EXAMPLE-ID")
        self.assertEqual(privacy.sanitize(text), tex("name", "") + tex("stuid", ""))

    def test_comment_inside_field(self):
        self.assertEqual(privacy.sanitize(tex("name", "% 演示同学\n")), tex("name", ""))

    def test_definitions_and_empty_labels_are_preserved(self):
        text = chr(92) + "newcommand" + chr(92) + "name[1]{" + chr(92) + "def" + chr(92) + "@name{#1}}"
        text += "\n% " + "作者" + "：\n% 说明文字\n" + tex("name", "")
        self.assertFalse(privacy.findings(text))

    def test_label_does_not_consume_next_line(self):
        text = "姓名" + "：\n实验结果\n"
        self.assertEqual(privacy.sanitize(text), text)

    def test_numeric_id_but_not_decimal(self):
        number = "3" + "1" * 9
        self.assertEqual(privacy.sanitize("编号 " + number), "编号 REDACTED")
        self.assertFalse(privacy.findings("0." + number))

    def test_labels_and_known_terms(self):
        source = "姓名" + "：" + "演示同学\n正文提到演示同学。"
        cleaned = privacy.sanitize(source, {"演示同学"})
        self.assertNotIn("演示同学", cleaned)
        self.assertFalse(privacy.findings(cleaned, {"演示同学"}))

    def test_unclosed_field_does_not_destroy_remainder(self):
        with self.assertRaises(ValueError):
            privacy.sanitize(chr(92) + "name{未闭合")

    def test_invalid_tex_encoding_fails_closed(self):
        for data in (b"text\0hidden", b"\xff\xfeb\0", b"\xffinvalid"):
            with self.assertRaises(ValueError):
                privacy.decode_text("report.tex", data)


class GitPrivacyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        (self.root / ".gitignore").write_text(".private/\n", encoding="utf-8")

    def tearDown(self):
        self.temp.cleanup()

    def run_scan(self, **kwargs):
        out = io.StringIO()
        with contextlib.redirect_stdout(out):
            result = privacy.run(self.root, **kwargs)
        return result, out.getvalue()

    def test_index_is_scanned_even_when_worktree_is_clean(self):
        path = self.root / "中文 报告.tex"
        dirty = tex("name", "演示同学")
        path.write_text(dirty, encoding="utf-8")
        privacy.git(self.root, "add", ".")
        path.write_text(tex("name", ""), encoding="utf-8")
        self.assertEqual(self.run_scan()[0], 0)
        code, output = self.run_scan(staged=True)
        self.assertEqual(code, 1)
        self.assertNotIn("演示同学", output)

    def test_fix_backs_up_and_never_stages(self):
        path = self.root / "报告.tex"
        dirty = (tex("name", "演示同学") + "\r\n" + tex("stuid", "DEMO") + "\r\n").encode()
        path.write_bytes(dirty)
        privacy.git(self.root, "add", ".")
        self.assertEqual(self.run_scan(fix=True)[0], 0)
        backups = list((self.root / ".private/privacy-backups").glob("*/报告.tex"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_bytes(), dirty)
        self.assertEqual(privacy.git(self.root, "show", ":报告.tex"), dirty)
        self.assertEqual(self.run_scan()[0], 0)
        self.assertIn(b"\r\n", path.read_bytes())

    def test_untracked_text_is_checked_and_ignored_private_is_not(self):
        (self.root / "draft.tex").write_text(tex("name", "演示同学"))
        private = self.root / ".private"
        private.mkdir()
        (private / "notes.txt").write_text(tex("name", "其他同学"))
        self.assertEqual(self.run_scan()[0], 1)
        (self.root / "draft.tex").unlink()
        self.assertEqual(self.run_scan()[0], 0)
        privacy.git(self.root, "add", "-f", ".private/notes.txt")
        self.assertEqual(self.run_scan(staged=True)[0], 1)

    def test_binary_images_are_unchanged(self):
        image = self.root / "photo.jpg"
        original = b"\xff\xd8" + tex("name", "演示同学").encode()
        image.write_bytes(original)
        self.assertEqual(self.run_scan(fix=True)[0], 0)
        self.assertEqual(image.read_bytes(), original)

    def test_sensitive_filename_is_not_printed(self):
        number = "3" + "1" * 9
        (self.root / (number + ".tex")).write_text("")
        code, output = self.run_scan()
        self.assertEqual(code, 1)
        self.assertNotIn(number, output)

    def test_symlink_is_rejected(self):
        (self.root / "outside.tex").symlink_to("/etc/hosts")
        with self.assertRaises(ValueError):
            self.run_scan(fix=True)

    def test_programs_and_other_text_are_never_modified(self):
        original = tex("name", "演示同学") + "\n" + "学号" + "：" + "3" + "1" * 9
        for suffix in (".py", ".m", ".cls", ".md", ".csv"):
            (self.root / ("source" + suffix)).write_text(original)
        self.assertEqual(self.run_scan(fix=True)[0], 0)
        for suffix in (".py", ".m", ".cls", ".md", ".csv"):
            self.assertEqual((self.root / ("source" + suffix)).read_text(), original)


class ExperimentTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name)
        (self.root / "templates").mkdir()
        shutil.copy2(new_experiment.ROOT / "templates/report.tex", self.root / "templates/report.tex")

    def tearDown(self):
        self.temp.cleanup()

    def test_create_chinese_space_and_preview(self):
        report = new_experiment.create_experiment(self.root, "单摆 实验_示例", preview=True)
        text = report.read_text()
        self.assertIn("[yuxi]", text)
        self.assertIn("../../templates/Report", text)
        self.assertIn(tex("name", ""), text)
        self.assertIn(tex("stuid", ""), text)
        self.assertTrue((report.parent / "figures/plots/.gitkeep").exists())

    def test_existing_experiment_is_not_overwritten(self):
        first = new_experiment.create_experiment(self.root, "单摆")
        first.write_text("已填写")
        notes = first.parent / "README.md"
        notes.write_text("已有的实验说明")
        figure = first.parent / "figures/photos/记录.jpg"
        figure.write_bytes(b"existing-photo")
        second = new_experiment.create_experiment(self.root, "单摆")
        third = new_experiment.create_experiment(self.root, "单摆", preview=True)
        self.assertEqual(second.name, "report-02.tex")
        self.assertEqual(third.name, "report-03.tex")
        self.assertIn("[yuxi]", third.read_text())
        self.assertEqual(first.read_text(), "已填写")
        self.assertEqual(notes.read_text(), "已有的实验说明")
        self.assertEqual(figure.read_bytes(), b"existing-photo")

    def test_numbering_continues_after_highest_existing_version(self):
        first = new_experiment.create_experiment(self.root, "单摆")
        (first.parent / "report-04.tex").write_text("已有第四份")
        fifth = new_experiment.create_experiment(self.root, "单摆")
        self.assertEqual(fifth.name, "report-05.tex")
        (first.parent / "report-99.tex").touch()
        self.assertEqual(new_experiment.create_experiment(self.root, "单摆").name, "report-100.tex")

    def test_empty_existing_directory_gets_first_report(self):
        (self.root / "experiments/单摆").mkdir(parents=True)
        self.assertEqual(new_experiment.create_experiment(self.root, "单摆").name, "report.tex")

    def test_existing_experiment_symlink_is_rejected(self):
        (self.root / "experiments").mkdir()
        (self.root / "experiments/单摆").symlink_to(self.root / "templates", target_is_directory=True)
        with self.assertRaises(ValueError):
            new_experiment.create_experiment(self.root, "单摆")

    def test_path_traversal_and_tex_injection_are_rejected(self):
        for name in ("../test", "/tmp/test", "a/b", "a%comment", "a" + chr(92) + "input{evil}", "", " 单摆"):
            with self.subTest(name=name), self.assertRaises(ValueError):
                new_experiment.create_experiment(self.root, name)


class BuildTests(unittest.TestCase):
    def test_failed_build_cannot_reuse_old_pdf(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            report = root / "experiments/单摆/report.tex"
            report.parent.mkdir(parents=True)
            report.write_text("invalid")
            stale = root / "build/reports/单摆/report.pdf"
            stale.parent.mkdir(parents=True)
            stale.write_bytes(b"old-pdf")
            with patch.object(build_reports.subprocess, "run", return_value=subprocess.CompletedProcess([], 1)):
                _, success = build_reports.build_one(report, root=root)
            self.assertFalse(success)
            self.assertFalse(stale.exists())


if __name__ == "__main__":
    unittest.main()
