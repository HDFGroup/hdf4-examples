cmake_minimum_required (VERSION 2.8.6)
PROJECT (HDF4_MFHDF)

#-----------------------------------------------------------------------------
# Build the mfhdf examples
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${HDF4_MFHDF_SOURCE_DIR}/examples      ${HDF4_MFHDF_BINARY_DIR}/examples)
IF (HDF4_BUILD_FORTRAN)
  ADD_SUBDIRECTORY (${HDF4_MFHDF_SOURCE_DIR}/fortran      ${HDF4_MFHDF_BINARY_DIR}/fortran)
ENDIF (HDF4_BUILD_FORTRAN)
