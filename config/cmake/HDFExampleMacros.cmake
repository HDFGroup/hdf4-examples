#-------------------------------------------------------------------------------
macro (BASIC_SETTINGS varname)
  string(TOUPPER ${varname} EXAMPLE_PACKAGE_VARNAME)
  string(TOLOWER ${varname} EXAMPLE_VARNAME)
  set (H4${EXAMPLE_PACKAGE_VARNAME}_PACKAGE "h4${EXAMPLE_VARNAME}")
  set (H4${EXAMPLE_PACKAGE_VARNAME}_PACKAGE_NAME "h4${EXAMPLE_VARNAME}")
  string(TOUPPER ${H4${EXAMPLE_PACKAGE_VARNAME}_PACKAGE_NAME} EXAMPLE_PACKAGE_NAME)
  string(TOLOWER ${H4${EXAMPLE_PACKAGE_VARNAME}_PACKAGE_NAME} EXAMPLE_NAME)
  set (CMAKE_NO_SYSTEM_FROM_IMPORTED 1)

  #-----------------------------------------------------------------------------
  # Define some CMake variables for use later in the project
  #-----------------------------------------------------------------------------
  set (${EXAMPLE_PACKAGE_NAME}_RESOURCES_DIR           ${${EXAMPLE_PACKAGE_NAME}_SOURCE_DIR}/config/cmake)
  set (${EXAMPLE_PACKAGE_NAME}_SRC_DIR                 ${${EXAMPLE_PACKAGE_NAME}_SOURCE_DIR}/src)

  #-----------------------------------------------------------------------------
  # Setup output Directories
  #-----------------------------------------------------------------------------
  if (NOT ${EXAMPLE_PACKAGE_NAME}_EXTERNALLY_CONFIGURED)
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
    get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
    if(_isMultiConfig)
      set (CMAKE_TEST_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${CMAKE_BUILD_TYPE})
      set (CMAKE_PDB_OUTPUT_DIRECTORY
          ${PROJECT_BINARY_DIR}/bin CACHE PATH "Single Directory for all pdb files."
      )
    else ()
      set (CMAKE_TEST_OUTPUT_DIRECTORY ${CMAKE_RUNTIME_OUTPUT_DIRECTORY})
    endif ()
  else ()
    # if we are externally configured, but the project uses old cmake scripts
    # this may not be set
    if (NOT CMAKE_RUNTIME_OUTPUT_DIRECTORY)
      set (CMAKE_RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    endif ()
  endif ()

  #-----------------------------------------------------------------------------
  # Option to use Shared/Static libs, default is static
  #-----------------------------------------------------------------------------
  set (LIB_TYPE STATIC)
  if (BUILD_SHARED_LIBS)
    set (LIB_TYPE SHARED)
  endif ()
  set (CMAKE_POSITION_INDEPENDENT_CODE ON)

  if (MSVC)
    set (CMAKE_MFC_FLAG 0)
  endif ()

  set (MAKE_SYSTEM)
  if (CMAKE_BUILD_TOOL MATCHES "make")
    set (MAKE_SYSTEM 1)
  endif ()

  set (CFG_INIT "/${CMAKE_CFG_INTDIR}")
  if (MAKE_SYSTEM)
    set (CFG_INIT "")
  endif ()

  set(CMAKE_C_STANDARD 99)
  set(CMAKE_C_STANDARD_REQUIRED TRUE)

  set(CMAKE_CXX_STANDARD 98)
  set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
  set(CMAKE_CXX_EXTENSIONS OFF)

  #-----------------------------------------------------------------------------
  # Compiler specific flags : Shouldn't there be compiler tests for these
  #-----------------------------------------------------------------------------
  if (CMAKE_COMPILER_IS_GNUCC)
    set (CMAKE_C_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_C_FLAGS} -std=c99 -fomit-frame-pointer -finline-functions -fno-common")
  endif ()
  if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_CXX_FLAGS "${CMAKE_ANSI_CFLAGS} ${CMAKE_CXX_FLAGS} -fomit-frame-pointer -finline-functions -fno-common")
  endif ()

  #-----------------------------------------------------------------------------
  # This is in here to help some of the GCC based IDES like Eclipse
  # and code blocks parse the compiler errors and warnings better.
  #-----------------------------------------------------------------------------
  if (CMAKE_COMPILER_IS_GNUCC)
    set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fmessage-length=0")
  endif ()
  if (CMAKE_COMPILER_IS_GNUCXX)
    set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fmessage-length=0")
  endif ()

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
    endif ()
    if (WIN32)
      add_definitions (-D_CRT_SECURE_NO_WARNINGS)
    endif ()
    # Borland uses -w- to suppress warnings.
    if (BORLAND)
     set (HDF_WARNINGS_BLOCKED 1)
      set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w-")
    endif ()

    # Most compilers use -w to suppress warnings.
    if (NOT HDF_WARNINGS_BLOCKED)
      set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -w")
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -w")
    endif ()
  endif ()

  #-----------------------------------------------------------------------------
  # Set includes needed for build
  #-----------------------------------------------------------------------------
  set (${EXAMPLE_PACKAGE_NAME}_INCLUDES_BUILD_TIME
      ${${EXAMPLE_PACKAGE_NAME}_SRC_DIR} ${${EXAMPLE_PACKAGE_NAME}_BINARY_DIR}
  )

  #-----------------------------------------------------------------------------
  # Option to build JAVA examples
  #-----------------------------------------------------------------------------
  option (HDF_BUILD_JAVA "Build JAVA support" OFF)
  if (HDF_BUILD_JAVA)
    find_package (Java)
    INCLUDE_DIRECTORIES (
        ${JAVA_INCLUDE_PATH}
        ${JAVA_INCLUDE_PATH2}
    )

    include (${${EXAMPLE_PACKAGE_NAME}_RESOURCES_DIR}/UseJava.cmake)
  endif ()
endmacro ()

macro (HDF4_SUPPORT)
  set (CMAKE_MODULE_PATH ${${EXAMPLE_PACKAGE_NAME}_RESOURCES_DIR} ${CMAKE_MODULE_PATH})
  option (USE_SHARED_LIBS "Use Shared Libraries" ON)

  if (NOT HDF4_HDF4_HEADER)
    if (USE_SHARED_LIBS)
      set (FIND_HDF_COMPONENTS C shared)
    else ()
      set (FIND_HDF_COMPONENTS C static)
    endif ()
    if (HDF_BUILD_FORTRAN)
      set (FIND_HDF_COMPONENTS ${FIND_HDF_COMPONENTS} Fortran)
    endif ()
    if (HDF_BUILD_JAVA)
      set (FIND_HDF_COMPONENTS ${FIND_HDF_COMPONENTS} Java)
    endif ()
    message (STATUS "HDF4 find comps: ${FIND_HDF_COMPONENTS}")
    set (SEARCH_PACKAGE_NAME ${HDF4_PACKAGE_NAME})

    find_package (HDF4 NAMES ${SEARCH_PACKAGE_NAME} COMPONENTS ${FIND_HDF_COMPONENTS})
    message (STATUS "HDF4 C libs:${HDF4_FOUND} static:${HDF4_static_C_FOUND} and shared:${HDF4_shared_C_FOUND}")
    message (STATUS "HDF4 Fortran libs: static:${HDF4_static_Fortran_FOUND} and shared:${HDF4_shared_Fortran_FOUND}")
    message (STATUS "HDF4 Java libs: ${HDF4_Java_FOUND}")
    if (HDF4_FOUND)
      if (USE_SHARED_LIBS)
        if (NOT TARGET ${HDF4_NAMESPACE}hdp-shared)
          add_executable (${HDF4_NAMESPACE}hdp-shared IMPORTED)
        endif ()
        set (HDF4_DUMP_EXECUTABLE $<TARGET_FILE:${HDF4_NAMESPACE}hdp-shared>)
      else ()
        if (NOT TARGET ${HDF4_NAMESPACE}hdp)
          add_executable (${HDF4_NAMESPACE}hdp IMPORTED)
        endif()
        set (HDF4_DUMP_EXECUTABLE $<TARGET_FILE:${HDF4_NAMESPACE}hdp>)
      endif()

      if (NOT HDF4_static_C_FOUND AND NOT HDF4_shared_C_FOUND)
        #find library from non-dual-binary package
        set (FIND_HDF_COMPONENTS C)
        if (HDF_BUILD_FORTRAN)
          set (FIND_HDF_COMPONENTS ${FIND_HDF_COMPONENTS} Fortran)
        endif ()
        if (HDF_BUILD_JAVA)
          set (FIND_HDF_COMPONENTS ${FIND_HDF_COMPONENTS} Java)
        endif ()
        message (STATUS "HDF4 find comps: ${FIND_HDF_COMPONENTS}")

        find_package (HDF4 NAMES ${SEARCH_PACKAGE_NAME} COMPONENTS ${FIND_HDF_COMPONENTS})
        message (STATUS "HDF4 libs:${HDF4_FOUND} C:${HDF4_C_FOUND} Fortran:${HDF4_Fortran_FOUND} Java:${HDF4_Java_FOUND}")
        set (LINK_LIBS ${LINK_LIBS} ${HDF4_LIBRARIES})
        if (HDF4_BUILD_SHARED_LIBS)
          add_definitions (-DH4_BUILT_AS_DYNAMIC_LIB)
        else ()
          add_definitions (-DH4_BUILT_AS_STATIC_LIB)
        endif ()
        if (USE_SHARED_LIBS AND WIN32)
          set_property (TARGET ${HDF4_NAMESPACE}hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdpdll")
        else ()
          set_property (TARGET ${HDF4_NAMESPACE}hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdp")
        endif ()
        if (HDF_BUILD_JAVA)
          set (CMAKE_JAVA_INCLUDE_PATH "${CMAKE_JAVA_INCLUDE_PATH};${HDF4_JAVA_INCLUDE_DIRS}")
          message (STATUS "HDF4 jars:${HDF5_JAVA_INCLUDE_DIRS}")
        endif ()
        set (HDF4_DUMP_EXECUTABLE $<TARGET_FILE:${HDF4_NAMESPACE}hdp>)
      else ()
        if (USE_SHARED_LIBS AND HDF4_shared_C_FOUND)
          set (LINK_LIBS ${LINK_LIBS} ${HDF4_C_SHARED_LIBRARY})
          set (HDF4_LIBRARY_PATH ${PACKAGE_PREFIX_DIR}/lib)
          set_property (TARGET ${HDF4_NAMESPACE}hdp-shared PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdp-shared")
        else ()
          set (LINK_LIBS ${LINK_LIBS} ${HDF4_C_STATIC_LIBRARY})
          set_property (TARGET ${HDF4_NAMESPACE}hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdp")
        endif ()
        if (HDF_BUILD_FORTRAN AND ${HDF4_BUILD_FORTRAN})
          if (BUILD_SHARED_LIBS AND HDF4_shared_Fortran_FOUND)
            set (LINK_LIBS ${LINK_LIBS} ${HDF4_FORTRAN_SHARED_LIBRARY})
          elseif (HDF4_static_Fortran_FOUND)
            set (LINK_LIBS ${LINK_LIBS} ${HDF4_FORTRAN_STATIC_LIBRARY})
          else ()
            set (HDF_BUILD_FORTRAN OFF CACHE BOOL "Build FORTRAN support" FORCE)
            message (STATUS "HDF4 Fortran libs not found - disable build of Fortran examples")
          endif ()
        else ()
          set (HDF_BUILD_FORTRAN OFF CACHE BOOL "Build FORTRAN support" FORCE)
          message (STATUS "HDF4 Fortran libs not found - disable build of Fortran examples")
        endif ()
        if (HDF_BUILD_JAVA)
          if (${HDF4_BUILD_JAVA} AND HDF4_Java_FOUND)
            set (CMAKE_JAVA_INCLUDE_PATH "${CMAKE_JAVA_INCLUDE_PATH};${HDF4_JAVA_INCLUDE_DIRS}")
            message (STATUS "HDF4 jars:${HDF4_JAVA_INCLUDE_DIRS}}")
          else ()
            set (HDF_BUILD_JAVA OFF CACHE BOOL "Build Java support" FORCE)
            message (STATUS "HDF4 Java libs not found - disable build of Java examples")
          endif ()
        else ()
          set (HDF_BUILD_JAVA OFF CACHE BOOL "Build Java support" FORCE)
        endif ()
      endif ()
    else ()
      find_package (HDF4) # Legacy find
      #Legacy find_package does not set HDF4_TOOLS_DIR, so we set it here
      set(HDF4_TOOLS_DIR ${HDF4_LIBRARY_DIRS}/../bin)
      #Legacy find_package does not set HDF4_BUILD_SHARED_LIBS, so we set it here
      if (USE_SHARED_LIBS AND EXISTS "${HDF4_LIBRARY_DIRS}/libhdf4.so")
        set (HDF4_BUILD_SHARED_LIBS 1)
      else ()
        set (HDF4_BUILD_SHARED_LIBS 0)
      endif ()
      set (LINK_LIBS ${LINK_LIBS} ${HDF4_LIBRARIES})
      add_executable (${HDF4_NAMESPACE}hdp IMPORTED)
      set_property (TARGET ${HDF4_NAMESPACE}hdp PROPERTY IMPORTED_LOCATION "${HDF4_TOOLS_DIR}/hdp")
      set (HDF4_DUMP_EXECUTABLE $<TARGET_FILE:${HDF4_NAMESPACE}hdp>)
    endif ()

    set (HDF4_PACKAGE_NAME ${SEARCH_PACKAGE_NAME})

    if (HDF4_FOUND)
      set (HDF4_HAVE_HDF_H 1)
      set (HDF4_HAVE_HDF4 1)
      set (HDF4_HDF4_HEADER "hdf.h")
      set (HDF4_INCLUDE_DIR_GEN ${HDF4_INCLUDE_DIR})
      set (HDF4_INCLUDE_DIRS ${HDF4_INCLUDE_DIR})
      message (STATUS "HDF4-${HDF4_VERSION_STRING} found: INC=${HDF4_INCLUDE_DIR} TOOLS=${HDF4_TOOLS_DIR}")
    else ()
      message (FATAL_ERROR " HDF4 is Required for HDF4 Examples")
    endif ()
  else ()
    # This project is being called from within another and HDF4 is already configured
    set (HDF4_HAVE_HDF_H 1)
    set (HDF4_HAVE_HDF4 1)
    set (LINK_LIBS ${LINK_LIBS} ${HDF4_LINK_LIBS})
  endif ()
  set (H4EX_INCLUDE_DIRS ${HDF4_INCLUDE_DIR})
  if (HDF_BUILD_FORTRAN)
    list (APPEND H5EX_INCLUDE_DIRS ${HDF4_INCLUDE_DIR_FORTRAN})
  endif ()
  message (STATUS "HDF4 link libs: ${HDF4_LINK_LIBS} Includes: ${H4EX_INCLUDE_DIRS}")

  if (USE_SHARED_LIBS)
    set (H4_LIB_TYPE SHARED)
  else ()
    set (H4_LIB_TYPE STATIC)
  endif ()
endmacro ()
#-------------------------------------------------------------------------------
macro (SET_HDF_BUILD_TYPE)
  get_property(_isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(_isMultiConfig)
    set(HDF_CFG_NAME ${CMAKE_BUILD_TYPE})
    set(HDF_BUILD_TYPE ${CMAKE_CFG_INTDIR})
    set(HDF_CFG_BUILD_TYPE \${CMAKE_INSTALL_CONFIG_NAME})
  else()
    set(HDF_CFG_BUILD_TYPE ".")
    if(CMAKE_BUILD_TYPE)
      set(HDF_CFG_NAME ${CMAKE_BUILD_TYPE})
      set(HDF_BUILD_TYPE ${CMAKE_BUILD_TYPE})
    else()
      set(HDF_CFG_NAME "Release")
      set(HDF_BUILD_TYPE "Release")
    endif()
  endif()
  if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.15.0")
      message (VERBOSE "Setting build type to 'RelWithDebInfo' as none was specified.")
    endif()
    set(CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING "Choose the type of build." FORCE)
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release"
      "MinSizeRel" "RelWithDebInfo")
  endif()
endmacro ()

#-------------------------------------------------------------------------------
macro (TARGET_C_PROPERTIES wintarget libtype)
  target_compile_options(${wintarget} PRIVATE
      $<$<C_COMPILER_ID:MSVC>:${WIN_COMPILE_FLAGS}>
      $<$<CXX_COMPILER_ID:MSVC>:${WIN_COMPILE_FLAGS}>
  )
  if(MSVC)
    set_property(TARGET ${wintarget} APPEND PROPERTY LINK_FLAGS "${WIN_LINK_FLAGS}")
  endif()
endmacro ()

macro (HDFTEST_COPY_FILE src dest target)
    add_custom_command(
        OUTPUT  "${dest}"
        COMMAND "${CMAKE_COMMAND}"
        ARGS     -E copy_if_different "${src}" "${dest}"
        DEPENDS "${src}"
    )
    list (APPEND ${target}_list "${dest}")
endmacro ()

macro (ADD_H4_FLAGS h4_flag_var infile)
  file (STRINGS ${infile} TEST_FLAG_STREAM)
  #message (TRACE "TEST_FLAG_STREAM=${TEST_FLAG_STREAM}")
  list (LENGTH TEST_FLAG_STREAM len_flag)
  if (len_flag GREATER 0)
    math (EXPR _FP_LEN "${len_flag} - 1")
    foreach (line RANGE 0 ${_FP_LEN})
      list (GET TEST_FLAG_STREAM ${line} str_flag)
      string (REGEX REPLACE "^#.*" "" str_flag "${str_flag}")
      #message (TRACE "str_flag=${str_flag}")
      if (str_flag)
        list (APPEND ${h4_flag_var} "${str_flag}")
      endif ()
    endforeach ()
  endif ()
  #message (TRACE "h4_flag_var=${${h4_flag_var}}")
endmacro ()
