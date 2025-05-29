FROM nvidia/cuda:12.8.0-base-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all
ENV XDG_RUNTIME_DIR=/tmp/runtime
ENV DISPLAY=:0
ENV NVIDIA_DRIVER_CAPABILITIES=compute,video,utility,graphics,display
RUN mkdir -p /tmp/runtime

# Basic tools and FFmpeg build deps
RUN apt-get update && apt-get install -y --no-install-recommends \
  build-essential git yasm cmake pkg-config nasm \
  wget curl unzip ca-certificates \
  libnuma-dev libfdk-aac-dev libvpx-dev libx264-dev libx265-dev \
  libass-dev libfreetype6-dev libfontconfig1-dev \
  libxcb1-dev libxcb-shm0-dev libxcb-xfixes0-dev \
  nvidia-cuda-toolkit \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install nv-codec-headers (required for NVENC support)
RUN git clone https://github.com/FFmpeg/nv-codec-headers.git && \
  cd nv-codec-headers && make && make install && cd .. && rm -rf nv-codec-headers

# Build FFmpeg from source with NVENC support
RUN git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git && \
  cd FFmpeg && \
  ./configure \
    --enable-gpl \
    --enable-nonfree \
    --enable-cuda \
    --enable-cuvid \
    --enable-nvenc \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libvpx \
    --enable-libfdk-aac \
    --enable-libass \
    --enable-libfreetype \
    --enable-libfontconfig \
    --enable-libxcb \
    --enable-libxcb-shm \
    --enable-libxcb-xfixes \
    --extra-cflags=-I/usr/local/cuda/include \
    --extra-ldflags="-L/usr/local/cuda/lib64 -L/usr/lib/x86_64-linux-gnu" \
    && make -j$(nproc) && make install && cd .. && rm -rf FFmpeg

COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
