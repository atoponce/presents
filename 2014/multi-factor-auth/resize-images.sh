#!/bin/sh

sed -i 's/\(includegraphics\)/\1[width=\\textwidth]/g' multi-factor-auth.latex
