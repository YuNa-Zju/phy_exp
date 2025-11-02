\ProvidesClass{Preport}
\LoadClass{ctexart}
\RequirePackage{graphicx, xcolor, tikz, amsmath}
\RequirePackage{geometry, titlesec, fancyhdr}
\RequirePackage{listings, cncolours}
\RequirePackage{indentfirst, enumitem, zhnumber}
\RequirePackage{fontspec, stackengine}
\RequirePackage{silence}
\WarningFilter{latexfont}{Some font shapes}
\WarningFilter{latexfont}{Font shape}
\RequirePackage{float, siunitx}
\RequirePackage{booktabs, tabularx, array, subcaption, hyperref}
\RequirePackage{currfile, cleveref, comment, multirow, enumitem}
\hypersetup{
    colorlinks=true,
}
%%%%%%%%%%%%%%%%%%%%%单位格式
\sisetup{
    separate-uncertainty = true,
    per-mode = symbol
}
%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%引用格式
\crefname{figure}{图}{图}
\crefname{table}{表}{表}
\crefname{equation}{式}{式}
% \crefmultiformat{figure}{图~#1}{ 和~#1}{、#1}{ 和~#1}

% 更复杂的格式，例如想让引用显示为 “图 1-1”
% #1 是标签名, #2 是数字, #3 是备注
\crefformat{figure}{图~#2#1#3}
\crefformat{table}{表~#2#1#3}
\crefformat{equation}{式~(#2#1#3)}
%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%报告标题
\newcommand{\@reporttitle}{}
\newif\ifpreviewreport

% 声明选项 'yuxi'
% 当在 \documentclass 中检测到 'yuxi' 时，执行以下所有操作
\DeclareOption{yuxi}{
  \renewcommand{\@reporttitle}{物理实验预习报告}
  \excludecomment{fullreportonly}
  \previewreporttrue
}

% 声明选项 'bg'
% 当在 \documentclass 中检测到 'bg' 时，执行以下所有操作
\DeclareOption{bg}{
  \renewcommand{\@reporttitle}{物~理~实~验~报~告}
  % \includecomment 是 comment 宏包的命令，确保环境生效
  \includecomment{fullreportonly}
  \previewreportfalse
}

% 3. ★★★ 设置默认值并执行选项 ★★★
% 如果用户没有提供任何选项，则默认执行 'bg' 选项
\ExecuteOptions{bg}

% 现在，处理用户在 \documentclass[...]{...} 中实际传入的选项
% 它会覆盖上面的默认设置
\ProcessOptions\relax
%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%模板文件夹路径
\newcommand{\templatedir}{./}
\newcommand{\settemplatedir}[1]{\renewcommand{\templatedir}{#1}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%表格列格式
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
\newcolumntype{R}[1]{>{\raggedleft\arraybackslash}p{#1}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%基础设置
% 设置版式
\linespread{1.2}
\geometry{top=1in,bottom=1in,left=1.91cm,right=1.91cm}

% 设置标题和字体格式
\setCJKmainfont[ItalicFont={KaiTi},BoldFont={SimHei}]{SimSun}
\setmonofont{DejaVu Sans Mono}
\setCJKfamilyfont{KaiTi}[AutoFakeBold=2.5]{KaiTi}

% 伪粗宋体
\newCJKfontfamily\fakeboldsong{SimSun}[AutoFakeBold = 2.5]
\newcommand{\fbsong}[1]{{\fakeboldsong\bfseries #1}}
% 伪粗仿宋体
\newCJKfontfamily\fakeboldfangsong{FangSong}[AutoFakeBold = 2.5]
\newcommand{\fbfangsong}[1]{{\fakeboldfangsong\bfseries #1}}

\setcounter{secnumdepth}{3}
\renewcommand\thesection{\zhnumber{\arabic{section}}、\hspace{-5.53mm}}
\renewcommand\thesubsection{\arabic{subsection}\hspace{-2.415mm}}
\renewcommand\thesubsubsection{\arabic{subsection}.\arabic{subsubsection}\hspace{-2.415mm}}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=\alph*.}
\titleformat{\section}[hang]{\Large\fakeboldsong\bfseries}{\textrm{\thesection}}{1em}{}
\titleformat{\subsection}[hang]{\large\fakeboldsong\bfseries}{\textrm{\thesubsection}}{1em}{}
\titleformat{\subsubsection}[hang]{\normalsize\fakeboldsong\bfseries}{\textrm{\thesubsubsection}}{1em}{}

% 代码格式和颜色定义
\colorlet{keyword}{松花绿}
\colorlet{comment}{漆黑!50}
\colorlet{emph1}{靛蓝}
\colorlet{emph2}{琥珀}
\lstset{
  frame=tb,
  framerule=0.5pt,
  numbers=none,
  breaklines=true,
  breakatwhitespace=true,
  keywordstyle = \bfseries\color{keyword},
  commentstyle = \itshape\color{comment},
  emphstyle    = [1]\itshape\color{emph1},
  emphstyle    = [2]\color{emph2},
  basicstyle   = {\small\ttfamily},
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%信息定义
% 信息
%\newcommand\major[1]{\def\@major{#1}}
%\newcommand\course[1]{\def\@course{#1}}
\newcommand\exname[1]{\def\@exname{#1}}
\newcommand\extable[1]{\def\@extable{#1}}
\newcommand\instructor[1]{\def\@instructor{#1}}

\newcommand\class[1]{\def\@class{#1}}
\newcommand\name[1]{\def\@name{#1}}
\newcommand\stuid[1]{\def\@stuid{#1}}


\newcommand\nyear[1]{\def\@nyear{#1}}
\newcommand\nmonth[1]{\def\@nmonth{#1}}
\newcommand\nday[1]{\def\@nday{#1}}
\newcommand\nweekday[1]{\def\@nweekday{#1}}

\newcommand\redate[1]{\def\@redate{#1}}
\newcommand\resitu[1]{\def\@resitu{#1}}
\newcommand\daypart[1]{\def\@daypart{#1}}
%\newcommand\college[1]{\def\@college{#1}}
%\newcommand\lab[1]{\def\@lab{#1}}
%\newcommand\grades[1]{\def\@grades{#1}}
%\newcommand\expname[1]{\def\@expname{#1}}
%\newcommand\exptype[1]{\def\@exptype{#1}}
%\newcommand\partner[1]{\def\@partner{#1}}
%%%%%%%%%%%%%%%%%%%%%%%%%%%

\graphicspath{{figures/}{\templatedir figures/}}
\renewcommand{\figurename}{图}
\renewcommand{\tablename}{表}

%%%%%%%%%%%%%%%%%%%%%%%%%%%注意事项插入
\newcommand{\insertnotes}{%
  % 在插入文件前，先用 \IfFileExists 检查文件是否存在
  \IfFileExists{\templatedir note.tex}
  {% 如果文件存在 (TRUE block)
    \par\vfill\noindent
    \input{\templatedir note} % 执行插入操作
  }
  {% 如果文件不存在 (FALSE block)
    % 在编译日志(.log)和终端中打印一条明确的警告信息
    \PackageWarning{myphydreport}{
      Notes file not found! I was looking for it at the exact path: '\templatedir/note'
    }
  }%
}
%%%%%%%%%%%%%%%%%%%%%%%%%%%
\pagestyle{plain}
%\lhead{实验名称：\@expname}
%\chead{姓名：\@name}
%\rhead{学号：\@stuid}

% 下划线定义
\newcommand{\underlinetext}[2][3cm]{%
  \stackunder[0.8ex]{\makebox[#1][c]{#2}}{\rule{#1}{1pt}}%
}

% 封面
\newcommand{\@makecover@preview}{%
  \phantom{\fontsize{42pt}{50.4pt}\selectfont wcnm的LaTeX}

    \begin{center}
    {\fontsize{36pt}{6pt}\selectfont \fbsong{物理实验预习报告}}\\
    \vspace{15.18mm}
    \vspace{17.712mm}

    \Large
    \centering
    \renewcommand\arraystretch{2}
    \begin{tabular}{l@{}l}
      \fbsong{实验名称：} & \underlinetext[69.125mm]{\@exname} \\
      \fbsong{指导教师：} & \underlinetext[69.125mm]{\@instructor}
    \end{tabular}

    \vspace{19.08mm}
    \large
    \centering
    \renewcommand\arraystretch{2}
    \begin{tabular}{l@{}l}
      \fbsong{班级：} & \underlinetext[79.695mm]{\@class}  \\
      \fbsong{姓名：} & \underlinetext[79.695mm]{\@name}   \\
      \fbsong{学号：} & \underlinetext[79.695mm]{\@stuid}
    \end{tabular}

    \vspace{8.694mm}

    \begin{center}
      \large{\fbsong{实验日期：}\underlinetext[9.66mm]{\@nyear}\fbsong{年}\underlinetext[9.66mm]{\@nmonth}\fbsong{月}\underlinetext[9.66mm]{\@nday}\fbsong{日}\hspace{7.245mm}\fbsong{星期}\underlinetext[7.245mm]{\@nweekday}\fbsong{\@daypart}}

      \vspace{8.694mm}

    \large{浙江大学物理实验教学中心}
    \end{center}
  \end{center}
  \thispagestyle{plain}
  \newpage
}

% 命令二：定义“正式报告”封面的具体样式
\newcommand{\@makecover@full}{%
  \begin{center}
    \begin{center}
      \includegraphics[width=0.4\linewidth]{浙江大学}
    \end{center}

    {\fontsize{36pt}{6pt}\selectfont \fbsong{物~理~实~验~报~告}}\\
    \vspace{12.65mm}
    \vspace{18.45mm}

    \Large
    \centering
    \renewcommand\arraystretch{2}
    \begin{tabular}{l@{}l}
      \fbsong{实验名称：} & \underlinetext[69.125mm]{\@exname} \\
      \fbsong{实验桌号：} & \underlinetext[69.125mm]{\@extable} \\
      \fbsong{指导教师：} & \underlinetext[69.125mm]{\@instructor}
    \end{tabular}

    \vspace{18.45mm}
    \large
    \centering
    \renewcommand\arraystretch{2}
    \begin{tabular}{l@{}l}
      \fbsong{班级：} & \underlinetext[79.695mm]{\@class}  \\
      \fbsong{姓名：} & \underlinetext[79.695mm]{\@name}   \\
      \fbsong{学号：} & \underlinetext[79.695mm]{\@stuid}
    \end{tabular}

    \vspace{4.83mm}

    \begin{center}
      \large{\fbsong{实验日期：}\underlinetext[9.66mm]{\@nyear}\fbsong{年}\underlinetext[9.66mm]{\@nmonth}\fbsong{月}\underlinetext[9.66mm]{\@nday}\fbsong{日}\hspace{7.245mm}\fbsong{星期}\underlinetext[7.245mm]{\@nweekday}\fbsong{\@daypart}}\\
    \textcolor[gray]{0.4}{\small{（此处填实验选课系统内日期）}}\\
    \large{浙江大学物理实验教学中心}
    \end{center}
  \end{center}

  \vspace{4.2175mm}

  \begin{flushleft}
    \textcolor[gray]{0.4}{\normalsize{\fbsong{如有实验补做，补做日期：}}}\@redate \\
    \textcolor[gray]{0.4}{\normalsize{\fbsong{情况说明：}}}\@resitu
  \end{flushleft}
  \thispagestyle{plain}
  \newpage
}

% 命令三：定义用户使用的总命令 \makecover
% 这个命令内部不做任何排版，只做逻辑判断和分发
\newcommand{\makecover}{%
  \ifpreviewreport
    \@makecover@preview  % 如果是预习报告，调用预习封面的命令
  \else
    \@makecover@full     % 否则，调用正式封面的命令
  \fi
}
\let\maketitle\makecover

%%%%%%%%%%%%%%%%%%%%%%%%%%%%数学符号
\renewcommand{\d}{\mathrm{d}}
\newcommand{\e}{\mathrm{e}}
\newcommand{\dv}[3][]{%
  \frac{\d^{#1} #2}{\d #3^{#1}}} %求n阶导数的Leibniz符号, 当n=1时第一个变量不填.
\newcommand{\pdv}[3][]{%
  \frac{\pa^{#1} #2}{\pa {#3}^{#1}}}