# local 빌드시
FROM tensorflow/tensorflow:2.13.0-gpu-jupyter 
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04 AS nvidia

# CUDA
ENV CUDA_MAJOR_VERSION=11
ENV CUDA_MINOR_VERSION=3
ENV CUDA_VERSION=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION

ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:/opt/bin:${PATH}

ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu
ENV LD_LIBRARY_PATH_NO_STUBS="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/opt/conda/lib"
ENV LD_LIBRARY_PATH="/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/cuda/lib64/stubs:/opt/conda/lib"
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=$CUDA_MAJOR_VERSION.$CUDA_MINOR_VERSION"

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | cat > /etc/apt/apt.conf.d/10no--check-valid-until
RUN apt-get update && apt-get install -y apt-transport-https

# 카카오 ubuntu archive mirror server 추가. 다운로드 속도 향상
#RUN sed -i 's@archive.ubuntu.com@mirror.kakao.com@g' /etc/apt/sources.list && \
#    apt-get update && apt-get install alien -y
RUN sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update && apt-get install -y

# openjdk java vm 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    g++ \
    gcc \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    curl \
    bzip2 \
    ca-certificates \
    libglib2.0-0 \
    libxext6 \
    libsm6 \
    libxrender1 \
    libssl-dev \
    libzmq3-dev \
    vim \
    git \
    cmake

RUN apt-get update

ARG CONDA_DIR=/opt/conda
ENV CUDA_PATH=/usr/local/cuda

# add to path
ENV PATH $CONDA_DIR/bin:$PATH

# Install miniconda
RUN echo "export PATH=$CONDA_DIR/bin:"'$PATH' > /etc/profile.d/conda.sh && \
    curl -sL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p $CONDA_DIR && \
    rm ~/miniconda.sh

# Conda 가상환경 생성
RUN conda config --set always_yes yes --set changeps1 no && conda create -y -q -n py39 python=3.9

ENV PATH /opt/conda/envs/py39/bin:$PATH
ENV CONDA_DEFAULT_ENV py39
ENV CONDA_PREFIX /opt/conda/envs/py39
ENV PATH=/usr/local/bin:${PATH}

#RUN echo "Acquire::Check-Valid-Until \"false\";\nAcquire::Check-Date \"false\";" | cat > /etc/apt/apt.conf.d/10no--check-valid-until

RUN apt-get update
#RUN apt-get update && apt-get install -y apt-transport-https

# Install OpenCL & libboost
RUN apt-get install -y ocl-icd-libopencl1 clinfo libboost-all-dev && \
    mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# 패키지 설치
RUN pip install setuptools && \
    pip install mkl && \
    pip install pymysql && \
    pip install numpy && \
    pip install scipy && \
    pip install pandas && \
    pip install matplotlib && \
    pip install seaborn && \
    pip install hyperopt && \
    pip install optuna && \
    pip install missingno && \
    pip install mlxtend && \
    pip install catboost && \
    pip install kaggle && \
    pip install folium && \
    pip install librosa && \
    pip install nbconvert && \
    pip install Pillow && \
    pip install tqdm && \
    pip install tensorflow-datasets && \
    pip install gensim && \
    pip install nltk && \
    pip install wordcloud && \
    pip install statsmodels

RUN apt-get update

RUN apt-get install -y graphviz && \
    apt-get install -y graphviz-dev && \
    pip install pygraphviz

RUN apt-get update

RUN pip install graphviz && \
    pip install cupy-cuda11x

RUN pip install -U cython && \
    pip install -U cysignals && \
    pip install pyfasttext && \
    pip install fasttext && \
    pip install accelerate && \
    pip install sentencepiece && \
    pip install -U bitsandbytes && \
    pip install -U git+https://github.com/huggingface/transformers.git && \
    pip install -U git+https://github.com/huggingface/peft.git && \
    pip install -U git+https://github.com/huggingface/accelerate.git && \
    pip install -U datasets

RUN pip install pystan==2.19.1.1 && \
    pip install prophet && \
    pip install torchsummary

RUN pip install wandb tensorboard albumentations pydicom opencv-python scikit-image pyarrow kornia \
    catalyst captum

RUN pip install fastai && \
    pip install fvcore 

RUN pip install openai && \
    pip install langchain && \
    pip install duckduckgo-search && \
    pip install pypdf && \
    pip install tiktoken && \
    pip install chromadb && \
    pip install pinecone-client

RUN pip install cudf-cu11 dask-cudf-cu11 cuml-cu11 --extra-index-url=https://pypi.nvidia.com

RUN pip install -U "ipython[all]"

RUN git clone https://github.com/slundberg/shap.git && cd shap && \
    python setup.py install

RUN pip install jupyter jupyterlab notebook jupyterthemes ipywidgets
 
ENV PATH=/usr/local/bin:${PATH}

# 나눔고딕 폰트 설치
# matplotlib에 Nanum 폰트 추가
RUN apt-get update && apt-get install fonts-nanum*
RUN cp /usr/share/fonts/truetype/nanum/Nanum* /opt/conda/envs/py39/lib/python3.9/site-packages/matplotlib/mpl-data/fonts/ttf/ && \
    fc-cache -fv && \
    rm -rf ~/.cache/matplotlib/*

# Mecab 설치
RUN apt-get update
RUN apt-get install g++ openjdk-8-jdk
RUN pip install konlpy JPype1-py3
RUN bash -c "bash <(curl -s https://raw.githubusercontent.com/konlpy/konlpy/master/scripts/mecab.sh)"; exit 0

# mecab-python의 버전 오류로 인해 아래 패키지를 설치하면 코랩에서 Mecab을 사용가능
RUN pip install mecab-python3

# XGBoost (GPU 설치)
RUN pip install xgboost && \
    pip install lightgbm

#RUN conda install -c nvidia -y

# Install OpenCL & libboost (required by LightGBM GPU version)
# RUN apt-get install -y ocl-icd-libopencl1 clinfo libboost-all-dev && \
#    mkdir -p /etc/OpenCL/vendors && \
#    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# RUN conda install -c conda-forge py-xgboost-gpu -y

# lightgbm (GPU 설치)
#RUN pip uninstall -y lightgbm && \
#    cd /usr/local/src && mkdir lightgbm && cd lightgbm && \
#    git clone --recursive --branch stable --depth 1 https://github.com/microsoft/LightGBM && \
#    cd LightGBM && mkdir build && cd build && \
#    cmake -DUSE_GPU=1 -DOpenCL_LIBRARY=/usr/local/cuda/lib64/libOpenCL.so -DOpenCL_INCLUDE_DIR=/usr/local/cuda/include/ .. && \
#    make -j$(nproc) OPENCL_HEADERS=/usr/local/cuda-11.2/targets/x86_64-linux/include LIBOPENCL=/usr/local/cuda-11.2/targets/x86_64-linux/lib && \
#    cd /usr/local/src/lightgbm/LightGBM/python-package && python setup.py install --precompile


# RUN git clone --recursive https://github.com/microsoft/LightGBM && \
#    cd LightGBM && \
#    mkdir build && \
#    cd build && \
#    cmake -DUSE_GPU=1 .. && \
#    make -j$(nproc) && \
#    cd ..

# soynlp, KR-WordRank, soyspacing, customized_konlpy 설치
RUN pip install soynlp && \
    pip install krwordrank && \
    pip install soyspacing && \
    pip install customized_konlpy

# PyTorch 2.0 설치
RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
RUN pip install torchtext==0.15.1

# PyTorch 2.0 compile 모드 지원을 위한 설치
RUN pip install torchtriton --extra-index-url "https://download.pytorch.org/whl/nightly/cu118" 

# TensorFlow 2.13.0 설치
RUN pip install tensorflow==2.13.0

# Remove the CUDA stubs.
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH_NO_STUBS"

# locale 설정
# RUN apt-get update && apt-get install -y locales tzdata && \
#     locale-gen ko_KR.UTF-8 && locale -a && \
#     ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

RUN apt-get autoremove -y && apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    conda clean -a -y

RUN apt-get update

# LANG 환경변수 설정
ENV LANG ko_KR.UTF-8

# Jupyter Notebook config 파일 생성
# RUN jupyter notebook --generate-config

# config 파일 복사 (jupyter_notebook_config.py 파일 참고)
# COPY jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

# 설치 완료 후 테스트용 ipynb
COPY ./01-GPU-TEST/GPU-Test.ipynb /home/jupyter/GPU-Test.ipynb

# 기본
EXPOSE 8888
# jupyter notebook 의 password를 지정하지 않으면 보안상 취약하므로 지정하는 것을 권장
# CMD jupyter notebook --allow-root




