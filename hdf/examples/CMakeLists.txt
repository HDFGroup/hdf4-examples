cmake_minimum_required (VERSION 3.1.0)
PROJECT (HDF4Examples_HDF C CXX)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/AN   ${PROJECT_BINARY_DIR}/AN)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/GR   ${PROJECT_BINARY_DIR}/GR)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/VD   ${PROJECT_BINARY_DIR}/VD)
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/VG   ${PROJECT_BINARY_DIR}/VG)
