\ProvidesClass{Phyport}
\LoadClass{ctexart}
\RequirePackage{graphicx, xcolor, tikz}
\RequirePackage{geometry, titlesec, fancyhdr}
\RequirePackage{listings}
\RequirePackage{indentfirst, enumitem, zhnumber}
\RequirePackage{fontspec, stackengine}
\RequirePackage{silence}
\WarningFilter{latexfont}{Some font shapes}
\WarningFilter{latexfont}{Font shape}
\RequirePackage{float, siunitx}
\RequirePackage{booktabs}
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
\renewcommand\thesubsection{\arabic{subsection}、\hspace{-2.415mm}}
\renewcommand\thesubsubsection{\arabic{subsubsection}.\hspace{-2.415mm}}
\setlist[enumerate,1]{label=(\arabic*)}
\setlist[enumerate,2]{label=\alph*.}
\titleformat*{\section}{\Large\bfseries}
\titleformat*{\subsection}{\large\fakeboldsong\bfseries}
\titleformat*{\subsubsection}{\normalsize}

% 代码格式和颜色定义
\definecolor{keyword}{RGB}{96,154,89}
\definecolor{comment}{RGB}{0,0,0}
\definecolor{emph1}{RGB}{25,25,112}
\definecolor{emph2}{RGB}{255,165,0}
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

%\newcommand\college[1]{\def\@college{#1}}
%\newcommand\lab[1]{\def\@lab{#1}}
%\newcommand\grades[1]{\def\@grades{#1}}
%\newcommand\expname[1]{\def\@expname{#1}}
%\newcommand\exptype[1]{\def\@exptype{#1}}
%\newcommand\partner[1]{\def\@partner{#1}}
\graphicspath{{../figures/}}

\pagestyle{plain}
%\lhead{实验名称：\@expname}
%\chead{姓名：\@name}
%\rhead{学号：\@stuid}

% 下划线定义
\newcommand{\underlinetext}[2][3cm]{%
  \stackunder[0.8ex]{\makebox[#1][c]{#2}}{\rule{#1}{1pt}}%
}

% 封面
\newcommand{\makecover}{
  \begin{center}
    \begin{center}
      \includegraphics[width=0.4\linewidth]{../figures/浙江大学}
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
      \large{\fbsong{实验日期：}\underlinetext[9.66mm]{\@nyear}\fbsong{年}\underlinetext[9.66mm]{\@nmonth}\fbsong{月}\underlinetext[9.66mm]{\@nday}\fbsong{日}\hspace{7.245mm}\fbsong{星期}\underlinetext[7.245mm]{\@nweekday}\fbsong{上/下午}}\\
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
\endinput
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}
\newcolumntype{R}[1]{>{\raggedleft\arraybackslash}p{#1}}
% 三线表使用方法
% \begin{table}[H]
%   \centering
%   \caption{}
%   \begin{tabular}{C{.3\textwidth}C{.3\textwidth}C{.3\textwidth}}
%   \toprule
%   读取值  & 测量值  & 计算误差 \\
%   \midrule
%   10000$\Omega$  & 10001$\Omega$  & 0.01\%  \\
%   100$\Omega$    & 100.4$\Omega$  & 0.40\%  \\
%   100k$\Omega$ & 100.25k$\Omega$ & 0.25\%  \\
%   \bottomrule
%   \end{tabular}
% \end{table}