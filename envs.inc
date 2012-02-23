\edef\minted@resetoptions{\minted@resetoptions\def\minted@opt@bgcolor{foo}}
\tikzset{mintedbox/.style={draw=sourcecodeborder, fill=sourcecodebg, thick, rectangle, rounded corners, inner sep=18pt, inner ysep=10pt}}
\renewenvironment{minted@colorbg}[1]{%
  \noindent
  \begin{lrbox}{\minted@bgbox}
  \begin{minipage}{0.88\textwidth}}
 {\end{minipage}
  \end{lrbox}%
  \tikz\node[mintedbox] 
         {\usebox{\minted@bgbox}};
 }

\newmint[jscode]{javascript}{}
\newmint[htmlcode]{html}{}