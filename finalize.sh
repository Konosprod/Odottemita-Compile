#!/bin/bash

url=$1

#Download the video
echo "Downloading"
count=0


./you-get/you-get "$url" > out.txt
count=`ls -1 *.mp4 2>/dev/null | wc -l`

while [ $count -eq 0 ] ; do
	sleep 30
	echo "Download failed, retrying"
	./you-get/you-get "$url" > out.txt
	count=`ls -1 *.mp4 2>/dev/null | wc -l`
done

#Get the title
title=$(cat out.txt | grep 'Title:' | sed 's/^......//')
echo -n $title > title.txt

#Add the url to the urls list
echo $url >> urls.txt

#Get current date in japan
mv *.mp4 "in.mp4"
date=$(date +%d.%m.%Y)

#Extract and draw title in the video
TARGET_HEIGHT=720
TARGET_WIDTH=1280
ffmpeg -i "in.mp4" -ss 0 -t 30 -vf "scale=min(iw*$TARGET_HEIGHT/ih\,$TARGET_WIDTH):min($TARGET_HEIGHT\,ih*$TARGET_WIDTH/iw),pad=$TARGET_WIDTH:$TARGET_HEIGHT:($TARGET_WIDTH-iw)/2:($TARGET_HEIGHT-ih)/2,fade=out:start_time=28:duration=2,drawtext=enable='between(t, 0, 7)':fontfile=/usr/share/fonts/truetype/fonts-japanese-mincho.ttf:textfile=./title.txt:fontcolor=white@1.0:fontsize=24:x=20:y=h-th-10:box=1:boxcolor=black@0.5:boxborderw=3" -af "afade=out:start_time=28:duration=2" -vcodec libx264 -crf 0 -acodec mp3 -ab 160k -ac 2 -ar 44100 -strict -2 -pix_fmt yuv420p -y -strict experimental out.mkv

#box=1:boxcolor=black@0.5:boxborderw=10
#drawbox=y=ih/PHI:color=black@0.4:width=iw:height=48:t=max

#Concatenate with the base video
echo "Concatenate"

if [ -e ../$date.mkv ]
then
	mkvmerge -o ./$date.mkv ../$date.mkv + out.mkv

	mv ./$date.mkv ../$date.mkv
else
	mv out.mkv ../$date.mkv
fi

echo "Cleaning"
rm -rf *.mp4
rm -rf *.mkv
