# Makefile for LaTeX files

# Based on http://www.acoustics.hut.fi/u/mairas/UltimateLatexMakefile/Makefile

# Original Makefile from http://www.math.psu.edu/elkin/math/497a/Makefile

# Copyright (c) 2005,2006 (in order of appearance):
#	Matti Airas <Matti.Airas@hut.fi>
# 	Rainer Jung
#	Antoine Chambert-Loir
#	Timo Kiravuo

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions: 

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software. 

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 


# define commands
LATEX	= pdflatex -interaction nonstopmode
BIBER	= biber


# define regular expressions (to check for necessary re-runs of latex)
RERUN = "(There were undefined references|Rerun to get (cross-references|the bars) right)"
RERUNBIB = "No file.*\.bbl|Citation.*undefined"

# Get the main latex documents (store them in SOURCES) as source files
SOURCES	:= $(shell egrep -l '^[^%]*\\begin\{document\}' *.tex)

# Define the corresponding PDF documents as targets
TARGETS	= $(SOURCES:%.tex=%.pdf)


define run-pdflatex
	# run latex
	$(LATEX) $<
	# run biber if necessary
	egrep -c $(RERUNBIB) $(<:%.tex=%.log) > /dev/null && ($(BIBER) $(<:%.tex=%);$(LATEX) $<) ; true
	# re-run latex if necessary 
	egrep $(RERUN) $(<:%.tex=%.log) && ($(LATEX) $<) >/dev/null; true
	egrep $(RERUN) $(<:%.tex=%.log) && ($(LATEX) $<) >/dev/null; true
	# Display relevant warnings
	egrep -i "(Reference|Citation).*undefined" $(<:%.tex=%.log) ; true
endef

define get_dependencies
	deps=`perl -ne '($$_)=/^[^%]*\\\(?:include|input)\{(.*?)\}/;@_=split /,/;foreach $$t (@_) {print "$$t.tex "}' $<`
endef

define getbibs
	bibs=`perl -ne '($$_)=/^[^%]*\\\bibliography\{(.*?)\}/;@_=split /,/;foreach $$b (@_) {print "$$b.bib "}' $< $$deps`
endef


all 	: $(TARGETS)

clean	:
	  -rm -f $(TARGETS) $(TARGETS:%.pdf=%.aux) $(TARGETS:%.pdf=%.bbl) $(TARGETS:%.pdf=%.blg) $(TARGETS:%.pdf=%.bcf) $(TARGETS:%.pdf=%.run.xml) $(TARGETS:%.pdf=%.log) $(TARGETS:%.pdf=%.out) $(TARGETS:%.pdf=%.idx) $(TARGETS:%.pdf=%.ilg) $(TARGETS:%.pdf=%.ind) $(TARGETS:%.pdf=%.toc) $(TARGETS:%.pdf=%.d)

veryclean	: clean
	  -rm -f *.log *.aux *.dvi *.bbl *.blg *.ilg *.toc *.lof *.lot *.idx *.ind *.ps  *~ *.backup *.d *.run.xml *.bcf *.pdf

# This is a rule to generate a file of prerequisites for a given .tex file
%.d	: %.tex
	$(get_dependencies) ; echo $$deps ; \
	$(getbibs) ; echo $$bibs ; \
	echo "$*.pdf $@ : $< $$deps" > $@ 

include $(SOURCES:%.tex=%.d)

$(TARGETS) : %.pdf : %.tex
	@$(run-pdflatex)

