cmake_minimum_required (VERSION 3.2.2)
project (HDF4Examples_MFHDF)

#-----------------------------------------------------------------------------
# Build the mfhdf examples
#-----------------------------------------------------------------------------
add_subdirectory (${PROJECT_SOURCE_DIR}/examples      ${PROJECT_BINARY_DIR}/examples)
if (HDF_BUILD_FORTRAN)
  add_subdirectory (${PROJECT_SOURCE_DIR}/fortran      ${PROJECT_BINARY_DIR}/fortran)
endif (HDF_BUILD_FORTRAN)
