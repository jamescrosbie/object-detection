# specify the base image
FROM python:3.6-stretch

# update os and install packages
RUN apt-get update && apt-get install -y \
    apt-utils \
    protobuf-compiler \
    python-pil \
    python-lxml \
    python-tk \
    python-pip \
    python-dev \
    git \
    wget

RUN pip install --upgrade pip

RUN pip install \
    cython \
    opencv-python \
    pillow \
    contextlib2 \
    numpy \
    lxml \
    matplotlib \
    jupyter \
    tensorflow==1.15

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

#get darkflow
RUN cd "/" && \
    git clone https://github.com/thtrieu/darkflow.git 

#replace loader.py file in build directory
COPY ./home/scripts/loader.py /darkflow/utils/loader.py

#run setup
RUN cd "/darkflow" && \
    python setup.py build_ext --inplace && \
    pip install . && \
    cd "/"  && \
    rm -rf "/darkflow"

WORKDIR /home

# #set up directory for files
RUN mkdir /data && \
    cd "/home" && \
    mkdir logs && \
    mkdir scripts && \
    mkdir samples && \
    cd "scripts" && \
    mkdir object_detection && \
    cd "object_detection" && \
    mkdir core && \
    mkdir utils && \
    mkdir protos && \
    mkdir data && \
    cd "/"

#YOLO object detection
COPY ./data/*.cfg /data/ 
COPY ./data/*.weights /data/

#script files
COPY ./home/scripts/*.ipynb /home/scripts/ 

#TensorFlow's object detection
COPY ./home/scripts/object_detection/core /home/scripts/object_detection/core/
COPY ./home/scripts/object_detection/utils /home/scripts/object_detection/utils/
COPY ./home/scripts/object_detection/protos /home/scripts/object_detection/protos/
COPY ./home/scripts/object_detection/data /home/scripts/object_detection/data/

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

# # # # ~ docker build -t jamescrosbie/object_detection:latest .