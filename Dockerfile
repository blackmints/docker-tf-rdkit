FROM ubuntu:18.04 AS rdkit-build-env

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        wget \
        ca-certificates \
        cmake gfortran \
        libcairo2-dev libeigen3-dev libssl-dev libffi-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV MKL_ROOT_DIR /opt/intel/mkl
ENV LD_LIBRARY_PATH $MKL_ROOT_DIR/lib/intel64

ARG N_PROC=2
ARG PYTHON_VERSION=3.6
RUN mkdir -p /src/python \
    && cd /src/python \
    && wget -qO- https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz | tar xzf - --strip-components=1 \
    && ./configure \
    && make -j${N_PROC} \
    && make install \
    && cd .. && rm -rf /src/python

ENV PATH /usr/local/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
ENV INCLUDE_PATH /usr/local/include:$INCLUDE_PATH

ARG BOOST_VERSION=1.69.0
RUN mkdir -p /src/boost \
    && cd /src/boost \
    && wget -qO- https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_$(echo $BOOST_VERSION | tr '.' '_').tar.gz \
        | tar xzf - --strip-components=1 \
    && ./bootstrap.sh \
    && python_version=$(echo ${PYTHON_VERSION} | grep -oE '[23]\.[0-9]+') \
    && echo "using python : ${python_version} : /usr/local : /usr/local/include/python${python_version}m ;" > user-config.jam \
    && ./b2 install -j${N_PROC} --with-system --with-iostreams --with-python --with-serialization --user-config=user-config.jam \
    && cd / && rm -rf /src/boost

ADD numpy-site.cfg /root/.numpy-site.cfg

RUN pip3 install --no-binary :all: numpy scipy
RUN pip3 install pillow six pandas

ENV RDBASE /opt/rdkit
ENV LD_LIBRARY_PATH $RDBASE/lib:$LD_LIBRARY_PATH
ENV PYTHONPATH $RDBASE:$PYTHONPATH

ARG RDKIT_VERSION=2019_03_2
RUN mkdir -p /opt/rdkit \
    && cd /opt/rdkit \
    && wget -qO- https://github.com/rdkit/rdkit/archive/Release_${RDKIT_VERSION}.tar.gz \
        | tar xzf - --strip-components=1 \
    && mkdir build && cd build \
    && cmake \
        -DPYTHON_EXECUTABLE=$(which python3) \
        -DRDK_BUILD_AVALON_SUPPORT=ON \
        -DRDK_BUILD_CAIRO_SUPPORT=ON \
        -DRDK_BUILD_INCHI_SUPPORT=ON \
        .. \
    && make -j${N_PROC} \
    && make install
