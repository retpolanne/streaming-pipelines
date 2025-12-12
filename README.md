# streaming-pipelines

This is how I stream content from my computer to a raspberry and then to a VCR

A few years ago, I wanted to record Serial Experiments Lain on a VCR. But I wanted
to do it in a very interesting way by using an almost headless raspberry pi connected
through RCA to a VCR and then record it. 

Unfortunately, the blank tape I had was bad and not recording. Fortunately, 
an old tape I had was recordable with a faux tape seal. Good-bye, Toy Story tape. 
Hello, Lain tape. 

The original post was published [here](https://blog.retpolanne.com/gstreamer/2023/10/23/lain-vhs.html). 

### The RTSP server 

I'll use [mediamtx](https://github.com/bluenviron/mediamtx) as an RTSP server. 
I'm not using docker, just using the macOS binary on my laptop. FFMpeg will probably
publish content to mediamtx as needed and gstreamer on the raspberry will retrieve
it. 

It should look like this:

```
laptop ffmpeg mp4 playlist ----> laptop mediamtx rtsp <------ raspberrypi rtsp client (gstreamer)
```

I wanted to keep SMPTE color bars showing up as an idle feed on mediamtx so that 
we don't have to switch gstreamer. The thing is that I don't want clients to 
switch. 

### Color bars idle signal 

This [guide](https://gist.github.com/nickferrando/6d572b044a205a507201e2fc69423a3e)
may help me generate the color bars.

### Feeding Lain to MediaMTX

My Lain files are in .mkv, so I need to transcode it in my laptop with ffmpeg
while sending the content to the MediaMTX feed. Then, gstreamer will only deal with 
H264 or something. 

This [tutorial](https://ottverse.com/rtmp-streaming-using-ffmpeg-tutorial/) seems 
to have worked for now. However I keep getting this message while checking the Lain
feed using VLC. 

``` 
2025/11/26 17:45:14 WAR [RTMP] [conn 127.0.0.1:49992] reader is too slow, discarding 337 frames
2025/11/26 17:45:15 WAR [RTMP] [conn 127.0.0.1:49992] reader is too slow, discarding 340 frames
2025/11/26 17:45:16 WAR [RTMP] [conn 127.0.0.1:49992] reader is too slow, discarding 308 frames
2025/11/26 17:45:17 INF [RTMP] [conn 127.0.0.1:49992] closed: too many reordered frames (14)
```

There's a .yml file alongside the binary with some configs. Changing [this one](
https://github.com/bluenviron/mediamtx/issues/5093#issuecomment-3520832566) helped.

However I got another issue (https://github.com/bluenviron/mediamtx/issues/5226)
where VLC simply froze. 

Regardless, I believe I have an almost good feed for gstreamer. I just need to 
figure out how to do the seamless switch between color bars and content. 

Before hooking up my Raspberry, I believe I'll try to use gstreamer on mac to
verify if things look correct. 

``` sh
SERVER_ADDR=$1

gst-launch-1.0 \
    uridecodebin uri=rtmp://$SERVER_ADDR/annietv name=d\
    ! videoconvert \
    ! autovideosink \
    d. \
    ! audioconvert \
    ! autoaudiosink
```

With this bit of code, I'm able to at least test the test pattern on the Mac, but when I 
do the switch of the feed the pipeline pauses.

A reminder is that we probably need to keep the test pattern feed running forever, as it's 
a fallback.

A basic fallback is described [here](https://coaxion.net/blog/2020/07/automatic-retry-on-error-and-fallback-stream-handling-for-gstreamer-sources/)

``` sh
gst-launch-1.0 \
    fallbacksrc uri=rtmp://$SERVER_ADDR/annietv/content \
    fallback-uri=rtmp://$SERVER_ADDR/annietv/pattern \
    ! videoconvert \
    ! autovideosink
```

Claude helped me understand the timeouts to keep a test pattern feed running
when there's no feed to begin with.

The timeouts are in nanoseconds. 

``` sh
gst-launch-1.0 \
    fallbacksrc uri=rtmp://$SERVER_ADDR/annietv/content \
    fallback-uri=rtmp://$SERVER_ADDR/annietv/pattern \
    immediate-fallback=true \
    timeout=5000000000 \
    restart-timeout=10000000000 \
    name=d \
    ! videoconvert \
    ! autovideosink \
    d. \
    ! audioconvert \
    ! autoaudiosink
```

It seamlessly switches between feeds, but the content feed seems to bring down the whole pipeline...

Actually, mediamtx seems to fail. DTS is greater than PTS error. That's expected .


### On to the raspberry

I had to upgrade to debian trixie `lsb_release -cs`.

``` sh
sudo apt update && sudo apt install $(cat packages.txt)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
cargo cinstall -p gst-plugin-fallbacksrc --prefix=/usr
```

