#!/usr/bin/env sh

SERVER_ADDR=$1

ffmpeg \
    -re \
    -f lavfi \
    -i "smptebars=rate=30:size=320x240" \
    -f lavfi \
    -i "sine=frequency=1000:sample_rate=48000" \
    -vf drawtext="text='AnnieTV Please Stand By':rate=30:x=(w-tw)/2:y=(h-lh)/2:fontsize=20:font='Andale Mono':fontcolor=white:box=1:boxcolor=black" \
    -f flv \
    -c:v h264 \
    -profile:v baseline \
    -pix_fmt yuv420p \
    -preset ultrafast \
    -tune zerolatency \
    -crf 28 \
    -g 60 \
    -c:a aac \
    "rtmp://$SERVER_ADDR/annietv/pattern"
