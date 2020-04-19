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
    vim \
    ffmpeg \
    libsm6 \
    libxext6 \
    libxrender-dev \
    wget

RUN pip install --upgrade pip

RUN pip install \
    cython \
    opencv-python \
    pillow \
    contextlib2 \
    numpy \
    scipy \
    h5py \
    scikit-image \
    lxml \
    matplotlib \
    jupyter \
    tensorflow==1.15 \
    keras

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

#get darkflow
RUN cd "/" && \
    git clone https://github.com/thtrieu/darkflow.git 

#run setup
RUN cd "/darkflow" && \
    python setup.py build_ext --inplace && \
    pip install . && \
    cd "/"  && \
    rm -rf "/darkflow"

WORKDIR /scripts

# #set up directory for files
COPY ./scripts /scripts/

CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--allow-root"]

# ~ docker build -t jamescrosbie/object_detection:latest .
