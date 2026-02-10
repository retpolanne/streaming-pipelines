#!/usr/bin/env sh

CONTENT_PATH=$1
SERVER_ADDR=$2


ffmpeg -re -i "$CONTENT_PATH" \
    -profile:v high -level 4.0 \
    -vf "subtitles=$CONTENT_PATH" \
    -pix_fmt yuv420p \
    -preset ultrafast -tune zerolatency \
    -flvflags no_duration_filesize \
    -c:v libx264 \
    -c:a aac \
    -f flv \
    "rtmp://$SERVER_ADDR/annietv/content"
