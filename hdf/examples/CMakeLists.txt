cmake_minimum_required (VERSION 3.2.2)
project (HDF4Examples_HDF C CXX)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
add_subdirectory (${PROJECT_SOURCE_DIR}/AN   ${PROJECT_BINARY_DIR}/AN)
add_subdirectory (${PROJECT_SOURCE_DIR}/GR   ${PROJECT_BINARY_DIR}/GR)
add_subdirectory (${PROJECT_SOURCE_DIR}/VD   ${PROJECT_BINARY_DIR}/VD)
add_subdirectory (${PROJECT_SOURCE_DIR}/VG   ${PROJECT_BINARY_DIR}/VG)
