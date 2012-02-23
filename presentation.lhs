%if False
\begin{code}
module Main where  

import Language.UHC.JScript.Prelude
import Language.UHC.JScript.JQuery.JQuery

import Language.UHC.JScript.Assorted ( alert )
\end{code}
%endif

\documentclass{beamer}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[utf8]{inputenc}
\usepackage{parskip, graphicx}
\usepackage[english]{babel}
\usepackage{csquotes, multicol}
\usepackage[]{minted}
\usepackage[backend=biber]{biblatex}
\usepackage{xspace, amsmath, color, tikz}
% \usepackage[unicode=true,colorlinks=true]{hyperref}
\makeatletter
\input{envs.inc}
\usemintedstyle{solarized}

%include polycode.fmt
%include presentation.fmt
%include solarized.sty

\tikzstyle{haskellbox} = [draw=sourcecodeborder, fill=sourcecodebg, thick,
    rectangle, rounded corners, inner sep=0pt, inner ysep=0pt]
%subst code a = "\begin{tikzpicture} \node [haskellbox] (box){ \begin{minipage}{\textwidth} \begin{hscode}\SaveRestoreHook'n" a "\ColumnHook'n\end{hscode}\resethooks'n \end{minipage} }; \end{tikzpicture}"


\definecolor{sourcecodebg}{RGB}{248, 248, 248}
\definecolor{sourcecodeborder}{RGB}{208, 208, 208}

\def\ci{\perp\!\!\!\perp}
\def\haskell{Haskell\xspace}
\def\js{JavaScript\xspace}
\def\pl{Prolog\xspace}
\def\jq{jQuery\xspace}
\def\jqui{jQuery UI\xspace}
\def\uhc{UHC\xspace}
\def\ghc{GHC\xspace}
\def\brunch{\verb+Brunch.IO+\xspace}
\def\uhcjs{\verb+uhc-jscript+\xspace}
\def\coffeescript{\verb+coffeescript+\xspace}

\title{The \uhc \js backend and the JCU Prolog app}
\author{Alessandro Vermeulen (3242919)\\ Computing Science Department \\ Utrecht University}

\begin{document}
\begin{frame}
  \maketitle
\end{frame}

\begin{frame}{Today}
  \tableofcontents
\end{frame}

\section{What and Why?}
\begin{frame}{The reason}
  Programming in \js is a pain. The following issues are cause to this:
  
  \begin{itemize}
    \item No type system
    \item No easy partial application
    \item Easy to make mistakes
    \item Verbose syntax
    \item Crazy evaluation rules\\
          \url(https://www.destroyallsoftware.com/talks/wat)
  \end{itemize}
\end{frame}

\begin{frame}
  \begin{block}{How can we circumvent this?}
    Easy, program in \haskell and let your compiler generate the \js code!
  \end{block}
\end{frame}

\begin{frame}  
  \begin{block}{Advantages}
    \begin{itemize}
      \item Type safety 
      \item Having an annoying checking and optimising nanny
      \item Use the same libraries on client and server
      \item Indirectly test your client code by using QuickCheck
      \item Sweet goodness of \haskell
    \end{itemize}
  \end{block}
\end{frame}

\begin{frame}{Other benefits}
  \begin{enumerate}
    \item We don't have to use \js for web applications
    \item We can make really portable \haskell applications!
    \item Server and client can speak the same language. \small{sortoff}
    \item A shared codebase between server and client
  \end{enumerate}
\end{frame}

\section{The UHC-JS backend}
\begin{frame}
  \begin{block}{Required Ingredients}
    \begin{itemize}
      \item A Runtime System in \js
      \item A compiler that translates \haskell in \js
      \item Executable code
    \end{itemize}
  \end{block}
\end{frame}

\begin{frame}{The RTS}
  The RTS consists of three fundamental blocks
  
  \begin{enumerate}
    \item Function Application   (|_A_|)
    \item Function nodes (|_F_|)
    \item Evaluation     (|_e_|)
  \end{enumerate}
\end{frame}

\begin{frame}{Creating the executable code, the compiler pipeline}
  \begin{enumerate}
    \item Parse the \haskell code
    \pause
    \item Transform to Essential Haskell
    \pause 
    \item Transform to Core
    \item Iterate over Core
    \pause
    \item Translate to \js \small{Fairly literally}
  \end{enumerate}
\end{frame}

\begin{frame}{Haskell}
\begin{spec}
main = do let  x =  40
               y =  2
          print $ x + y  
\end{spec}
\end{frame}

\begin{frame}{Essential Haskell}
\begin{spec}
let example.main
      = let y
              = (UHC.Base.fromInteger 2)
         in
        let x
              = (UHC.Base.fromInteger 40)
         in
        (UHC.Base.$ UHC.OldIO.print (UHC.Base.+ x y))
 in
let main
      = (UHC.Run.ehcRunMain example.main)
    main :: UHC.Base.IO ()
 in
main  
\end{spec}
\end{frame}

\begin{frame}{Core}
\begin{spec}
let
  { $example$.main
      {BINDPLAIN,VAL}
      = 
let
  { $_
      {BINDPLAIN,VAL}
      = ($example$.y_$@1UNQ_$@7)
          ($UHC$.Base$.Num_$@1DCT_$@73_134_0)} in
let
  { $__$@1_$@2
      {BINDPLAIN,VAL}
      = ($example$.x_$@1UNQ_$@8)
          ($UHC$.Base$.Num_$@1DCT_$@73_134_0)} in
\end{spec}
\end{frame}

\begin{frame}{Core - cont.}
\begin{spec}
let
  { $__$@1_$@3
      {BINDPLAIN,VAL}
      = ($UHC$.Base$.$+)
          ($UHC$.Base$.Num_$@1DCT_$@73_134_0)
          ($__$@1_$@2)
          ($_)} in
let
  { $__$@1_$@4
      {BINDPLAIN,VAL}
      = ($UHC$.OldIO$.print)
          ($UHC$.Base$.Show_$@1DCT_$@73_157_0)} in
(($UHC$.Base$.$$)
   ($__$@1_$@4)
   (($__$@1_$@3 :: v_3_72_2)) :: UHC.Base.IO ())}  
\end{spec}
\end{frame}

\begin{frame}[fragile]{Translate to \js}
\begin{minted}{javascript}
$example.$main=
 new _A_(new _F_("example.main",function()
  {var $__=
    new _A_($example.$yUNQ7,[$UHC.$Base.$NumDct]);
   var $__2=
    new _A_($example.$xUNQ8,[$UHC.$Base.$NumDct]);
   var $__3=
    new _A_($UHC.$Base.$_2b,[$UHC.$Base.$NumDct
                            ,$__2
                            ,$__]);
   var $__4=
    new _A_($UHC.$OldIO.$print
           ,[$UHC.$Base.$Show__DCT73__157__0]);
   return new _A_($UHC.$Base.$_24,[$__4,$__3]);})
                 ,[]);  
\end{minted}  
\end{frame}

\begin{frame}{Remarks}
  \begin{itemize}
    \item We can piggy-back on the existing GC
    \item Though also limited by what the \js engine is allowed to do.
  \end{itemize}
\end{frame}

\section{The FFI}

\begin{frame}{Static Import}
  \begin{itemize}
    \item Importing a \js function into the \haskell world
  \end{itemize}
\begin{spec}
foreign import js "plus"
  plus :: Int -> Int -> Int
\end{spec}
\end{frame}

\begin{frame}[fragile]{Static Export}
  \begin{itemize}
    \item Exporting a \haskell defined function and wrap it in the \js world. 
  \end{itemize}

\begin{code}
plus :: Int -> Int -> Int
plus = (+)
  
foreign export js "plus" plus :: Int -> Int -> Int
\end{code}

Generates:

\begin{minted}{javascript}
function plus (x, y) {
  return _e_ (new _A_(haskPlus, [x , y]));
}  
\end{minted}
\end{frame}

\begin{frame}{Dynamic import}
  \begin{itemize}
    \item Dynamically wrapping a \js function for use inside \haskell.
  \end{itemize}
  
\begin{spec}
foreign import convention "dynamic"
  dyn :: (FunPtr a) -> a  
\end{spec}
  
\begin{spec}
foreign import js "dynamic"
  dynPlus  :: JSFunPtr  (  Int -> Int -> Int )
           ->              Int -> Int -> Int
\end{spec}
\end{frame}

\begin{frame}{Dynamic export}
  \begin{itemize}
    \item And the other way around
  \end{itemize}
  
\begin{spec}
foreign import convention "wrapper"
  mkWrapper :: a -> IO (FunPtr a)
\end{spec}
  
\begin{spec}
foreign import js "wrapper"
  wrap  ::               (Int -> Int -> Int)
        -> IO (JSFunPtr  (Int -> Int -> Int))
\end{spec}    

\end{frame}

\begin{frame}{Current issues}
  \begin{itemize}
    \item Working with Strings provides a big overhead
    \item WPL causes exports to disappear
    \item The RTS is not that fast
  \end{itemize}
\end{frame}

\begin{frame}{Benchmarks}
  \begin{tabular}{||l || c  c || c c c ||}
    \hline
    |fib(n)|& JS        & GC       & HS     & GC        & eval \\
    \hline
    \multicolumn{6}{||c||}{Chrome}\\
    \hline                        
    100*$n=20$  & 13   ms     & (n/a)\footnotemark[1]   & 9014 ms  & 3090 ms      & 12650 ms  \\
    100*$n=30$  & 1600 ms     & (n/a)\footnotemark[1]   & \multicolumn{3}{c||}{Still running}\\
    \hline
    \multicolumn{6}{||c||}{Firefox}\\
    \hline
    100*$n=20$  & 816ms     & (n/a)                   & \multicolumn{3}{c||}{Did not run}\\
    100*$n=30$  & \multicolumn{5}{c||}{Did not finish}\\
    \hline
                & \multicolumn{2}{c||}{GHC 7} & \multicolumn{3}{c||}{GHC 7 Strict}\\
    \hline
    100*$n=20$  & \multicolumn{2}{c}{60 ms}   & \multicolumn{3}{||c||}{3 ms}\\
    100*$n=30$  & \multicolumn{2}{c}{7001 ms} & \multicolumn{3}{||c||}{20 ms}\\
    \hline
                & \multicolumn{5}{c||}{UHC 101 (non-strict)}\\
    \hline
    100*$n=20$  & \multicolumn{5}{c||}{2133 ms} \\
    100*$n=30$  & \multicolumn{5}{c||}{259870 ms} \\
    \hline
  \end{tabular}
  
  \footnotetext[1]{Did not show up in the trace}
\end{frame}



\section{The UHC-JS Library}
\begin{frame}{The UHC-JS Library}
  The UHC JavaScript library contains the following bindings:
  
  \begin{itemize}
    \item HTML5
    \item ECMA Standard
    \item Backbone
    \item JQuery (UI)
    \item JSON
  \end{itemize}
  
  This is an ongoing process.
\end{frame}

\begin{frame}[fragile]{Example 1}
\begin{minted}{html}
 <input type="button" id="foo" value="Click me!"/>
\end{minted}

\begin{spec}
main = do 
  button <- jQuery "input#foo"
  let eventHandler _ _ = do
    alert "Hello world!"
    return True
  bind button Click eventHandler
\end{spec}

\end{frame}

\begin{frame}[fragile]{Example 2}
\begin{minted}{html}
 <input type="number" id="l" value="40"/>
 <input type="number" id="r" value="2"/>
 <input type="button" id="foo" value="+"/>
\end{minted}

\begin{code}
main = do 
  button <- jQuery "input#foo"
  let eventHandler _  = do 
      l  <- fmap read (jQuery "#l" >>= valString)
      r  <- fmap read (jQuery "#r" >>= valString)
      alert (show (l + r))
      return True
  bind button Click eventHandler
\end{code}

\end{frame}

\section{The JCU app}

\begin{frame}{A Real Life Example}
  \begin{block}{JCU App}
    The JCU application offers a way to try and learn how \pl works to students
    of Junior College Utrecht.
    
    \begin{itemize}
      \item The server is already \haskell
      \item Client side done in \js but with \brunch.
    \end{itemize}
  \end{block}
\end{frame}

\begin{frame}{A Real Life Example - cont.}
  \begin{block}{And now}
    \begin{itemize}
      \item The client side is written in \haskell
      \item Around 400 lines of \haskell
      \item and utilizes both \verb+uu-tc+ and \verb+NanoProlog+.
    \end{itemize}
  \end{block}
\end{frame}

\subsection{Encountered issues}
\begin{frame}{The wandering |this|}
  \begin{itemize}
    \item \jq uses the |this| parameter to pass along objects the event handler
          was attached to.
    \item Causes a problem in \jq event handlers
    \item The scope of the keyword |this| depends on where the function is
          \emph{executed} and not where it is \emph{defined}
  \end{itemize}
\end{frame}

\begin{frame}[fragile]{The wandering |this| - cont.}
  
  This is fixable by adding the |this| argument as a parameter to the event
  handler.

\begin{minted}{javascript}
function wrapThis(cps) {
  return function() {
    var args = 
      Array.prototype.slice.call(arguments);
    args.unshift(this);
    return cps.apply(this, args);
  } 
}  
\end{minted}  
\end{frame}

\begin{frame}[fragile]{The wandering |this| - cont.}

  This is used in the following manner:

\begin{spec}
mkJUIThisEventHandler  ::  UIThisEventHandler 
                       ->  IO JUIThisEventHandler  

foreign import js "wrapThis(%1)"
  wrappedJQueryUIEvent  ::  JUIThisEventHandler 
                        ->  IO JUIEventHandler  
\end{spec}

\begin{spec}
f = do  
  ..
  eH :: UIThisEventHandler
  eH' <-  mkJUIThisEventHandler eH 
          >>= wrappedJQueryUIEvent
  ..
\end{spec}

\end{frame}

\begin{frame}
  Demo
\end{frame}

\begin{frame}
  Yes! It is possible to create web applications with \haskell!
  
  \begin{multicols}{2}
    \begin{itemize}
      \item 400 lines of \brunch views
      \item Global state containing the Proof Tree
    \end{itemize}
    
    \begin{itemize}
      \item 400 lines of \haskell
      \item The Proof Tree is passed along using partial application
    \end{itemize}
  \end{multicols}
  
  \begin{itemize}
    \item The code is pretty ugly, a lot of |IO| stuff.
    \item Small application directly using \jq bindings
  \end{itemize}
\end{frame}

\begin{frame}
  \begin{figure}
    \includegraphics[width=\textwidth]{benchmark/TheRoadAhead.jpg}
    \caption{There is still work to done!}
    \label{fig:theroadahead}
  \end{figure}
\end{frame}

\section{Future work}
\begin{frame}
  \begin{block}{Typed channels}
    It would be nice to have typed channels. So you specify the parameters for
    an action in the \haskell web server, and use the type of the call to be
    sure you don't make any errors there.
  \end{block}
\end{frame}

\begin{frame}
  \begin{block}{Threading}
    Make threading available in the \haskell RTS. Possibly using WebWorkers.
  \end{block}
\end{frame}

\begin{frame}
  \begin{block}{Abstract API for GUIs}
    Provide a functional, or reactive, framework to create GUIs. Think of
    something like WxHaskell or \verb+reactive-banana+. Work in this direction
    is being done by Ruben de Gooijer.
  \end{block}
\end{frame}

\begin{frame}{And a lot more}
  \begin{itemize}
    \item Importing \js files
    \item General work on the \uhc
    \item \dots
  \end{itemize}
\end{frame}

\section{Information}

\begin{frame}[fragile]{Join us!}

\begin{itemize}
  \item Install UHC: \\
        \url{http://uu-computerscience.github.com/uhc-js/}
  \item For the JCU app look at this page:\\
        \url{http://alessandrovermeulen.me/2012/01/26/getting-rid-of-javascript-with-haskell/}
  \item We are moving to GitHub:
        \url{https://github.com/organizations/UU-ComputerScience}
        Please provide us with your GitHub username! (Leave an issue or message
        us.)
\end{itemize}

\end{frame}

\end{document}