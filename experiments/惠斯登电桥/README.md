# 惠斯登电桥

报告版本按原文件保留，编号不代表新旧或推荐顺序。

| 报告 | 原路径 |
| --- | --- |
| [report.tex](report.tex) | `惠斯登电桥/惠斯登电桥.tex` |
| [report-02.tex](report-02.tex) | `惠斯登电桥/惠斯登电桥2.tex` |
| [report-03.tex](report-03.tex) | `惠斯登电桥/惠斯登电桥3.tex` |
| [report-04.tex](report-04.tex) | `惠斯登电桥/惠斯登电桥4.tex` |
| [report-05.tex](report-05.tex) | `惠斯登电桥/惠斯登电桥5.tex` |

图片分为 [原理图](figures/diagrams/)、[结果图](figures/plots/) 和 [照片与扫描件](figures/photos/)，内容保持原样。数据放在 `data/`，处理程序放在 `analysis/`。

从仓库根目录编译：

```bash
python3 scripts/build_reports.py "experiments/惠斯登电桥/report.tex"
```

新建实验、匿名化和提交 PR 的方法见[仓库 README](../../README.md)。
