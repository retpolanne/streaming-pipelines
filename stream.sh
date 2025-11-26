#!/usr/bin/env sh

SERVER_ADDR=$1

gst-launch-1.0 \
    fallbacksrc uri=rtmp://$SERVER_ADDR/annietv/content \
    fallback-uri=rtmp://$SERVER_ADDR/annietv/pattern \
    name=d \
    ! videoconvert \
    ! autovideosink \
    d. \
    ! audioconvert \
    ! autoaudiosink
