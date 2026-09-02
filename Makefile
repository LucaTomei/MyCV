# Build both CVs from the repository root.
#   make          -> PDFs (EN, IT, EN without photo) and Word versions under build/
#   make check    -> run the same parser checks used in CI
#   make dist     -> copy the PDFs to dist/ with their public names
#   make clean

LATEXMK ?= latexmk
FLAGS    = -pdf -interaction=nonstopmode -halt-on-error -file-line-error

.PHONY: all en it nophoto docx check dist clean

all: en it nophoto docx

en: build/en/main.pdf
it: build/it/main.pdf

build/en/main.pdf: CV-EN/main.tex common/preamble.tex common/foto.jpg common/firma.png
	$(LATEXMK) $(FLAGS) -outdir=build/en CV-EN/main.tex

build/it/main.pdf: CV-IT/main.tex common/preamble.tex common/foto.jpg common/firma.png
	$(LATEXMK) $(FLAGS) -outdir=build/it CV-IT/main.tex

nophoto: build/en-nophoto/nophoto.pdf
build/en-nophoto/nophoto.pdf: CV-EN/nophoto.tex CV-EN/main.tex common/preamble.tex common/firma.png
	$(LATEXMK) $(FLAGS) -outdir=build/en-nophoto CV-EN/nophoto.tex

docx: build/Luca_Tomei_CV_EN.docx build/Luca_Tomei_CV_IT.docx
build/Luca_Tomei_CV_%.docx: CV-%/main.tex scripts/build-docx.py
	scripts/build-docx.py $< $@

check: all
	scripts/check-cv.sh build/en/main.pdf en
	scripts/check-cv.sh build/it/main.pdf it
	scripts/check-cv.sh build/en-nophoto/nophoto.pdf en

dist: all
	mkdir -p dist
	cp build/en/main.pdf dist/Luca_Tomei_CV_EN.pdf
	cp build/it/main.pdf dist/Luca_Tomei_CV_IT.pdf
	cp build/en-nophoto/nophoto.pdf dist/Luca_Tomei_CV_EN_nophoto.pdf
	cp build/*.docx dist/

clean:
	rm -rf build
