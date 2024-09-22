# Start from NVIDIA base image
FROM nvidia/cuda:12.2.2-devel-ubuntu22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
# All GPUs and all capabilities
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

ENV MIN_DRIVER_VERSION=525.60.11
ENV VK_DRIVER_FILES=/etc/vulkan/icd.d/nvidia_icd.json

RUN mkdir -p /etc/vulkan/icd.d/ /usr/share/glvnd/egl_vendor.d/ \
    && echo '{"file_format_version" : "1.0.0", "ICD": {"library_path": "libGLX_nvidia.so.0", "api_version" : "1.3"}}' > /etc/vulkan/icd.d/nvidia_icd.json \
    && echo '{"file_format_version" : "1.0.0", "ICD" : {"library_path" : "libEGL_nvidia.so.0"}}' > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    gcc \
    g++ \
    make \
    cmake \
    pkg-config \
    libglib2.0-dev \
    libgtk-3-dev \
    libpulse-dev \
    libasound2-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libx11-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxi-dev \
    libudev-dev \
    net-tools \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Download and extract OpenFrameworks
RUN wget https://github.com/openframeworks/openFrameworks/releases/download/0.11.2/of_v0.11.2_linux64gcc6_release.tar.gz \
    && tar xzf of_v0.11.2_linux64gcc6_release.tar.gz \
    && mv of_v0.11.2_linux64gcc6_release openframeworks \
    && rm of_v0.11.2_linux64gcc6_release.tar.gz

# Install OpenFrameworks dependencies
WORKDIR /app/openframeworks/scripts/linux/debian
RUN sed -i 's/apt-get install/apt-get install -y/g' ./install_dependencies.sh
RUN ./install_dependencies.sh

WORKDIR /app/openframeworks/scripts/linux
RUN ./compileOF.sh
RUN ./compilePG.sh

# Clone required addons
WORKDIR /app/openframeworks/addons
RUN git clone https://github.com/EmotiBit/ofxEmotiBit.git \
    && git clone https://github.com/bakercp/ofxNetworkUtils.git \
    && git clone https://github.com/produceconsumerobot/ofxOscilloscope.git \
    && git clone https://github.com/produceconsumerobot/ofxThreadedLogger.git \
    && git clone https://github.com/smukkejohan/ofxBiquadFilter.git \
    && git clone https://github.com/jeffcrouse/ofxJSON.git \
    && git clone https://github.com/EmotiBit/EmotiBit_XPlat_Utils.git \
    && git clone https://github.com/EmotiBit/ofxLSL.git \
    && git clone https://github.com/bakercp/ofxSerial.git \
    && git clone https://github.com/bakercp/ofxIO.git

# Checkout stable branches for specific addons
WORKDIR /app/openframeworks/addons/ofxNetworkUtils
RUN git checkout stable

WORKDIR /app/openframeworks/addons/ofxSerial
RUN git checkout stable

WORKDIR /app/openframeworks/addons/ofxIO
RUN git checkout stable

# Build EmotiBit Oscilloscope
WORKDIR /app/openframeworks/addons/ofxEmotiBit/EmotiBitOscilloscope
RUN make \
    && ln -s /app/openframeworks/addons/ofxEmotiBit/EmotiBitOscilloscope/bin/EmotiBitOscilloscope /usr/bin/EmotiBitOscilloscope

RUN apt-get update && apt-get install -y \
    iputils-ping \
    libgl1-mesa-glx libglu1-mesa libgl1-mesa-dri \
    mesa-utils

CMD ["/app/openframeworks/addons/ofxEmotiBit/EmotiBitOscilloscope/bin/EmotiBitOscilloscope"]
