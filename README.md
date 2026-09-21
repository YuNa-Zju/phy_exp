# 大学物理实验报告

浙江大学大学物理实验的 LaTeX 报告、原始记录和数据处理程序。现有内容按实验整理在 [`experiments/`](experiments/) 中，共 23 个实验、44 份报告。报告有多个版本时全部保留；`report.tex` 是原无编号版本的入口，`report-02.tex` 等是其他版本，编号不代表新旧顺序或正确性排名。

## 目录

```text
experiments/
  实验名称/
    report.tex          # 报告入口
    report-02.tex       # 可选的其他报告版本
    README.md           # 版本与原路径说明
    figures/
      diagrams/         # 原理图、电路图、光路图
      plots/            # 拟合图、误差图、结果截图
      photos/           # 实验照片、仪器截图、原始记录扫描件
    data/               # CSV 等可处理的数据
    analysis/           # MATLAB / Python 数据处理程序
templates/              # 共享 Report.cls、报告骨架、字体和校名图片
  legacy/               # 原始 Phyport / Preport 模板源码，供溯源
references/             # 课程参考资料
docs/                   # 整理说明与旧路径对照
scripts/                # 新建实验、隐私检查、结构检查和编译工具
tests/                  # 工具的回归测试
build/                  # 本地编译输出，不提交
.private/               # 本地备份与敏感词配置，不提交
```

图片内容保持原样；重复文件按 SHA-256 合并，引用已更新。图片分类、少数有问题的旧文件和迁移说明见 [整理记录](docs/REORGANIZATION.md)，逐文件对照见 [path-mapping.json](docs/path-mapping.json)。

## 新建实验

仓库工具只需 **Python 3.10+** 和 Git，无需安装 Python 第三方包。在仓库根目录运行：

```bash
python3 scripts/new_experiment.py "单摆法测量重力加速度"
```

这会生成 `experiments/单摆法测量重力加速度/report.tex` 及配套目录，并自动填写实验标题和模板路径。姓名、学号默认留空。目录已存在时脚本会拒绝覆盖。

如需预习报告：

```bash
python3 scripts/new_experiment.py "单摆预习" --preview
```

名称可含中文、英文字母、数字、空格、括号、短横线和下划线；有空格时请加引号。新报告正文可直接在 `report.tex` 中填写，保留 `\makecover` / `\maketitle`、`fullreportonly` 和 `\insertnotes` 等模板接口。

配图采用相对实验目录的完整路径，例如：

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.7\textwidth]{figures/diagrams/实验原理.png}
  \caption{实验原理}
  \label{fig:principle}
\end{figure}
```

不要把图复制到多个报告版本中；同一实验的报告可以共享 `figures/`。公开版本的 `\name{}` 和 `\stuid{}` 保持为空。课程提交版可在本地填写，提交 Git 前运行下方匿名化命令。

## 编译报告

安装包含 **XeLaTeX、latexmk 和中文宏包**的 TeX Live / MacTeX。共享模板直接加载 `templates/fonts/` 中的字体，不依赖系统中是否安装同名字体。

从仓库根目录编译一份报告：

```bash
python3 scripts/build_reports.py "experiments/惠斯登电桥/report.tex"
```

编译全部报告并打包：

```bash
python3 scripts/build_reports.py --jobs 2 --zip
```

PDF 保存到 `build/reports/实验名称/`，日志保存到 `build/logs/实验名称/`，合集为 `build/reports.zip`。失败时脚本返回非零状态，不生成 ZIP，也不会用旧 PDF 冒充本次成功产物。指定部分报告时，ZIP 只包含本次指定的报告。

也可以在某个实验目录中直接运行：

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error report.tex
```

MATLAB 程序位于各实验的 `analysis/`，图像输出路径已改为对应实验的 `figures/plots/`。原有程序可能使用 MATLAB 工具箱；弗兰克赫兹实验的 `genTexFromCsvData.py` 还需要 `pandas`。这些是旧数据处理程序的依赖，与仓库辅助脚本无关。

## 提交前过滤姓名与学号

**过滤范围只有 `.tex` 文件。** `.py`、`.m`、`.cls`、Markdown、CSV、图片和 PDF 的内容均不检查或替换。原始照片按本仓库约定保留，不做 OCR、打码或元数据清理，因此这不是对整个仓库的完全匿名化。

先检查工作区，包括未跟踪、尚未 `git add` 的 TeX 文件：

```bash
python3 scripts/privacy.py --check
```

自动清空 TeX 身份字段并隐藏匹配到的信息：

```bash
python3 scripts/privacy.py --fix
```

脚本识别 `\name{...}`、`\stuid{...}`（包括换行及嵌套花括号）、其他学生姓名/学号字段、明确带姓名或学号标签的文字，以及常见的以 3 开头的十位学号。姓名字段中发现的姓名会用于检查其他 TeX 正文和注释。它不会猜测所有中文词语是否为姓名；脱离字段的姓名需要本地敏感词补充，特殊格式学号也应使用字段或敏感词。数字匹配可能误判测量值，运行 `--fix` 后应检查差异。

如需补充敏感词，在本地建立 `.private/privacy-terms.json`，填入 `{"names": [], "ids": []}`，再将要过滤的姓名、学号添加到相应数组。该文件禁止提交。此次整理已在当前机器上保存发现的词表；其他人的 clone 和 GitHub CI 不包含它，只使用通用规则。

`--fix` 会先把原始文件备份到 `.private/privacy-backups/`，再修改工作区；不会自动暂存或提交。输出仅给出文件、行号和规则，不回显身份信息。发现身份信息时检查退出码为 1，检查无法完成时为 2。

**匿名化之后务必重新 `git add`，再检查暂存区：**

```bash
python3 scripts/privacy.py --fix
git add -A
python3 scripts/privacy.py --check --staged
```

`--staged` 读取将进入提交的 Git blob，不会被工作区中尚未暂存的修改误导。不能和 `--fix` 同时使用。若 TeX 文件名本身包含姓名或学号，需要手动重命名并修正引用。

可选：为本地仓库启用提交前自动检查。如果已经设置了 `core.hooksPath`，先合并已有 hook：

```bash
git config --get core.hooksPath
git config core.hooksPath .githooks
```

hook 只检查、不改文件；有问题时拒绝提交。`.gitignore` 会忽略本地备份和编译输出。已经进入旧提交、旧 Release 或其他副本的信息不会因这次整理自动消失，本工具不改写历史。

## 如何提 PR

没有仓库写权限时，先在 GitHub Fork 仓库，再克隆自己的 Fork；已有本地 clone 可以把自己的 Fork 配置为用于推送的 remote。以下命令在自己的 clone 根目录执行，`origin` 应指向你有权限推送的仓库。

```bash
git switch -c experiment/add-pendulum
python3 scripts/new_experiment.py "单摆法测量重力加速度"
# 编辑报告，放入图片和数据后：
python3 scripts/privacy.py --fix
python3 scripts/check_repository.py
python3 scripts/build_reports.py "experiments/单摆法测量重力加速度/report.tex"
python3 -m unittest discover -s tests -v
git add -A
python3 scripts/privacy.py --check --staged
git diff --cached --stat
git commit -m "添加单摆实验报告"
git push -u origin experiment/add-pendulum
```

然后在 GitHub 选择 **Compare & pull request**，目标仓库选 `YuNa-Zju/phy_exp`，目标分支选默认分支（当前为 `master`）。说明实验名称、修改原因和验证结果，按 PR 模板填写。只提交本次实验或修复涉及的文件，确认没有带入本地备份。

`Reports` workflow 会在 PR 时执行 `Privacy and structure` 和 `Compile reports`：先检查暂存快照中的 TeX、路径和 Python 测试，再编译全部报告。PR 仅上传构建附件；推送到上游仓库默认分支且全部成功后，才发布新的报告合集。维护者可把这两个检查设为分支保护中的必需检查。

## GitHub Actions

工作流位于 [reports.yml](.github/workflows/reports.yml)，使用 GitHub 托管的 Ubuntu runner 和 TeX Live 2026 容器，不需要自建 runner 或手动安装系统中文字体。可在 Actions 页选择 **Reports → Run workflow** 手动验证；手动运行不会发布 Release。

某份报告失败时，查看 Actions 中上传的 `latex-logs` 附件；本地用相同的 `build_reports.py` 命令复现。成功时可下载 `reports` 附件；默认分支自动发布的合集在 [Releases](https://github.com/YuNa-Zju/phy_exp/releases/latest)。

配置参考：[GitHub 的 PR 触发事件](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#pull_request)、[TeX Live Action 官方说明](https://github.com/xu-cheng/texlive-action)。

## 实验索引

| 实验 | 报告版本数 |
| --- | ---: |
| [万用表的设计](experiments/%E4%B8%87%E7%94%A8%E8%A1%A8%E7%9A%84%E8%AE%BE%E8%AE%A1/README.md) | 3 |
| [交流电功率因数与整流器](experiments/%E4%BA%A4%E6%B5%81%E7%94%B5%E5%8A%9F%E7%8E%87%E5%9B%A0%E6%95%B0%E4%B8%8E%E6%95%B4%E6%B5%81%E5%99%A8/README.md) | 3 |
| [光栅衍射实验](experiments/%E5%85%89%E6%A0%85%E8%A1%8D%E5%B0%84%E5%AE%9E%E9%AA%8C/README.md) | 1 |
| [光电效应测定普朗克常数](experiments/%E5%85%89%E7%94%B5%E6%95%88%E5%BA%94%E6%B5%8B%E5%AE%9A%E6%99%AE%E6%9C%97%E5%85%8B%E5%B8%B8%E6%95%B0/README.md) | 3 |
| [光的偏振应用研究](experiments/%E5%85%89%E7%9A%84%E5%81%8F%E6%8C%AF%E5%BA%94%E7%94%A8%E7%A0%94%E7%A9%B6/README.md) | 1 |
| [光的衍射](experiments/%E5%85%89%E7%9A%84%E8%A1%8D%E5%B0%84/README.md) | 1 |
| [光速测量](experiments/%E5%85%89%E9%80%9F%E6%B5%8B%E9%87%8F/README.md) | 1 |
| [分光计的调整和使用](experiments/%E5%88%86%E5%85%89%E8%AE%A1%E7%9A%84%E8%B0%83%E6%95%B4%E5%92%8C%E4%BD%BF%E7%94%A8/README.md) | 2 |
| [双棱镜干涉](experiments/%E5%8F%8C%E6%A3%B1%E9%95%9C%E5%B9%B2%E6%B6%89/README.md) | 1 |
| [双臂电桥测低电阻](experiments/%E5%8F%8C%E8%87%82%E7%94%B5%E6%A1%A5%E6%B5%8B%E4%BD%8E%E7%94%B5%E9%98%BB/README.md) | 1 |
| [固定均匀弦振动的研究](experiments/%E5%9B%BA%E5%AE%9A%E5%9D%87%E5%8C%80%E5%BC%A6%E6%8C%AF%E5%8A%A8%E7%9A%84%E7%A0%94%E7%A9%B6/README.md) | 1 |
| [声速测定](experiments/%E5%A3%B0%E9%80%9F%E6%B5%8B%E5%AE%9A/README.md) | 1 |
| [密立根油滴](experiments/%E5%AF%86%E7%AB%8B%E6%A0%B9%E6%B2%B9%E6%BB%B4/README.md) | 2 |
| [弗兰克赫兹实验](experiments/%E5%BC%97%E5%85%B0%E5%85%8B%E8%B5%AB%E5%85%B9%E5%AE%9E%E9%AA%8C/README.md) | 2 |
| [惠斯登电桥](experiments/%E6%83%A0%E6%96%AF%E7%99%BB%E7%94%B5%E6%A1%A5/README.md) | 5 |
| [棱镜偏向角特性](experiments/%E6%A3%B1%E9%95%9C%E5%81%8F%E5%90%91%E8%A7%92%E7%89%B9%E6%80%A7/README.md) | 1 |
| [测量液体表面张力系数](experiments/%E6%B5%8B%E9%87%8F%E6%B6%B2%E4%BD%93%E8%A1%A8%E9%9D%A2%E5%BC%A0%E5%8A%9B%E7%B3%BB%E6%95%B0/README.md) | 1 |
| [用霍尔法测直流圆线圈与亥姆霍兹线圈磁场](experiments/%E7%94%A8%E9%9C%8D%E5%B0%94%E6%B3%95%E6%B5%8B%E7%9B%B4%E6%B5%81%E5%9C%86%E7%BA%BF%E5%9C%88%E4%B8%8E%E4%BA%A5%E5%A7%86%E9%9C%8D%E5%85%B9%E7%BA%BF%E5%9C%88%E7%A3%81%E5%9C%BA/README.md) | 2 |
| [示波器的应用](experiments/%E7%A4%BA%E6%B3%A2%E5%99%A8%E7%9A%84%E5%BA%94%E7%94%A8/README.md) | 2 |
| [等厚干涉](experiments/%E7%AD%89%E5%8E%9A%E5%B9%B2%E6%B6%89/README.md) | 2 |
| [金属材料杨氏模量的测定](experiments/%E9%87%91%E5%B1%9E%E6%9D%90%E6%96%99%E6%9D%A8%E6%B0%8F%E6%A8%A1%E9%87%8F%E7%9A%84%E6%B5%8B%E5%AE%9A/README.md) | 4 |
| [铁磁材料的磁滞回线和基本磁化曲线](experiments/%E9%93%81%E7%A3%81%E6%9D%90%E6%96%99%E7%9A%84%E7%A3%81%E6%BB%9E%E5%9B%9E%E7%BA%BF%E5%92%8C%E5%9F%BA%E6%9C%AC%E7%A3%81%E5%8C%96%E6%9B%B2%E7%BA%BF/README.md) | 2 |
| [非平衡电桥](experiments/%E9%9D%9E%E5%B9%B3%E8%A1%A1%E7%94%B5%E6%A1%A5/README.md) | 2 |

## 模板与学习资源

共享模板基于 [CC98 大二物理实验报告 LaTeX 模版](https://www.cc98.org/topic/6284556) 修改。原始模板源码保留在 `templates/legacy/`，当前实验请使用 `templates/Report.cls`。

- [Typst 模板](https://www.cc98.org/topic/6286687)
- [CC98 大学物理实验报告讨论](https://www.cc98.org/topic/6076104)
- [咸鱼暄的大学物理实验资料](https://xuan-insr.github.io/other_courses/big_physics_exp/)
- [大物绪论与误差分析](references/大物绪论_误差分析.pdf)

报告用于学习交流；不同版本可能使用不同实验数据，使用时请核对自己的记录和课程要求。
