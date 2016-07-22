#!/bin/bash

command -v convert >/dev/null 2>&1 || { echo "This script requires 'ImageMagick'. Aborting." >&2; exit 1; }
command -v bc >/dev/null 2>&1 || { echo "This script requires 'bc'. Aborting." >&2; exit 1; }

bold=$(tput bold)
normal=$(tput sgr0)

imgPath="$1"
definedThreshold="$2"

for file in $imgPath/*.jpg; do

    convert $file -define convolve:scale=-1\! \
            -morphology Convolve Laplacian:0 -clamp $imgPath/edge.gif

    read width height < <(identify -format '%w %h' $imgPath/edge.gif)
    totalPixels=$((width * height))
    acceptableThreshold=$(echo "scale=0; ($definedThreshold * $totalPixels)/1" | bc)

    read white black < <(convert $imgPath/edge.gif -format "%[fx:mean*w*h] %[fx:(1-mean)*w*h]" info:)
    white=$(echo "scale=0; $white/1" | bc)

    percentage=$(echo "scale=4; ($white / $totalPixels)*100" | bc)

    echo "$file edge -- $white/$totalPixels ($percentage%), Threshold: $acceptableThreshold"

    if (("$white" < "$acceptableThreshold")) ;
        then
            echo "${bold}removing $file -- too blurry${normal}"
            mv $file $imgPath/remove/
        fi
done

mv $imgPath/*.gif $imgPath/remove/
