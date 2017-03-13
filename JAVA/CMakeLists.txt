cmake_minimum_required (VERSION 3.2.2)
project (HDF4Examples_JAVA)

#-----------------------------------------------------------------------------
# Build the hdf examples
#-----------------------------------------------------------------------------
add_subdirectory (${PROJECT_SOURCE_DIR}/exAN   ${PROJECT_BINARY_DIR}/exAN)
add_subdirectory (${PROJECT_SOURCE_DIR}/exGR   ${PROJECT_BINARY_DIR}/exGR)
add_subdirectory (${PROJECT_SOURCE_DIR}/exVD   ${PROJECT_BINARY_DIR}/exVD)
add_subdirectory (${PROJECT_SOURCE_DIR}/exSD   ${PROJECT_BINARY_DIR}/exSD)
