#!/bin/bash

date=$(date +%d.%m.%Y)

youtube-upload --client-secrets=client_secrets.json -t "【踊ってみたCOMPILATION】$date【ニコニコ動画】" -d "$(cat urls.txt)" --privacy=unlisted ../$date.mkv 

rm -rf "urls.txt"
touch "urls.txt"
#rm -rf ../$date.mkv
