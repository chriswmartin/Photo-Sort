#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

expThresh=0.8
blurThresh=0.004
simThresh=0.2

usage() { echo "$0 usage:" && grep " .)\ #" $0; exit 0; }
[ $# -eq 0 ] && usage
while getopts ':p:e:b:s:h:' arg; do
    case $arg in
        p) #Absolute path to '.jpg' image directory
            imgPath=${OPTARG}
            ;;
        e) #Exposure threshold. Default is 0.8. Omit flag for default.
            expThresh=$OPTARG
            ;;
        b) #Blur threshold. Default is 0.004. Omit flag for default.
            blurThresh=$OPTARG
            ;;
        s) #Similarity threshold. Default is 0.2. Omit flag for default.
            simThresh=$OPTARG
            ;;
        h | *)
            usage
            exit 0
            ;;
    esac
done

echo "${bold}Starting...${normal}"
echo "${bold}Image Path: $imgPath${normal}"

originCount=$(ls -1 $imgPath | wc -l)

removeDir="$imgPath/remove/"
if [ ! -d "$removeDir" ]; then
    mkdir $removeDir
fi

echo "${bold}Detecting dark/bright images${normal}"
./includes/darkBrightDetect.sh "$imgPath" "$expThresh"

echo "${bold}Detecting blurry images${normal}"
./includes/detectBlur.sh "$imgPath" "$blurThresh"

echo "${bold}Detecting similar/duplicate images${normal}"
./includes/detectSimilar.sh "$imgPath" "$simThresh"

removeCount=$(ls -1 $removeDir | wc -l)

echo "${bold}Finished${normal}"
echo "${bold}Moved $removeCount out of $originCount images to $removeDir${normal}"

#rm -rf $removeDir/*
