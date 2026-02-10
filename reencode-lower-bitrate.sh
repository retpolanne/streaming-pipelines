#!/usr/bin/env sh

CONTENT_PATH=$1
OUTPUT=$2

ffmpeg -i "$CONTENT_PATH" \
    -c:v libx264 \
    -crf 23 \
    $OUTPUT
