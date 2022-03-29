cmake_minimum_required (VERSION 3.12)
project (H4EXAMPLES C CXX)

#-----------------------------------------------------------------------------
# Basic HDF4Examples stuff here
#-----------------------------------------------------------------------------
include (${H4EXAMPLES_SOURCE_DIR}/config/cmake/HDFExampleMacros.cmake)
set (CMAKE_JAVA_INCLUDE_PATH "")

SET_HDF_BUILD_TYPE()

BASIC_SETTINGS (EXAMPLES)

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (HDF4EX_RESOURCES_DIR       ${PROJECT_SOURCE_DIR}/config/cmake)
set (HDF4EX_HDFSRC_DIR          ${PROJECT_SOURCE_DIR}/hdf)
set (HDF4EX_HDF_FORTRAN_DIR     ${PROJECT_SOURCE_DIR}/hdf/fortran)
set (HDF4EX_MFHDFSRC_DIR        ${PROJECT_SOURCE_DIR}/mfhdf)
set (HDF4EX_MFHDF_FORTRAN_DIR   ${PROJECT_SOURCE_DIR}/mfhdf/fortran)
set (HDF4EX_JAVA_DIR            ${PROJECT_SOURCE_DIR}/JAVA)

#-----------------------------------------------------------------------------
# HDF4 support
#-----------------------------------------------------------------------------
HDF4_SUPPORT (TRUE)
message (STATUS "HDF4 link libs: ${LINK_LIBS}")

if (WIN32)
  set(CMAKE_TEST_LIB_DIRECTORY "${HDF4_TOOLS_DIR}")
else ()
  set(CMAKE_TEST_LIB_DIRECTORY "${HDF4_LIBRARY_PATH}")
endif ()

#-----------------------------------------------------------------------------
# All examples need the main include directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${PROJECT_BINARY_DIR})

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build HDF4 Example Testing" OFF)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200 CACHE STRING
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)
  include (${PROJECT_SOURCE_DIR}/CTestConfig.cmake)
  configure_file (${HDF4EX_RESOURCES_DIR}/CTestCustom.cmake ${PROJECT_BINARY_DIR}/CTestCustom.ctest @ONLY)
endif ()

#-----------------------------------------------------------------------------
# Build examples
#-----------------------------------------------------------------------------
if (HDF_BUILD_C)
  add_subdirectory (hdf/examples)
  add_subdirectory (mfhdf/examples)
endif ()

#-----------------------------------------------------------------------------
# Option to build Fortran examples
# Make sure this appears before the CONFIGURE_FILE step
# so that fortran name mangling is detected before writing H4config.h
#-----------------------------------------------------------------------------
# Set default name mangling : overridden by Fortran detection in fortran dir
set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) name ## _")
set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) name ## __")
if (EXISTS "${PROJECT_SOURCE_DIR}/mfhdf/fortran" AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/mfhdf/fortran")
  option (HDF_BUILD_FORTRAN "Build FORTRAN support" OFF)
  if (HDF_BUILD_FORTRAN AND HDF4_BUILD_FORTRAN)
      set (LINK_Fortran_LIBS ${LINK_LIBS})

    if (WIN32)
      set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) NAME")
      set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) NAME")
    endif ()

    add_subdirectory (mfhdf/fortran)
    add_subdirectory (hdf/fortran)
  endif ()
endif ()

#-----------------------------------------------------------------------------
# Option to build JAVA examples
#-----------------------------------------------------------------------------
if (EXISTS "${PROJECT_SOURCE_DIR}/JAVA" AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/JAVA")
  option (HDF_BUILD_JAVA "Build JAVA support" OFF)
  if (HDF_BUILD_JAVA AND HDF4_BUILD_JAVA)
    include (${HDF4EX_RESOURCES_DIR}/UseJava.cmake)
    add_subdirectory (JAVA)
  endif ()
endif ()
