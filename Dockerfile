FROM ubuntu:16.04

# Let the container know that there is no TTY
ENV DEBIAN_FRONTEND noninteractive

#RUN add-apt-repository ppa:ubuntu-toolchain-r/test
#RUN apt-get update
#RUN apt-get install gcc-4.9

# Install necessary packages for proper system state
RUN apt-get -y update && apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    libboost-all-dev \
    libbz2-dev \
    libstxxl-dev \
    libstxxl-doc \
    libstxxl1-bin \
    libtbb-dev \
    libxml2-dev \
    libzip-dev \
    lua5.1 \
    liblua5.1-0-dev \
    libluabind-dev \
    libluajit-5.1-dev \
    pkg-config


RUN mkdir -p /osrm-build \
 && mkdir -p /osrm-data

COPY car.lua /

WORKDIR /osrm-build

RUN curl --silent -L https://github.com/Project-OSRM/osrm-backend/archive/v5.5.0.tar.gz -o v5.5.0.tar.gz \
 && tar xzf v5.5.0.tar.gz \
 && mv osrm-backend-5.5.0 /osrm-src \
 && cmake /osrm-src \
 && make \
 && mv /car.lua profile.lua \
 && mv /osrm-src/profiles/lib/ lib \
 && echo "disk=/tmp/stxxl,250000,syscall" > .stxxl \
 && rm -rf /osrm-src

# Cleanup --------------------------------

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Publish --------------------------------

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000
