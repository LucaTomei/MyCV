# Build both CVs from the repository root.
#   make          -> build/en/main.pdf, build/it/main.pdf
#   make check    -> run the same parser checks used in CI
#   make dist     -> copy the PDFs to dist/ with their public names
#   make clean

LATEXMK ?= latexmk
FLAGS    = -pdf -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all en it check dist clean

all: en it

en: build/en/main.pdf
it: build/it/main.pdf

build/en/main.pdf: CV-EN/main.tex common/preamble.tex common/foto.jpg common/firma.png
	$(LATEXMK) $(FLAGS) -outdir=build/en CV-EN/main.tex

build/it/main.pdf: CV-IT/main.tex common/preamble.tex common/foto.jpg common/firma.png
	$(LATEXMK) $(FLAGS) -outdir=build/it CV-IT/main.tex

check: all
	scripts/check-cv.sh build/en/main.pdf en
	scripts/check-cv.sh build/it/main.pdf it

dist: all
	mkdir -p dist
	cp build/en/main.pdf dist/Luca_Tomei_CV_EN.pdf
	cp build/it/main.pdf dist/Luca_Tomei_CV_IT.pdf

clean:
	rm -rf build
