#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add gsl
module add openmpi
echo ${DEPLOY_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"

export LDFLAGS="-L${GSL_DIR}/lib"
export LIBS="-lgsl -lgslcblas -lm"
../configure --prefix=${SOFT_DIR} \
 --enable-mpi \
 --enable-threads \
 --enable-gcov \
 --enable-gsl


make install
echo "Creating the modules file directory ${BIOINFORMATICS}"
mkdir -vp modules ${BIOINFORMATICS}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add gsl
module add openmpi

module-whatis   "$NAME $VERSION."
setenv                         HMMER_VERSION       $VERSION
setenv HMMER_DIR               $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(HMMER_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(HMMER_DIR)/include
prepend-path CFLAGS            "-I${HMMER_DIR}/include"
prepend-path LDFLAGS           "-L${HMMER_DIR}/lib"
prepend-path PATH              $::env(HMMER_DIR)/bin
MODULE_FILE
) > ${BIOINFORMATICS}/${NAME}/${VERSION}

module avail ${NAME}
module add ${NAME}/${VERSION}
echo $PATH
which hmmscan
