#!/bin/bash -e
. /etc/profile.d/modules.sh
module add ci
module add gsl/2.1
module add openmpi/1.8.8-gcc-5.2.0

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make check

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}

module add gsl/2.1
module add openmpi/1.8.8-gcc-5.2.0

module-whatis   "$NAME $VERSION."
setenv       HMMER_VERSION       $VERSION
setenv       HMMER_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH   $::env(HMMER_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(HMMER_DIR)/include
prepend-path CFLAGS            "-I${HMMER_DIR}/include"
prepend-path LDFLAGS           "-L${HMMER_DIR}/lib"
prepend-path PATH              $::env(HMMER_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}
module purge
module add ci
# check the module
module avail $NAME
module add $NAME/$VERSION
echo $PATH
echo "checking if we have hmmscan"
which hmmscan
