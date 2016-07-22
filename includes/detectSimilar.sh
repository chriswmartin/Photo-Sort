#!/bin/bash

command -v convert >/dev/null 2>&1 || { echo "This script requires 'ImageMagick'. Aborting." >&2; exit 1; }
command -v bc >/dev/null 2>&1 || { echo "This script requires 'bc'. Aborting." >&2; exit 1; }

bold=$(tput bold)
normal=$(tput sgr0)

imgPath="$1"
definedThreshold="$2"

cd "$imgPath"
for i in $(ls -R |grep .jpg$); do
	  for j in $(ls -R |grep .jpg$); do
        if [[ -f $i ]] && [[ -f $j ]] && [[ "$i" != "$j" ]] ;
        then
            convert $i $j -compose difference -composite \
			              -colorspace Gray $imgPath/difference.jpg

            read width height < <(identify -format '%w %h' $imgPath/difference.jpg)
            totalPixels=$((width * height))
            acceptableThreshold=$(echo "scale=0; ($definedThreshold * $totalPixels)/1" | bc)

            read white < <(convert $imgPath/difference.jpg -format "%[fx:mean*w*h]" info:)
            white=$(echo "scale=0; $white/1" | bc)

            difference=$(echo "scale=2; ($white / $totalPixels)*100" | bc)

            if (("$white" < "$acceptableThreshold")) ;
            then
                echo "${bold}removing $j -- too similar to $i${normal}"
                mv $j remove/
            fi
            echo "$i & $j - Difference: $difference%"
        fi
    done
done

mv $imgPath/difference.jpg $imgPath/remove/
cd -
