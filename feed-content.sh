#!/usr/bin/env sh

CONTENT_PATH=$1
SERVER_ADDR=$2


ffmpeg -i "$CONTENT_PATH" \
    -c:v libx264 \
    -c:a aac \
    -f flv \
    "rtmp://$SERVER_ADDR/annietv/content"
