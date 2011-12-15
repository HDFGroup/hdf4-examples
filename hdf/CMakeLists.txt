cmake_minimum_required (VERSION 2.8.6)
PROJECT (HDF4_HDF)

#-----------------------------------------------------------------------------
# Build the hdf examples
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${HDF4_HDF_SOURCE_DIR}/examples   ${HDF4_HDF_BINARY_DIR}/examples)
IF (HDF4_BUILD_FORTRAN)
  ADD_SUBDIRECTORY (${HDF4_HDF_SOURCE_DIR}/fortran      ${HDF4_HDF_BINARY_DIR}/fortran)
ENDIF (HDF4_BUILD_FORTRAN)
