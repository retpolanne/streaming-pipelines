#!/usr/bin/env sh

SERVER_ADDR=$1

GST_PLUGIN_PATH=$PWD gst-launch-1.0 \
    fallbacksrc uri=rtmp://$SERVER_ADDR/annietv/content \
    fallback-uri=rtmp://$SERVER_ADDR/annietv/pattern \
    immediate-fallback=true \
    timeout=5000000000 \
    restart-timeout=10000000000 \
    restart-on-eos=true \
    name=d \
    ! videoconvert \
    ! autovideosink \
    d. \
    ! audioconvert \
    ! autoaudiosink
