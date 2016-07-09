#!/bin/sh

sed -i 's/\(includegraphics\)/\1[width=\\textwidth]/g' password-math.latex
