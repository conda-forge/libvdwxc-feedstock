#!/bin/sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config/gnu

mkdir build && cd build

if [[ x"$mpi" != x"nompi" ]]; then
  if [[ "${target_platform}" == osx-arm64 ]]; then
    export CC=$BUILD_PREFIX/bin/mpicc
    export FC=$BUILD_PREFIX/bin/mpifort
  else
    export CC=mpicc
    export FC=mpifort
  fi
fi
configure_args=(
  "--prefix=${PREFIX}"
  "--build=${BUILD}"
  "--host=${HOST}"
  "--disable-static"
  "--with-fftw3=${PREFIX}"
)
if [[ x"$mpi" != x"nompi" ]]; then
  configure_args+=(--with-mpi=$PREFIX)
fi
../configure \
  CC=$CC \
  FC=$FC \
  CFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" \
  LCFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" \
  ${configure_args[@]} || (cat config.log && false)
make -j$CPU_COUNT
if [[ x"$mpi" != x"mpich" ]]; then
  make check
fi
make install

# Removes binaries built and used by `make check` 
rm -rf $PREFIX/bin/libvdw_*test
