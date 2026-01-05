#!/bin/sh
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config/gnu

mkdir build && cd build

if [[ "$CONDA_BUILD_CROSS_COMPILATION" == "1" ]]; then
  # This is only used by open-mpi's mpicc
  # ignored in other cases
  export OMPI_CC=$CC
  export OMPI_CXX=$CXX
  export OMPI_FC=$FC
  export OPAL_PREFIX=$PREFIX
fi

export CFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops"
export FCFLAGS=$CFLAGS

configure_args=(
  "--prefix=${PREFIX}"
  "--build=${BUILD}"
  "--host=${HOST}"
  "--disable-static"
  "--with-fftw3=${PREFIX}"
)
if [[ x"$mpi" != x"nompi" ]]; then
  if [[ "${target_platform}" == osx-arm64 ]]; then
    export CC=$BUILD_PREFIX/bin/mpicc
    export FC=$BUILD_PREFIX/bin/mpifort
  else
    export CC=mpicc
    export FC=mpifort
  fi
  configure_args+=(--with-mpi=$PREFIX)
fi
../configure ${configure_args[@]} || (cat config.log && false)
make -j$CPU_COUNT
if [[ "${target_platform}" == "linux*" ]] || [[ x"$mpi" == x"nompi" ]]; then
  make check
fi
make install

# Removes binaries built and used by `make check` 
rm -rf $PREFIX/bin/libvdw_*test
