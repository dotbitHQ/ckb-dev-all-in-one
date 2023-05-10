FROM docker.io/buildpack-deps:focal as base
RUN apt-get update && apt-get install -y git autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/nervosnetwork/ckb-riscv-gnu-toolchain.git --branch update-20191012 /source

FROM base as elf-builder
WORKDIR /source
ENV CFLAGS_FOR_TARGET_EXTRA "-Os -DCKB_NO_MMU -D__riscv_soft_float -D__riscv_float_abi_soft"
RUN mkdir -p /riscv-elf
RUN cd /source && ./docker/check_git
RUN cd /source && git rev-parse HEAD > /riscv-elf/REVISION
RUN cd /source && ./configure --prefix=/riscv-elf --with-arch=rv64imac && make -j$(nproc)


FROM base as gnu-builder
WORKDIR /source
RUN mkdir -p /riscv-gnu
RUN cd /source && ./docker/check_git
RUN cd /source && git rev-parse HEAD > /riscv-gnu/REVISION
RUN cd /source && ./configure --prefix=/riscv-gnu --with-arch=rv64imac && make -j$(nproc) linux


FROM docker.io/buildpack-deps:focal
COPY --from=elf-builder /riscv-elf /riscv-elf
COPY --from=gnu-builder /riscv-gnu /riscv-gnu
RUN apt-get update && apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev cmake && apt-get clean
ENV PATH "${PATH}:/riscv-elf/bin:/riscv-gnu/bin"
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
ENV PATH=/root/.cargo/bin:$PATH
RUN rustup target add riscv64imac-unknown-none-elf
RUN cargo install --git https://github.com/nervosnetwork/ckb-binary-patcher.git --rev b9489de4b3b9d59bc29bce945279bc6f28413113