
# Object detection
A docker image including tensorflow, opencv and darkflow (a tensorflow version of darknet).  

The purpose of this repo is to refamiliarise myself with docker and to put together some object detection methods in a docker container.  I've drawn from others -  
** [davvdg's docker image](https://hub.docker.com/r/davvdg/darkflow-docker)

TODO add webcam to docker and get image to work with video

## Running the image
The image uses a volume mapping from the local samples directory to the image.  So images and video can be place here on the local machine, and will be avialble within the docker container.  

To run the image: `docker run jamescrosbie/object_detection` or `docker-compose up` from the directory with the docker file in.   Note, if you run the docker file, you'll need to incorporate the volume mapping and the port mapping for jupyter - hence the docker-compose file.  Copy paste the url displayed in your console to your brower to start the ipython notebook and enjoy.  

## Tensorflow (v 1.15)
Included in the image is the TensorFlow object detection notebooks.  This includes the models for bounding box object detection  and Mask object detection with the [COCO dataset](http://cocodataset.org/#home) (Common Objects in COntext).  I've done this because I found the TensorFlow repo includes loads of great stuff but its a bit messy -  so I've tried to slim in down for my purposes.


## Darkflow
Darknet is an open source neural network framework written in C and CUDA made by Joseph Redmon (https://pjreddie.com/darknet/). It is used to run an object detection network called YOLO (You Only Look Once, https://pjreddie.com/darknet/yolo/).
Darkflow is a Tensorflow version of Darknet, made by Th. Thrieu (https://github.com/thtrieu/darkflow).

This image uses tensorflow with darkflow, and provide a demo notebook to test tiny-yolo classification.

