COMPILER = ${UHC} --import-path=${UHC_JSCRIPT} --import-path=${UHC_NANOPROLOG} --import-path=${UHC_UU_TC} -tjs -O,2
COMPILERD = /Users/alessandro/Documents/Uni/xp/ehc/install/99/bin/ehc --import-path=${UHC_JSCRIPT} --import-path=${UHC_NANOPROLOG} --import-path=${UHC_UU_TC} -tjs -O,2 --dump-core-stages=1 # --no-recomp --no-hi-check --dump-core-stages=1

all: presentation

build: example
	${COMPILER} presentation.lhs
	${COMPILER} benchmark.hs
	
example: demo/example.hs
	${COMPILERD}--pretty=eh demo/example.hs
		
presentation: presentation.lhs presentation.fmt
	lhs2tex-hl -o presentation.fmt presentation.lhs
	lhs2tex -o presentation.tex presentation.lhs
	pdflatex --shell-escape presentation.tex	

	
clean:
	rm *.aux *.bbl *.log *.out *.blg *.ptb presentation.tex presentation.pdf

# publish: presentation
#   cp presentation.pdf ~/sources/octopress/source/downloads/presentation-on-getting-rid-of-js.pdf

.PHONY: clean