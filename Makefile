# Makefile of _Un Hedo Prince_

# By Marcos Cruz (programandala.net)

# Last modified 201811280126
# See change log at the end of the file

# ==============================================================
# Requirements

# - make
# - asciidoctor
# - asciidoctor-pdf
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
epub: \
	target/$(book).adoc.xml.pandoc.epub \
	target/$(book).adoc.epub

.PHONY: picdir
picdir:
	ln --force --symbolic --target-directory=target ../src/pic

.PHONY: html
html: picdir target/$(book).adoc.html target/$(book).adoc.plain.html target/$(book).adoc.xml.pandoc.html

.PHONY: odt
odt: target/$(book).adoc.xml.pandoc.odt

.PHONY: pdf
pdf: target/$(book).adoc.pdf

.PHONY: rtf
rtf: target/$(book).adoc.xml.pandoc.rtf

.PHONY: cover
cover: target/$(book)_cover.txt.png

.PHONY: clean
clean:
	rm -f \
		target/*.epub \
		target/*.html \
		target/*.odt \
		target/*.pdf \
		target/*.rtf \
		target/*.xml \
		target/*.png

# ==============================================================
# Convert to DocBook

target/$(book).adoc.xml: $(book).adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Convert to EPUB

# NB: Pandoc does not allow alternative templates. The default templates must
# be modified or redirected instead. They are the following:
# 
# /usr/share/pandoc-1.9.4.2/templates/epub-coverimage.html
# /usr/share/pandoc-1.9.4.2/templates/epub-page.html
# /usr/share/pandoc-1.9.4.2/templates/epub-titlepage.html

target/$(book).adoc.xml.pandoc.epub: target/$(book).adoc.xml target/$(book)_cover.txt.png
	pandoc \
		--from=docbook \
		--to=epub \
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

target/$(book).adoc.epub: $(book).adoc target/$(book)_cover.txt.png
	asciidoctor-epub3 \
		--destination-dir=target \
		$< ; \
    mv target/$(book).epub $@

# ==============================================================
# Convert to HTML

target/$(book).adoc.plain.html: $(book).adoc
	adoc \
		--attribute="stylesheet=none" \
		--quiet \
		--out-file=$@ \
		$<

target/$(book).adoc.html: $(book).adoc
	adoc --out-file=$@ $<

target/$(book).adoc.xml.pandoc.html: target/$(book).adoc.xml
	pandoc \
		--from=docbook \
		--to=html \
		--output=$@ \
		$<

# ==============================================================
# Convert to ODT

target/$(book).adoc.xml.pandoc.odt: target/$(book).adoc.xml
	pandoc \
		+RTS -K15000000 -RTS \
		--from=docbook \
		--to=odt \
		--output=$@ \
		$<

# ==============================================================
# Convert to PDF

target/$(book).adoc.pdf: $(book).adoc
	asciidoctor-pdf --out-file=$@ $<

# ==============================================================
# Convert to RTF

# XXX FIXME -- Both LibreOffice Writer and AbiWord don't read this RTF file
# properly. The RTF marks are exposed. It seems they don't recognize the format
# and take it as a plain file.

target/$(book).adoc.xml.pandoc.rtf: target/$(book).adoc.xml
	pandoc \
		--from=docbook \
		--to=rtf \
		--output=$@ \
		$<

# ==============================================================
# Change log

# 2018-11-25: Start. Copy from the project _Plu Glosa Nota_.
#
# 2018-11-27: Add asciidoctor-epub3, as an alternative to Pandoc. Replace the
# `$target` variable with a literal. Add a temporary cover, created by
# GraphicsMagick out of a text file.
