THIS := $(lastword $(MAKEFILE_LIST))

PDF_PREFIX=
PDF_NAME=$(PDF_PREFIX)ChineseCharactersWallchart.pdf

#AUTOMATIC OS DETECTION
OS=$(shell uname -s)
ifeq ($(OS),Darwin)
PDFVIEWER=open
else
ifeq ($(OS),Linux)
PDFVIEWER=evince
endif
endif

TEX_NAME = $(PDF_NAME:%.pdf=%.tex)
TEX_BUILD_FLAGS= -interaction=nonstopmode -file-line-error

COLOR_END = \033[0m
COLOR_WHITE = \033[1;37m
BGCOLOR_GREEN = \033[42m
BGCOLOR_RED = \033[41m

CC_CMD=xelatex

CLEAN_CMD=rm -f
CLEAN_CMD+= *.backup *.aux *.toc *.ind *.idx *.ilg *.blg *.log *.out *.bbl *.dvi
CLEAN_CMD+= *.nav *.pyg *.snm *.lof *.glg *.glo *.gls *.acn *.acr *.alg *.ist
CLEAN_CMD+= 2> /dev/null

.PHONY: update clean all view

update: $(PDF_NAME)
	@$(CLEAN_CMD)

clean:
	@printf "%-18s <$(PDF_NAME)>...\n" "Cleaning"
	@$(CLEAN_CMD)
	@rm -f $(PDF_NAME)

all: clean update

view: update
	@$(PDFVIEWER) $(PDF_NAME) > /dev/null 2>&1 &

%.pdf: %.tex $(wildcard *.tex) $(THIS)
	@$(CLEAN_CMD)
	@printf "%-18s <$@>...\n" "Building stage 1" ;\
	$(CC_CMD) $(TEX_BUILD_FLAGS) "$<" > $@.stdout 2> $@.stderr ;\
	OK=$$? ;\
	if [ $$OK -eq 0 ]; then\
		printf "%-18s <$@>...\n" "Building stage 2" ;\
		$(CC_CMD) $(TEX_BUILD_FLAGS) "$<" > $@.stdout 2> $@.stderr ;\
		OK=$$? ;\
	fi;\
	if [ $$OK -eq 0 ]; then\
		printf "%-18s <$@>...\n" "Building stage 3" ;\
		$(CC_CMD) $(TEX_BUILD_FLAGS) "$<" > $@.stdout 2> $@.stderr ;\
		OK=$$? ;\
	fi;\
	if [ $$OK -eq 0 ]; then\
		echo; \
		echo "$(BGCOLOR_GREEN)$(COLOR_WHITE)BUILD SUCCESSFUL$(COLOR_END)" ;\
	else\
		cat $@.stdout ;\
		rm -f $@ ;\
		echo; \
		echo "$(BGCOLOR_RED)$(COLOR_WHITE)BUILD FAILED$(COLOR_END)" ;\
	fi;\
	rm -f $@.stdout $@.stderr ;
	@$(CLEAN_CMD)

