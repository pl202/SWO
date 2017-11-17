IOTC-2017-SC20-11.pdf: IOTC-2017-SC20-11.Rmd references.bib
	R -e "rmarkdown::render('IOTC-2017-SC20-11.Rmd', clean=FALSE)"

md: IOTC-2017-SC20-11.md
	/usr/bin/pandoc +RTS -K512m -RTS IOTC-2017-SC20-11.utf8.md --to latex --from markdown+autolink_bare_uris+ascii_identifiers+tex_math_single_backslash --output IOTC-2017-SC20-11.pdf --template /home/mosquia/R/x86_64-pc-linux-gnu-library/3.4/rmarkdown/rmd/latex/default-1.17.0.2.tex --number-sections --highlight-style tango --latex-engine pdflatex --variable graphics=yes --variable 'geometry:margin=1in' --bibliography references.bib --filter /usr/bin/pandoc-citeproc 
