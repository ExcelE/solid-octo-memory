# People-Counter

This is an exploratory project for people/pedestrian detection using tensorflow's object detection API.

### Installing libraries:
You may need to install certain libraries to optimally run the implementation. I've provided the following in the `sources` directory:
1. OpenCV installation (build from source) `bash sources/buildOpenCV.sh`
1. Protobuf 3.6.0 (build from source) 
    * `bash sources/installProtobuf_p1.sh`
    * `reboot`
    * `bash sources/installProtobuf_p2.sh`
1. Installing TensorRT Library with Models API (Required for Object Detection API):
    * `bash sources/installTRT.sh`


### TRT Optimization:
I've built a TensorRT Optimized graph of the `ssd_mobilenet_v2_coco` in the `data/ssd_inception_v2_coco_trt.pb`.  
You can directly import this graph as you would on tensorflow with GFile. 
This was meant to be deployed on a Jetson platform.

