# syntax=docker/dockerfile:1.5

FROM nvidia/cuda:12.1.1-devel-ubuntu22.04 as base_image

FROM base_image as builder

ENV DEBIAN_FRONTEND=noninteractive

ENV TZ="Europe/Moscow"

ENV FORCE_CUDA=1

RUN apt update && \
    apt install -y --no-install-recommends --fix-missing \
    wget\
    git\
    build-essential\ 
    python-setuptools \
    ca-certificates \
    cmake \
    apt-utils \
    ccache \
    libjpeg-dev \
    libpng-dev  \
    libfreeimage-dev \
    tmux \
    tar \
    curl \
    unzip \
    nano \
    ffmpeg \
    sudo \
    gosu

# Install Miniconda See possible versions: https://repo.anaconda.com/miniconda/
ARG CONDA_VERSION=py310_23.1.0-1

ENV CONDA_DIR=/opt/conda

ENV PATH=$CONDA_DIR/bin:$PATH

WORKDIR /home/build

RUN wget -q -O ./miniconda.sh http://repo.continuum.io/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh \
    && sh ./miniconda.sh -bfp $CONDA_DIR \
    && rm ./miniconda.sh

# ARG CONDA_PACKAGE_CACHE=/mnt/conda-cache-dir

# RUN conda config --system --prepend pkgs_dirs ${CONDA_PACKAGE_CACHE}

RUN --mount=type=bind,source=./environment.yaml,target=./environment.yaml \
    # --mount=type=cache,target=${CONDA_PACKAGE_CACHE} \
    # --mount=type=secret,required=true,id=nexus_pypi_netrc,target=/root/.netrc \
    conda env update -n base --file ./environment.yaml

RUN conda clean -ayf 

# SHELL ["conda", "run", "--no-capture-output", "-n", "base", "/bin/bash", "-c"]

ENV CONDA_AUTO_UPDATE_CONDA=false

COPY ./scripts/entrypoint.sh ./

RUN chmod o+x ./entrypoint.sh 

WORKDIR /home/workspace

ENV PROJECT_HOME_DIR=/home/workspace

ENTRYPOINT [ "/home/build/entrypoint.sh"]

CMD [ "bash" ]
