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

if [[ "$target_platform" == osx-* ]]; then
  export SDKROOT=$(xcrun --show-sdk-path)
fi

if [[ x"$mpi" != x"nompi" ]]; then
  ../configure --prefix=$PREFIX --disable-static CC=mpicc FC=mpifort CFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" FCFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" --with-fftw3=$PREFIX --with-mpi=$PREFIX
else
  ../configure --prefix=$PREFIX --disable-static CC=$CC FC=$FC CFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" FCFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" --with-fftw3=$PREFIX
fi



make -j$CPU_COUNT
make check
make install

# Removes binaries built and used by `make check` 
rm -rf $PREFIX/bin/libvdw_*test
