cmake_minimum_required (VERSION 3.2.2)
project (HDF4Examples_JAVA_AN Java)

set (CMAKE_VERBOSE_MAKEFILE 1)

INCLUDE_DIRECTORIES (
    ${HDFJAVA_LIB_DIR}
    ${JAVA_INCLUDE_PATH}
    ${JAVA_INCLUDE_PATH2}
)

set (HDF_JAVA_EXAMPLES
    h4jex_AN_create_annotation
)

if (WIN32 AND NOT CYGWIN)
  set (CMAKE_JAVA_INCLUDE_FLAG_SEP ";")
else ()
  set (CMAKE_JAVA_INCLUDE_FLAG_SEP ":")
endif ()

set (CMAKE_JAVA_CLASSPATH ".")
foreach (CMAKE_INCLUDE_PATH ${CMAKE_JAVA_INCLUDE_PATH})
  set (CMAKE_JAVA_CLASSPATH "${CMAKE_JAVA_CLASSPATH}${CMAKE_JAVA_INCLUDE_FLAG_SEP}${CMAKE_INCLUDE_PATH}")
endforeach ()

foreach (HCP_JAR ${CMAKE_JAVA_INCLUDE_PATH})
  get_filename_component (_HCP_FILE ${HCP_JAR} NAME)
  set (HDFJAVA_CLASSJARS "${_HCP_FILE} ${HDFJAVA_CLASSJARS}")
endforeach ()

foreach (example ${HDF_JAVA_EXAMPLES})
  file (WRITE ${PROJECT_BINARY_DIR}/Manifest.txt
  "Main-Class: exAN.${example}
Class-Path: ${HDFJAVA_CLASSJARS}
"
  )
  ADD_JAR (${example} SOURCES ${example}.java MANIFEST ${PROJECT_BINARY_DIR}/Manifest.txt)
  get_target_property (${example}_JAR_FILE ${example} JAR_FILE)
endforeach ()

if (CMAKE_BUILD_TYPE MATCHES Debug)
  set (CMD_ARGS "-Dhdf.hdflib.HDFLibrary.loadLibraryName=hdf_java_debug;")
endif()

if (BUILD_TESTING)
  macro (ADD_H4_TEST resultfile resultcode)
    add_test (
        NAME jnative-h4-${resultfile}
        COMMAND "${CMAKE_COMMAND}"
            -D "TEST_TESTER=${CMAKE_Java_RUNTIME}"
            -D "TEST_PROGRAM=exAN.${resultfile}"
            -D "TEST_ARGS:STRING=${CMD_ARGS}${ARGN}"
            -D "TEST_CLASSPATH:STRING=${CMAKE_JAVA_CLASSPATH}${CMAKE_JAVA_INCLUDE_FLAG_SEP}${${resultfile}_JAR_FILE}"
            -D "TEST_LIBRARY_DIRECTORY=${HDF4_JAVA_LIBRARIES}"
            -D "TEST_FOLDER=${HDF4Examples_JAVA_AN_BINARY_DIR}"
            -D "TEST_OUTPUT=${HDF4Examples_JAVA_AN_BINARY_DIR}/${resultfile}.out"
            -D "TEST_REFERENCE=${resultfile}.txt"
            -D "TEST_EXPECT=${resultcode}"
            -D "TEST_SKIP_COMPARE=TRUE"
            -P "${HDF4EX_RESOURCES_DIR}/jrunTest.cmake"
    )
    if (NOT "${last_test}" STREQUAL "")
      set_tests_properties (jnative-h4-${resultfile} PROPERTIES DEPENDS ${last_test})
    endif ()
    set (last_test "jnative-h5-${resultfile}")
  endmacro ()

  foreach (example ${HDF_JAVA_EXAMPLES})
    add_test (
        NAME jnative-h4-${example}-clearall-objects
        COMMAND    ${CMAKE_COMMAND}
            -E remove
            ${HDF4Examples_JAVA_AN_DIR}/${example}.hdf
            ${example}.out
            ${example}.out.err
    )
    if (NOT "${last_test}" STREQUAL "")
      set_tests_properties (jnative-h4-${example}-clearall-objects PROPERTIES DEPENDS ${last_test})
    endif ()
    add_test (
        NAME jnative-h4-${example}-copy-objects
        COMMAND    ${CMAKE_COMMAND}
            -E copy_if_different
            ${HDF4Examples_JAVA_AN_SOURCE_DIR}/testfiles/${example}.txt
            ${HDF4Examples_JAVA_AN_BINARY_DIR}/${example}.txt
    )
    set_tests_properties (jnative-h4-${example}-copy-objects PROPERTIES DEPENDS jnative-h4-${example}-clearall-objects)
    set (last_test "jnative-h4-${example}-copy-objects")
    ADD_H4_TEST (${example} 0)
  endforeach ()

endif ()
