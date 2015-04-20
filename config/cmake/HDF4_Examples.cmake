cmake_minimum_required(VERSION 3.1.0 FATAL_ERROR)
###############################################################################################################
# This script will build and run the examples from an existing source folder
# Execute from a command line:
#     ctest -S HDF4_Examples.cmake,HDF4Examples -C Release -O test.log
###############################################################################################################

###############################################################################################################
#     Adjust the following SET Commands to match your HDF4 installation
###############################################################################################################
set(INSTALLDIR "/my_hdf_install/hdf4")  # appends line 29/37 to locate configuration files
set(CTEST_CMAKE_GENERATOR "my_build_system")
set(STATICLIBRARIES "TRUE/FALSE")  # true if HDF4 built with static libraries
###############################################################################################################

set(CTEST_SOURCE_NAME ${CTEST_SCRIPT_ARG})
set(CTEST_DASHBOARD_ROOT ${CTEST_SCRIPT_DIRECTORY})
set(CTEST_BUILD_CONFIGURATION "Release")
#set(NO_MAC_FORTRAN "true")
#set(BUILD_OPTIONS ""${BUILD_OPTIONS} -DHDF_BUILD_FORTRAN:BOOL=ON")

###############################################################################################################
#     Adjust the following SET Commands as needed
###############################################################################################################
if(WIN32)
  if(STATICLIBRARIES)
    set(BUILD_OPTIONS "${BUILD_OPTIONS} -DBUILD_SHARED_LIBS:BOOL=OFF")
  endif(STATICLIBRARIES)
  set(ENV{HDF4_DIR} "${INSTALLDIR}/cmake/hdf4")
  set(CTEST_BINARY_NAME ${CTEST_SOURCE_NAME}\\build)
  set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}\\${CTEST_SOURCE_NAME}")
  set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}\\${CTEST_BINARY_NAME}")
else(WIN32)
  if(STATICLIBRARIES)
    set(BUILD_OPTIONS "${BUILD_OPTIONS} -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_ANSI_CFLAGS:STRING=-fPIC")
  endif(STATICLIBRARIES)
  set(ENV{HDF4_DIR} "${INSTALLDIR}/share/cmake/hdf4")
  set(ENV{LD_LIBRARY_PATH} "${INSTALLDIR}/lib")
  set(CTEST_BINARY_NAME ${CTEST_SOURCE_NAME}/build)
  set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_SOURCE_NAME}")
  set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${CTEST_BINARY_NAME}")
endif(WIN32)

###############################################################################################################
# For any comments please contact cdashhelp@hdfgroup.org
#
###############################################################################################################
 
#-----------------------------------------------------------------------------
# MAC machines need special option
#-----------------------------------------------------------------------------
if(APPLE)
  # Compiler choice
  execute_process(COMMAND xcrun --find cc OUTPUT_VARIABLE XCODE_CC OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(COMMAND xcrun --find c++ OUTPUT_VARIABLE XCODE_CXX OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(ENV{CC} "${XCODE_CC}")
  set(ENV{CXX} "${XCODE_CXX}")
  if(NOT MAC_FORTRAN_ON)
    # Shared fortran is not supported, build static 
    set(BUILD_OPTIONS "${BUILD_OPTIONS} -DHDF_BUILD_FORTRAN:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF -DCMAKE_ANSI_CFLAGS:STRING=-fPIC")
  else(NOT MAC_FORTRAN_ON)
    set(BUILD_OPTIONS "${BUILD_OPTIONS} -DHDF_BUILD_FORTRAN:BOOL=ON")
  endif(NOT MAC_FORTRAN_ON)
  set(BUILD_OPTIONS "${BUILD_OPTIONS} -DCTEST_USE_LAUNCHERS:BOOL=ON -DCMAKE_BUILD_WITH_INSTALL_RPATH:BOOL=OFF")
endif(APPLE)
 
#-----------------------------------------------------------------------------
set(CTEST_CMAKE_COMMAND "\"${CMAKE_COMMAND}\"")
 
#-----------------------------------------------------------------------------
## Clear the build directory
## --------------------------
set(CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
file(MAKE_DIRECTORY "${CTEST_BINARY_DIRECTORY}")
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

# Use multiple CPU cores to build
include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
  if(NOT WIN32)
    set(CTEST_BUILD_FLAGS -j${N})
  endif(NOT WIN32)
  set(ctest_test_args ${ctest_test_args} PARALLEL_LEVEL ${N})
endif()
set (CTEST_CONFIGURE_COMMAND
    "${CTEST_CMAKE_COMMAND} -C \"${CTEST_SOURCE_DIRECTORY}/config/cmake/cacheinit.cmake\" -DCMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION} ${BUILD_OPTIONS} \"-G${CTEST_CMAKE_GENERATOR}\" \"${CTEST_SOURCE_DIRECTORY}\""
)
 
#-----------------------------------------------------------------------------
## -- set output to english
set($ENV{LC_MESSAGES}  "en_EN")
 
#-----------------------------------------------------------------------------
  ## NORMAL process
  ## --------------------------
  CTEST_START (Experimental)
  CTEST_CONFIGURE (BUILD "${CTEST_BINARY_DIRECTORY}")
  CTEST_READ_CUSTOM_FILES ("${CTEST_BINARY_DIRECTORY}")
  CTEST_BUILD (BUILD "${CTEST_BINARY_DIRECTORY}" APPEND)
  CTEST_TEST (BUILD "${CTEST_BINARY_DIRECTORY}" APPEND ${ctest_test_args} RETURN_VALUE res)
  if(res GREATER 0)
    message (FATAL_ERROR "tests FAILED")
  endif(res GREATER 0)
#-----------------------------------------------------------------------------
############################################################################################################## 
message("DONE")