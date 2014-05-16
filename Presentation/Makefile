ASS=CellularAtomataPresentation
MDFILE=$(ASS).md
OUTFILE=$(ASS)

pdf:
	pandoc -t beamer $(MDFILE) -o $(OUTFILE).pdf
	zip $(OUTFILE).zip $(OUTFILE).pdf $(UI_DES).pdf


