########################
# 拉取一个基础镜像
########################
# 从 docker hub的determine ai的仓库拉取
# FROM determinedai/environments:cuda-11.8-pytorch-2.0-gpu-mpi-0.30.1
# 从实验室的服务器拉取
FROM harbor.cvgl.lab/determinedai/environments:cuda-11.8-pytorch-2.0-gpu-mpi-0.27.1


########################
# 一些常规的设置
########################
# 关掉自动提醒
ARG DEBIAN_FRONTEND=noninteractive
# 设置时区、语言和编码
ENV TZ=Asia/Shanghai LANG=C.UTF-8 LC_ALL=C.UTF-8
# 在使用 pip 安装 Python 包时，不会缓存包
ENV PIP_NO_CACHE_DIR=1 
ARG CUDA_ARCHITECTURES=89;86
ENV TORCH_CUDA_ARCH_LIST="8.9;8.6" TORCH_NVCC_FLAGS="-Xfatbin -compress-all"


########################
# 安装常规的依赖
########################
# 将APT源地址替换为中科大的镜像源，并清除其他源
# 安装其他依赖，包括unzip、python-opencv、graphviz
RUN sed -i  "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g"  /etc/apt/sources.list && \
    sed -i  "s/security.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/* &&\
    rm -rf /opt/hpcx/ &&\
    apt-get update && apt-get upgrade -y
    
RUN apt-get install -y --no-install-recommends tzdata             unzip              graphviz          libboost-all-dev
RUN apt-get install -y --no-install-recommends libeigen3-dev      libsuitesparse-dev libfreeimage-dev  qtbase5-dev
RUN apt-get install -y --no-install-recommends libmetis-dev       libgoogle-glog-dev libgflags-dev     libglew-dev 
RUN apt-get install -y --no-install-recommends libsqlite3-dev     libatlas-base-dev  libgtest-dev
RUN apt-get install -y --no-install-recommends libqt5opengl5-dev  libcgal-dev        libcgal-qt5-dev   libflann-dev
WORKDIR /tmp


########################
# 安装第三方库
#   1. colmap 依赖 ceres
#   2. ceres  依赖 glog
########################

# 解决编译glog库时 会出现version `GLIBCXX_3.4.29‘ not found的问题
RUN cp /opt/conda/lib/libstdc++.so.6.0.29 /usr/lib/x86_64-linux-gnu/                                 &&\
    rm /usr/lib/x86_64-linux-gnu/libstdc++.so.6                                                      &&\
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.29 /usr/lib/x86_64-linux-gnu/libstdc++.so.6

# Install GLOG (required by ceres).
RUN git clone --branch v0.6.0 https://github.com/google/glog --single-branch &&\
    cd glog &&\
    mkdir build &&\
    cd build &&\
    cmake .. &&\
    make -j `nproc` &&\
    make install &&\
    rm -rf /tmp/*
# Add glog path to LD_LIBRARY_PATH.
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/lib"

# Install Ceres-solver (required by colmap).
RUN git clone --branch 2.1.0 https://ceres-solver.googlesource.com/ceres-solver --single-branch &&\
    cd ceres-solver &&\
    git checkout $(git describe --tags) &&\
    mkdir build &&\
    cd build &&\
    cmake .. -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF &&\
    make -j8 &&\
    make install &&\
    rm -rf /tmp/*

# Install colmap.
RUN git clone https://github.com/colmap/colmap &&\
    cd colmap &&\
    # Fix CUDA 12.x compile for tag/3.8
    git checkout 1f80118456f4b587a44f288ce5874099fbfebc36 &&\
    mkdir build &&\
    cd build &&\
    cmake .. -DCUDA_ENABLED=ON \
             -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} &&\
    make -j8 &&\
    make install &&\
    rm -rf /tmp/*

# Install 3dgs.
COPY diff-gaussian-rasterization.zip /tmp/diff-gaussian-rasterization.zip
RUN cd /tmp                                 &&\
    unzip diff-gaussian-rasterization.zip   &&\
    cd diff-gaussian-rasterization          &&\
    python setup.py install                 &&\
    pip install .                           &&\
    rm -rf /tmp/* 

# Install simple-knn.
COPY simple-knn-main.zip /tmp/simple-knn-main.zip
RUN cd /tmp                                 &&\
    unzip simple-knn-main.zip               &&\
    cd simple-knn-main                      &&\
    python setup.py install                 &&\
    pip install .                           &&\
    rm -rf /tmp/* 


########################
# python库
########################
# 给pip换源
RUN pip config set global.index-url https://mirrors.bfsu.edu.cn/pypi/web/simple

# 将本地的两个文件 environment.yml 和 pip_requirements.txt 复制到 Docker 容器的 /tmp 目录中
# /tmp 是 Linux 系统中的临时目录，适合在容器构建时用于存放中间文件
COPY environment.yml /tmp/environment.yml
# COPY pip_requirements.txt /tmp/pip_requirements.txt

# libarchive 是一个用于处理不同压缩文件格式的库，可能需要用于处理某些软件包或依赖项。
# -n base：指定要在 base 环境（即默认的 Conda 环境）中进行安装
# -c main：指定从 Conda 的 main 频道安装 libarchive 包
# --force-reinstall：强制重新安装 libarchive，即使它已经安装
# --yes：自动确认所有提示，以避免交互式确认
RUN conda install -n base libarchive -c main --force-reinstall --yes
# 指定默认的包管理渠道
RUN conda config --add channels defaults
# 在base环境中安装environment中的环境
RUN conda env update --name base --file /tmp/environment.yml
# 清理 Conda 的所有缓存，包括下载的包、未使用的索引、和临时文件等。这样可以减少镜像的体积
RUN conda clean --all --force-pkgs-dirs --yes
