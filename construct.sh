#!/bin/bash

url=$1

#Download the video
echo "Downloading"
./you-get/you-get "$url"> out.txt

#Get the title
title=$(cat out.txt | grep 'Title:' | sed 's/^......//')
echo -n $title > title.txt

#Add the url to the urls list
echo $url >> urls.txt

#Get current date in japan
mv *.mp4 "in.mp4"
date=$(TZ=Asia/Tokyo date +%d-%m-%Y)

#Extract and draw title in the video
echo "Extract & stuff"
sync
./ffmpeg/ffmpeg -i "in.mp4" -ss 0 -t 30 -vf "drawtext=enable='between(t, 0, 7)':fontfile=/usr/share/fonts/truetype/fonts-japanese-mincho.ttf:textfile=./title.txt:fontcolor=white@1.0:fontsize=24:x=20:y=h-th-10:box=1:boxcolor=black@0.5:boxborderw=3,fade=out:start_time=28:duration=2" -af "afade=out:start_time=28:duration=2" -s hd720 -vcodec libx264 -crf 23 -acodec mp3 -ab 160k -ac 2 -ar 44100 -strict -2 -pix_fmt yuv420p -y -strict experimental out.mp4

#box=1:boxcolor=black@0.5:boxborderw=10
#drawbox=y=ih/PHI:color=black@0.4:width=iw:height=48:t=max

#Concatenate with the base video
echo "Concatenate"

if [ -e ../$date.mp4 ]
then
	MP4Box -force-cat -add ../$date.mp4#audio -cat out.mp4#audio a.mp4
	MP4Box -add ../$date.mp4#video -cat out.mp4#video v.mp4
	MP4Box -add a.mp4 -cat v.mp4 ./$date.mp4

	mv ./$date.mp4 ../$date.mp4
else
	mv out.mp4 ../$date.mp4
fi

rm -rf *.mp4