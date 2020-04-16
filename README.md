
# Object detection
A docker image including tensorflow, opencv and darkflow (a tensorflow version of darknet).

## Tensorflow 
Included in the image is the TensorFlow object detection routine.

## Darkflow
Darknet is an open source neural network framework written in C and CUDA made by Joseph Redmon (https://pjreddie.com/darknet/). It is used to run an object detection network called YOLO (you only look once, https://pjreddie.com/darknet/yolo/).
Darkflow is a Tensorflow version of Darknet, made by Th. Thrieu (https://github.com/thtrieu/darkflow).

This image uses tensorflow with darkflow, and provide a demo notebook to test tiny-yolo classification.

## Running the image
The image uses a volume mapping from the local samples directory to the image.  So images and video can be place here on the local machine, and will be avialble within the docker container.  
To run the image: `docker run jamescrosbie/object_detection` or `docker-compose up`.   Copy past the url displayed in your console to your brower to start the ipython notebook and enjoy !

Design the net

Skip this if you are working with one of the original configurations since they are already there. Otherwise, see the following example:

...

[convolutional]
batch_normalize = 1
size = 3
stride = 1
pad = 1
activation = leaky

[maxpool]

[connected]
output = 4096
activation = linear

...

Flowing the graph using flow

# Have a look at its options
flow --h

First, let's take a closer look at one of a very useful option --load

# 1. Load yolo-tiny.weights
flow --model cfg/yolo-tiny.cfg --load bin/yolo-tiny.weights

# 2. To completely initialize a model, leave the --load option
flow --model cfg/yolo-new.cfg

# 3. It is useful to reuse the first identical layers of tiny for `yolo-new`
flow --model cfg/yolo-new.cfg --load bin/yolo-tiny.weights
# this will print out which layers are reused, which are initialized

All input images from default folder sample_img/ are flowed through the net and predictions are put in sample_img/out/. We can always specify more parameters for such forward passes, such as detection threshold, batch size, images folder, etc.

# Forward all images in sample_img/ using tiny yolo and 100% GPU usage
flow --imgdir sample_img/ --model cfg/yolo-tiny.cfg --load bin/yolo-tiny.weights --gpu 1.0

json output can be generated with descriptions of the pixel location of each bounding box and the pixel location. Each prediction is stored in the sample_img/out folder by default. An example json array is shown below.

# Forward all images in sample_img/ using tiny yolo and JSON output.
flow --imgdir sample_img/ --model cfg/yolo-tiny.cfg --load bin/yolo-tiny.weights --json

JSON output:

[{"label":"person", "confidence": 0.56, "topleft": {"x": 184, "y": 101}, "bottomright": {"x": 274, "y": 382}},
{"label": "dog", "confidence": 0.32, "topleft": {"x": 71, "y": 263}, "bottomright": {"x": 193, "y": 353}},
{"label": "horse", "confidence": 0.76, "topleft": {"x": 412, "y": 109}, "bottomright": {"x": 592,"y": 337}}]

    label: self explanatory
    confidence: somewhere between 0 and 1 (how confident yolo is about that detection)
    topleft: pixel coordinate of top left corner of box.
    bottomright: pixel coordinate of bottom right corner of box.

Training new model

Training is simple as you only have to add option --train. Training set and annotation will be parsed if this is the first time a new configuration is trained. To point to training set and annotations, use option --dataset and --annotation. A few examples:

# Initialize yolo-new from yolo-tiny, then train the net on 100% GPU:
flow --model cfg/yolo-new.cfg --load bin/yolo-tiny.weights --train --gpu 1.0

# Completely initialize yolo-new and train it with ADAM optimizer
flow --model cfg/yolo-new.cfg --train --trainer adam

During training, the script will occasionally save intermediate results into Tensorflow checkpoints, stored in ckpt/. To resume to any checkpoint before performing training/testing, use --load [checkpoint_num] option, if checkpoint_num < 0, darkflow will load the most recent save by parsing ckpt/checkpoint.

# Resume the most recent checkpoint for training
flow --train --model cfg/yolo-new.cfg --load -1

# Test with checkpoint at step 1500
flow --model cfg/yolo-new.cfg --load 1500

# Fine tuning yolo-tiny from the original one
flow --train --model cfg/yolo-tiny.cfg --load bin/yolo-tiny.weights

Example of training on Pascal VOC 2007:

# Download the Pascal VOC dataset:
curl -O https://pjreddie.com/media/files/VOCtest_06-Nov-2007.tar
tar xf VOCtest_06-Nov-2007.tar

# An example of the Pascal VOC annotation format:
vim VOCdevkit/VOC2007/Annotations/000001.xml

# Train the net on the Pascal dataset:
flow --model cfg/yolo-new.cfg --train --dataset "~/VOCdevkit/VOC2007/JPEGImages" --annotation "~/VOCdevkit/VOC2007/Annotations"

Training on your own dataset

The steps below assume we want to use tiny YOLO and our dataset has 3 classes

    Create a copy of the configuration file tiny-yolo-voc.cfg and rename it according to your preference tiny-yolo-voc-3c.cfg (It is crucial that you leave the original tiny-yolo-voc.cfg file unchanged, see below for explanation).

    In tiny-yolo-voc-3c.cfg, change classes in the [region] layer (the last layer) to the number of classes you are going to train for. In our case, classes are set to 3.

    ...

    [region]
    anchors = 1.08,1.19,  3.42,4.41,  6.63,11.38,  9.42,5.11,  16.62,10.52
    bias_match=1
    classes=3
    coords=4
    num=5
    softmax=1

    ...

    In tiny-yolo-voc-3c.cfg, change filters in the [convolutional] layer (the second to last layer) to num * (classes + 5). In our case, num is 5 and classes are 3 so 5 * (3 + 5) = 40 therefore filters are set to 40.

    ...

    [convolutional]
    size=1
    stride=1
    pad=1
    filters=40
    activation=linear

    [region]
    anchors = 1.08,1.19,  3.42,4.41,  6.63,11.38,  9.42,5.11,  16.62,10.52

    ...

    Change labels.txt to include the label(s) you want to train on (number of labels should be the same as the number of classes you set in tiny-yolo-voc-3c.cfg file). In our case, labels.txt will contain 3 labels.

    label1
    label2
    label3

    Reference the tiny-yolo-voc-3c.cfg model when you train.

    flow --model cfg/tiny-yolo-voc-3c.cfg --load bin/tiny-yolo-voc.weights --train --annotation train/Annotations --dataset train/Images

    Why should I leave the original tiny-yolo-voc.cfg file unchanged?

    When darkflow sees you are loading tiny-yolo-voc.weights it will look for tiny-yolo-voc.cfg in your cfg/ folder and compare that configuration file to the new one you have set with --model cfg/tiny-yolo-voc-3c.cfg. In this case, every layer will have the same exact number of weights except for the last two, so it will load the weights into all layers up to the last two because they now contain different number of weights.

Camera/video file demo

For a demo that entirely runs on the CPU:

flow --model cfg/yolo-new.cfg --load bin/yolo-new.weights --demo videofile.avi
