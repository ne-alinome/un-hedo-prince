# Makefile of _Un Hedo Prince_

# This file is part of project
# _Un Hedo Prince_
# by Marcos Cruz (programandala.net)
# http://ne.alinome.net

# Last modified 201902231523
# See change log at the end of the file

# ==============================================================
# XXX TODO --

# - Create HTML versions without header and footer.

# ==============================================================
# Requirements

# - make
# - asciidoctor
# - asciidoctor-pdf
# - dbtoepub
# - pandoc
# - GraphicsMagick

# ==============================================================
# Config

VPATH=./src:./target

book=un_hedo_prince

# ==============================================================
# Interface

.PHONY: all
all: epub html odt pdf

.PHONY: docbook
docbook: target/$(book).adoc.xml

.PHONY: epub
epub: epubd epubp

.PHONY: epubd
epubd: target/$(book).adoc.xml.dbtoepub.epub

.PHONY: epubp
epubp: target/$(book).adoc.xml.pandoc.epub

.PHONY: html
html: \
	target/$(book).adoc.html \
	target/$(book).adoc.plain.html \
	target/$(book).adoc.xml.pandoc.html

.PHONY: odt
odt: target/$(book).adoc.xml.pandoc.odt

.PHONY: pdf
pdf: pdfa4 pdfletter

.PHONY: pdfa4
pdfa4: target/$(book).adoc.a4.pdf

.PHONY: pdfletter
pdfletter: target/$(book).adoc.letter.pdf

.PHONY: rtf
rtf: target/$(book).adoc.xml.pandoc.rtf

.PHONY: cover
cover: target/$(book)_cover.txt.png

.PHONY: clean
clean:
	rm -f target/*

# ==============================================================
# Convert Asciidoctor to DocBook

target/$(book).adoc.xml: $(book).adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert DocBook to EPUB

# ------------------------------------------------
# With dbtoepub

target/$(book).adoc.xml.dbtoepub.epub: \
	target/$(book).adoc.xml
	dbtoepub \
		--output $@ $<

# ------------------------------------------------
# With pandoc

target/$(book).adoc.xml.pandoc.epub: \
	target/$(book).adoc.xml \
	target/$(book)_cover.txt.png \
	src/pandoc_epub_template.txt \
	src/stylesheet.css
	pandoc \
		--from=docbook \
		--to=epub3 \
		--template=src/pandoc_epub_template.txt \
		--css=src/stylesheet.css \
		--epub-cover-image=target/$(book)_cover.txt.png \
		--output=$@ \
		$<

target/$(book)_cover.txt.png: src/$(book)_cover.txt
	gm convert \
		-page 900x1500 \
		-background white -fill black \
		-border 50 -bordercolor white \
		-pointsize 70 \
		-font Courier \
		text:$< \
		$@

# XXX OLD -- asciidoctor-epub3 is not used anymore:

target/$(book).adoc.epub: $(book).adoc target/$(book)_cover.txt.png
	asciidoctor-epub3 \
		--destination-dir=target \
		$< ; \
    mv target/$(book).epub $@

# ==============================================================
# Convert Asciidoctor to HTML

target/$(book).adoc.plain.html: $(book).adoc
	adoc \
		--attribute="stylesheet=none" \
		--quiet \
		--out-file=$@ \
		$<

target/$(book).adoc.html: $(book).adoc
	adoc --out-file=$@ $<

# ==============================================================
# Convert DocBook to HTML

target/$(book).adoc.xml.pandoc.html: \
	target/$(book).adoc.xml \
	src/pandoc_html_template.txt
	pandoc \
		--from=docbook \
		--to=html \
		--template=src/pandoc_html_template.txt \
		--standalone \
		--output=$@ \
		$<

# ==============================================================
# Convert DocBook to ODT

target/$(book).adoc.xml.pandoc.odt: \
	target/$(book).adoc.xml \
	src/pandoc_odt_template.txt
	pandoc \
		+RTS -K15000000 -RTS \
		--from=docbook \
		--to=odt \
		--template=src/pandoc_odt_template.txt \
		--output=$@ \
		$<

# ==============================================================
# Convert Asciidoctor to PDF

target/$(book).adoc.a4.pdf: $(book).adoc
	asciidoctor-pdf \
		--out-file=$@ $<

target/$(book).adoc.letter.pdf: $(book).adoc
	asciidoctor-pdf \
		--attribute pdf-page-size=letter \
		--out-file=$@ $<

# ==============================================================
# Convert DocBook to RTF

target/$(book).adoc.xml.pandoc.rtf: \
	target/$(book).adoc.xml \
	src/pandoc_rtf_template.txt
	pandoc \
		--from=docbook \
		--to=rtf \
		--template=src/pandoc_rtf_template.txt \
		--standalone \
		--output=$@ \
		$<

# ==============================================================
# Change log

# 2018-11-25: Start. Copy from the project _Plu Glosa Nota_.
#
# 2018-11-27: Add asciidoctor-epub3, as an alternative to Pandoc. Replace the
# `$target` variable with a literal. Add a temporary cover, created by
# GraphicsMagick out of a text file.
#
# 2018-11-29: Add a pandoc EPUB stylesheet. Don't use asciidoctor-epub3
# anymore; use only pandoc. Fix pandoc's RTF and HTML output. Remove old <pic>
# directory link, which was used by HTML.
#
# 2019-02-23: Update pandoc parameters to version 2.6 and add templates. Make
# also a letter-size PDF. Make an alterntive EPUB with dbtoepub.
