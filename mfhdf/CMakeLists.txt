cmake_minimum_required (VERSION 3.1.0)
PROJECT (HDF4Examples_MFHDF)

#-----------------------------------------------------------------------------
# Build the mfhdf examples
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/examples      ${PROJECT_BINARY_DIR}/examples)
IF (HDF_BUILD_FORTRAN)
  ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/fortran      ${PROJECT_BINARY_DIR}/fortran)
ENDIF (HDF_BUILD_FORTRAN)
