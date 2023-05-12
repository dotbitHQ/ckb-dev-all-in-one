FROM buildpack-deps:bionic as gnu-builder
MAINTAINER Louis Yu <yuluyi1991@gmail.com>
RUN apt-get update && apt-get install -y git autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/nervosnetwork/ckb-riscv-gnu-toolchain.git --branch update-20191012 /source
WORKDIR /source
RUN mkdir -p /riscv-gnu
RUN ./docker/check_git
RUN git rev-parse HEAD > /riscv-gnu/REVISION
RUN ./configure --prefix=/riscv-gnu --with-arch=rv64imac && make -j$(nproc) linux

FROM thewawar/ckb-capsule:2022-08-01
MAINTAINER Louis Yu <yuluyi1991@gmail.com>
COPY --from=gnu-builder /riscv-gnu /riscv-gnu
ENV RISCV=
ENV PATH "${PATH}:/riscv-gnu/bin"
RUN cargo install --git https://github.com/nervosnetwork/ckb-binary-patcher.git --rev b9489de4b3b9d59bc29bce945279bc6f28413113