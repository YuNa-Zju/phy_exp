# 大学物理实验报告

浙江大学大学物理实验的报告与 LaTeX 模板。[浏览实验](experiments/README.md) · [下载 PDF 报告](https://github.com/YuNa-Zju/phy_exp/releases/latest)

## 开始使用

安装 Python 3.10+，以及 TeX Live（Windows / Linux）或 MacTeX（macOS）。在 GitHub 点击 **Code → Download ZIP**，解压后打开项目文件夹。在包含 `README.md` 的这一层打开终端，执行下面的命令。Windows 上可将 `python3` 换成 `python`。

### 新建报告

```bash
python3 scripts/new_experiment.py "单摆法测量重力加速度"
```

打开生成的 `experiments/单摆法测量重力加速度/report.tex`，按提示填写。对同一实验再次运行命令，会依次生成 `report-02.tex`、`report-03.tex`；已有多份报告时，接着最大序号创建。

预习报告在命令末尾加 `--preview`：

```bash
python3 scripts/new_experiment.py "单摆法测量重力加速度" --preview
```

图片放在该实验的 `figures/` 下：原理图用 `diagrams/`，结果图用 `plots/`，照片用 `photos/`。文件名可以带报告序号，例如 `原始数据-02.jpg`。

### 生成 PDF

```bash
python3 scripts/build_reports.py "experiments/单摆法测量重力加速度/report.tex"
```

生成的 PDF 位于 `build/reports/单摆法测量重力加速度/`。编译其他版本时，把命令里的 `report.tex` 换成相应文件名。

## 常用 LaTeX 写法

完整的[报告模板](templates/report.tex)会由新建脚本自动复制。下面的代码可以直接放进报告正文。

### 单位与公式

```tex
\SI{10}{mA}                                % 数值和单位
\si{\meter\per\second}                     % 仅单位：米每秒
\si{\degreeCelsius}                        % 摄氏度
\SI{9.8}{\meter\per\second\squared}         % 加速度
\SI{1.23e-4}{\pascal\second}                % 科学计数法
```

行内公式用 `$...$`，单独一行的公式用 `\[...\]`：

```tex
由周期 $T$ 计算重力加速度：
\[
  g = \frac{4\pi^2 L}{T^2}
\]
```

### 三线表与自动换行

`C{...}` 表示居中且宽度固定的列，较长的文字会自动换行。

```tex
\begin{table}[H]
  \centering
  \caption{电阻测量结果}
  \label{tab:resistance}
  \begin{tabular}{C{.3\textwidth}C{.3\textwidth}C{.3\textwidth}}
    \toprule
    读取值 & 测量值 & 相对误差 \\
    \midrule
    \SI{10000}{\ohm} & \SI{10001}{\ohm} & 0.01\% \\
    \SI{100}{\ohm}   & \SI{100.4}{\ohm} & 0.40\% \\
    \SI{100}{\kilo\ohm} & \SI{100.25}{\kilo\ohm} & 0.25\% \\
    \bottomrule
  \end{tabular}
\end{table}
```

### 插入图片

把路径换成自己图片的位置，`0.7\textwidth` 表示图片宽度为正文的 70%。

```tex
\begin{figure}[htbp]
  \centering
  \includegraphics[width=0.7\textwidth]{figures/diagrams/实验原理.png}
  \caption{实验原理}
  \label{fig:principle}
\end{figure}
```

<details>
<summary>一行放两张图片</summary>

```tex
\begin{figure}[htbp]
  \centering
  \begin{subfigure}[b]{0.45\textwidth}
    \includegraphics[width=\textwidth]{figures/diagrams/电路设计.png}
    \caption{多量程电流表设计电路}
    \label{fig:design}
  \end{subfigure}
  \hfill
  \begin{subfigure}[b]{0.45\textwidth}
    \includegraphics[width=\textwidth]{figures/diagrams/电路校验.png}
    \caption{多量程电流表校验电路}
    \label{fig:calibration}
  \end{subfigure}
  \caption{多量程电流表相关电路}
\end{figure}
```

</details>

### 引用图表

给图表添加 `\label{...}` 后，在正文中用 `\cref{...}` 引用，编号会自动更新：

```tex
实验原理见\cref{fig:principle}，测量结果见\cref{tab:resistance}。
```

## 分享报告：提交 PR

PR（Pull Request）就是把自己的修改提交给仓库维护者，审核后加入这个仓库。下面两种方式任选一种。

上传前，在本地项目根目录运行以下命令，清空 TeX 中的姓名和学号，再生成 PDF 检查报告内容：

```bash
python3 scripts/privacy.py --fix
```

### 使用 GitHub 网页

1. 登录 GitHub，在本仓库页面点击 **Fork → Create fork**，获得自己账号下的副本。
2. 在自己的副本中打开 `experiments/`，点击 **Add file → Upload files**，将本地这次修改的实验文件夹拖入上传区域，例如 `单摆法测量重力加速度/`。这样报告与 `figures/` 图片会保留原来的目录关系。
3. 填写修改说明，选择 **Create a new branch**，分支名可填 `add-pendulum`，点击 **Propose changes** 保存。
4. 回到[本仓库](https://github.com/YuNa-Zju/phy_exp)，点击 **Pull requests → New pull request → compare across forks**。左侧目标仓库选 `YuNa-Zju/phy_exp`、分支选 `master`；右侧选自己的副本和刚才的 `add-pendulum` 分支。
5. 点击 **Create pull request**，填写实验名称和修改说明，再次点击 **Create pull request** 提交。

图文参考：[上传文件](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository) · [从 Fork 提交 PR](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-a-pull-request-from-a-fork)。

### 使用 GitHub Desktop

1. 在本仓库页面点击 **Fork**，获得自己账号下的副本。在 [GitHub Desktop](https://desktop.github.com/) 中选择 **File → Clone Repository**，将这个副本下载到电脑。
2. 在 **Current Branch → New Branch** 新建分支，例如 `add-pendulum`。在这个文件夹中添加或修改报告；已经写好的报告和图片也可以复制进来。
3. 运行上面的姓名学号清理命令后，回到 GitHub Desktop，勾选本次修改的文件，在 **Summary** 写上说明，点击 **Commit**，再点击 **Publish branch** 或 **Push origin** 上传。
4. 点击 **Preview Pull Request → Create Pull Request**，在网页上确认目标仓库为 `YuNa-Zju/phy_exp`、目标分支为 `master`，填写实验名称和修改说明，提交即可。

图文参考：[下载自己的副本](https://docs.github.com/en/desktop/adding-and-cloning-repositories/cloning-and-forking-repositories-from-github-desktop) · [提交 PR](https://docs.github.com/en/desktop/working-with-your-remote-repository-on-github-or-github-enterprise/creating-an-issue-or-pull-request-from-github-desktop)。

## 模板与参考资料

本模板参考 [CC98 大二物理实验报告 LaTeX 模版](https://www.cc98.org/topic/6284556) 修改。

- [Typst 模板](https://www.cc98.org/topic/6286687)
- [CC98 大学物理实验报告讨论](https://www.cc98.org/topic/6076104)
- [咸鱼暄的大学物理实验资料](https://xuan-insr.github.io/other_courses/big_physics_exp/)
- [大物绪论与误差分析](references/大物绪论_误差分析.pdf)
