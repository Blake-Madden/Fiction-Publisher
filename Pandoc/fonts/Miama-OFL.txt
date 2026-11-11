DESCRIPTION:
The miama package provides LaTeX support for the Miama Nueva typeface. 
The package and the typeface are distributed on CTAN under the terms of 
the LaTeX Project Public License (LPPL) and the Open Font License (OFL),
respectively.

Copyright (c) 2016 - 2025 Linus Romer

Please write to 
linus dot romer at gmx dot ch
to submit bug reports, request new features, etc.

INSTALLATION:
The installation process will depend on your LaTeX distribution. Your
distribution will probably provide an installation package that can
easily be installed by a package manager.

The main steps for a manual installation will be similar to the 
following:

1. Run LaTeX on miama.ins:
    latex miama.ins
   This will produce several new files.
2. Determine your local texmf tree:
    kpsexpand '$TEXMFLOCAL'
   In the following, we assume that /usr/local/share/texmf is your 
   local texmf tree.
3. Copy the files into your local texmf tree:
    cp *.tfm /usr/local/share/texmf/fonts/tfm/public/miama/
    cp miama.afm /usr/local/share/texmf/fonts/afm/public/miama/
    cp miama.pfb /usr/local/share/texmf/fonts/type1/public/miama/
    cp miama.otf /usr/local/share/texmf/fonts/opentype/public/miama/
    cp *.fd /usr/local/share/texmf/tex/latex/miama/
    cp miama.sty /usr/local/share/texmf/tex/latex/miama/
    cp miama.map /usr/local/share/texmf/fonts/map/dvips/miama/
    cp *.enc /usr/local/share/texmf/fonts/enc/dvips/miama/
    cp miama.pdf /usr/local/share/texmf/doc/fonts/miama/
4. Add the line "Map miama.map" to your updmap.cfg and refresh
   the LaTeX database:
    mktexlsr
    updmap-sys --enable Map miama.map
    update-updmap
    updmap-sys

CONTENTS:
lgr-miama.enc
miama.afm
miama.dtx
miama.ins
miama-lgr.tfm
miama.map
miama-ot1.tfm
miama.otf
miama.pdf
miama.pfb
miama-qx.tfm
miama-t1.tfm
miama-t2a.tfm
miama-t2b.tfm
miama-t2c.tfm
miama-t5.tfm
miama-x2.tfm
ot1-miama.enc
qx-miama.enc
README
t1-miama.enc
t2a-miama.enc
t2b-miama.enc
t2c-miama.enc
t5-miama.enc
x2-miama.enc
