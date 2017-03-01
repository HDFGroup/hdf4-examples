cmake_minimum_required (VERSION 3.2.2)
project (HDF4Examples_JAVA)

#-----------------------------------------------------------------------------
# Build the hdf examples
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/exAN   ${PROJECT_BINARY_DIR}/exAN)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/exGR   ${PROJECT_BINARY_DIR}/exGR)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/exVD   ${PROJECT_BINARY_DIR}/exVD)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/exSD   ${PROJECT_BINARY_DIR}/exSD)
