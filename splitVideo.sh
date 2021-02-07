#!/bin/bash

ffmpeg -i default.mp4 -ss 00:01:34 -t 00:01:40 -async 1 -c copy 17.mp4 
