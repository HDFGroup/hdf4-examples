cmake_minimum_required (VERSION 3.1.0)
PROJECT (HDF4Examples C CXX)

#-----------------------------------------------------------------------------
# Instructions for use : Normal Build
#
# For standard build of HDF4 examples.
#-----------------------------------------------------------------------------
set (CMAKE_NO_SYSTEM_FROM_IMPORTED 1)

#-----------------------------------------------------------------------------
# Allow Visual Studio solution directories
#-----------------------------------------------------------------------------
# Provide a way for Visual Studio Express users to turn OFF the new FOLDER
# organization feature. Default to ON for non-Express users. Express users must
# explicitly turn off this option to build HDF4 in the Express IDE...
#
option (HDF4_USE_FOLDERS "Enable folder grouping of projects in IDEs." ON)
MARK_AS_ADVANCED (HDF4_USE_FOLDERS)
if (HDF4_USE_FOLDERS)
  set_property (GLOBAL PROPERTY USE_FOLDERS ON)
endif (HDF4_USE_FOLDERS)

#-----------------------------------------------------------------------------
# Define some CMake variables for use later in the project
#-----------------------------------------------------------------------------
set (HDF4EX_RESOURCES_DIR       ${PROJECT_SOURCE_DIR}/config/cmake)
set (HDF4EX_HDFSRC_DIR          ${PROJECT_SOURCE_DIR}/hdf)
set (HDF4EX_HDF_FORTRAN_DIR     ${PROJECT_SOURCE_DIR}/hdf/fortran)
set (HDF4EX_MFHDFSRC_DIR        ${PROJECT_SOURCE_DIR}/mfhdf)
set (HDF4EX_MFHDF_FORTRAN_DIR   ${PROJECT_SOURCE_DIR}/mfhdf/fortran)

#-----------------------------------------------------------------------------
# Include some macros for reusable code
#-----------------------------------------------------------------------------
include (${HDF4EX_RESOURCES_DIR}/HDFMacros.cmake)
include (${HDF4EX_RESOURCES_DIR}/HDF4Macros.cmake)

#-----------------------------------------------------------------------------
# Setup output Directories
#-----------------------------------------------------------------------------
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Executables."
)
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all Libraries"
)
set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all static libraries."
)
set (CMAKE_Fortran_MODULE_DIRECTORY
    ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all fortran modules."
)

#-----------------------------------------------------------------------------
# When building utility executables that generate other (source) files :
# we make use of the following variables defined in the root CMakeLists.
# Certain systems may add /Debug or /Release to output paths
# and we need to call the executable from inside the CMake configuration
#-----------------------------------------------------------------------------
set (EXE_EXT "")
if (WIN32)
  set (EXE_EXT ".exe")
  if (NOT CYGWIN)
    ADD_DEFINITIONS (-D_BIND_TO_CURRENT_VCLIBS_VERSION=1)
    ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS)
    ADD_DEFINITIONS (-D_CONSOLE)
  endif (NOT CYGWIN)
endif (WIN32)

if (MSVC)
  set (CMAKE_MFC_FLAG 0)
endif (MSVC)

set (MAKE_SYSTEM)
if (CMAKE_BUILD_TOOL MATCHES "make")
  set (MAKE_SYSTEM 1)
endif (CMAKE_BUILD_TOOL MATCHES "make")

set (CFG_INIT "/${CMAKE_CFG_INTDIR}")
if (MAKE_SYSTEM)
  set (CFG_INIT "")
endif (MAKE_SYSTEM)

#-----------------------------------------------------------------------------
# Compiler specific flags : Shouldn't there be compiler tests for these
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -fomit-frame-pointer -finline-functions -fno-common")
endif (CMAKE_COMPILER_IS_GNUCXX)

#-----------------------------------------------------------------------------
# HDF4 support
#-----------------------------------------------------------------------------
set (CMAKE_MODULE_PATH ${HDF4EX_RESOURCES_DIR} ${CMAKE_MODULE_PATH})

if (NOT USE_SHARED_LIBS)
  set (HDF4_USE_STATIC_LIBRARIES 1)
endif (NOT USE_SHARED_LIBS)

if (NOT HDF4_HDF4_HEADER)
  find_package (HDF4 NAMES ${HDF4_PACKAGE_NAME})
  if (HDF4_FOUND)
    set (HDF4_HAVE_HDF_H 1)
    set (HDF4_HAVE_HDF4 1)
    set (HDF4_HDF4_HEADER "hdf.h")
    set (HDF4_INCLUDE_DIR_GEN ${HDF4_INCLUDE_DIR})
    message (STATUS "HDF4 found: INC=${HDF4_INCLUDE_DIR} TOOLS=${HDF4_TOOLS_DIR}")
    if ((NOT USE_SHARED_LIBS AND HDF4_BUILD_SHARED_LIBS) OR (USE_SHARED_LIBS AND NOT HDF4_BUILD_SHARED_LIBS))
      message (STATUS "HDF4 build type does match requested type")
    endif ((NOT USE_SHARED_LIBS AND HDF4_BUILD_SHARED_LIBS) OR (USE_SHARED_LIBS AND NOT HDF4_BUILD_SHARED_LIBS))
    if (HDF4_BUILD_SHARED_LIBS)
      ADD_DEFINITIONS (-DH4_BUILT_AS_DYNAMIC_LIB)
    else (HDF4_BUILD_SHARED_LIBS)
      ADD_DEFINITIONS (-DH4_BUILT_AS_STATIC_LIB)
    endif (HDF4_BUILD_SHARED_LIBS)
  else (HDF4_FOUND)
    message (FATAL_ERROR " HDF4 is Required for HDF4 Examples")
  endif (HDF4_FOUND)
else (NOT HDF4_HDF4_HEADER)
  # This project is being called from within another and HDF4 is already configured
  set (HDF4_HAVE_HDF_H 1)
  set (HDF4_HAVE_HDF4 1)
endif (NOT HDF4_HDF4_HEADER)
add_executable (hdp IMPORTED)
if (USE_SHARED_LIBS AND WIN32)
  set_property (TARGET hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdpdll")
else (USE_SHARED_LIBS AND WIN32)
  set_property (TARGET hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdp")
endif (USE_SHARED_LIBS AND WIN32)
set (HDF4_DUMP_EXECUTABLE $<TARGET_FILE:hdp>)
set (LINK_LIBS ${LINK_LIBS} ${HDF4_LIBRARIES})
INCLUDE_DIRECTORIES (${HDF4_INCLUDE_DIR})
if (HDF_BUILD_FORTRAN)
  INCLUDE_DIRECTORIES (${HDF4_INCLUDE_DIR_FORTRAN})
endif (HDF_BUILD_FORTRAN)

#-----------------------------------------------------------------------------
# Option to use Shared/Static libs, default is static
#-----------------------------------------------------------------------------
set (LIB_TYPE STATIC)
if (BUILD_SHARED_LIBS)
  set (LIB_TYPE SHARED)
else (BUILD_SHARED_LIBS)
  if (NOT WIN32)
    # should this be a user setting : Everyone uses it anyway ?
    ADD_DEFINITIONS (-DPIC)
  endif (NOT WIN32)
endif (BUILD_SHARED_LIBS)

#-----------------------------------------------------------------------------
# Option to allow the user to disable compiler warnings
#-----------------------------------------------------------------------------
option (HDF_DISABLE_COMPILER_WARNINGS "Disable compiler warnings" OFF)
if (HDF_DISABLE_COMPILER_WARNINGS)
  # MSVC uses /w to suppress warnings.  It also complains if another
  # warning level is given, so remove it.
  if (MSVC)
    set (HDF_WARNINGS_BLOCKED 1)
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /w")
    string (REGEX REPLACE "(^| )([/-])W[0-9]( |$)" " " CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /w")
  endif (MSVC)
  if (WIN32)
    ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS)
  endif (WIN32)
  # Borland uses -w- to suppress warnings.
  if (BORLAND)
    set (HDF_WARNINGS_BLOCKED 1)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w-")
  endif (BORLAND)

  # Most compilers use -w to suppress warnings.
  if (NOT HDF_WARNINGS_BLOCKED)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
  endif (NOT HDF_WARNINGS_BLOCKED)
endif (HDF_DISABLE_COMPILER_WARNINGS)

#-----------------------------------------------------------------------------
# This is in here to help some of the GCC based IDES like Eclipse
# and code blocks parse the compiler errors and warnings better.
#-----------------------------------------------------------------------------
if (CMAKE_COMPILER_IS_GNUCC)
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCC)
if (CMAKE_COMPILER_IS_GNUCXX)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
endif (CMAKE_COMPILER_IS_GNUCXX)

#-----------------------------------------------------------------------------
# All examples need the main include directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (${PROJECT_BINARY_DIR})

#-----------------------------------------------------------------------------
# Dashboard and Testing Settings
#-----------------------------------------------------------------------------
option (BUILD_TESTING "Build HDF4 Example Testing" OFF)
if (BUILD_TESTING)
  set (DART_TESTING_TIMEOUT 1200
      CACHE INTEGER
      "Timeout in seconds for each test (default 1200=20minutes)"
  )
  enable_testing ()
  include (CTest)
  include (${PROJECT_SOURCE_DIR}/CTestConfig.cmake)
  configure_file (${HDF4EX_RESOURCES_DIR}/CTestCustom.cmake ${PROJECT_BINARY_DIR}/CTestCustom.ctest @ONLY)
endif (BUILD_TESTING)

#-----------------------------------------------------------------------------
# Build examples
#-----------------------------------------------------------------------------
add_subdirectory (${PROJECT_SOURCE_DIR}/hdf/examples     ${PROJECT_BINARY_DIR}/hdf/examples)
add_subdirectory (${PROJECT_SOURCE_DIR}/mfhdf/examples   ${PROJECT_BINARY_DIR}/mfhdf/examples)

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
  if (HDF_BUILD_FORTRAN)
    if (WIN32 AND NOT CYGWIN)
      set (H4_F77_FUNC "H4_F77_FUNC(name,NAME) NAME")
      set (H4_F77_FUNC_ "H4_F77_FUNC_(name,NAME) NAME")
    endif (WIN32 AND NOT CYGWIN)
    include (${HDF4EX_RESOURCES_DIR}/HDF4UseFortran.cmake)
    add_subdirectory (${PROJECT_SOURCE_DIR}/mfhdf/fortran ${PROJECT_BINARY_DIR}/mfhdf/fortran)
    add_subdirectory (${PROJECT_SOURCE_DIR}/hdf/fortran ${PROJECT_BINARY_DIR}/hdf/fortran)
  endif (HDF_BUILD_FORTRAN)
endif (EXISTS "${PROJECT_SOURCE_DIR}/mfhdf/fortran" AND IS_DIRECTORY "${PROJECT_SOURCE_DIR}/mfhdf/fortran")
  