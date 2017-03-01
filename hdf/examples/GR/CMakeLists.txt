cmake_minimum_required (VERSION 3.2.2)
PROJECT (HDF4Examples_HDF_GR C CXX)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
SET (h4examples
    h4ex_GR_create_and_write_chunked_image
    h4ex_GR_create_and_write_image
    h4ex_GR_write_palette
)
SET (h4examples_use
    h4ex_GR_get_attribute
    h4ex_GR_image_info
    h4ex_GR_modify_image
    h4ex_GR_read_image
    h4ex_GR_read_palette
    h4ex_GR_set_attribute
)
SET (h4examples_files
    General_RImages.hdf
    General_RImages2.hdf
    General_RImages3.hdf
    General_RImages4.hdf
    Image_with_Palette.hdf
)

FOREACH (example ${h4examples})
  ADD_EXECUTABLE (hdf_${example} ${PROJECT_SOURCE_DIR}/${example}.c)
  TARGET_NAMING (hdf_${example} ${LIB_TYPE})
  TARGET_LINK_LIBRARIES (hdf_${example} ${LINK_LIBS})
ENDFOREACH (example ${h4examples})

FOREACH (example ${h4examples_use})
  ADD_EXECUTABLE (hdf_${example} ${PROJECT_SOURCE_DIR}/${example}.c)
  TARGET_NAMING (hdf_${example} ${LIB_TYPE})
  TARGET_LINK_LIBRARIES (hdf_${example} ${LINK_LIBS})
ENDFOREACH (example ${h4examples_use})

IF (BUILD_TESTING)
  MACRO (ADD_H4_TEST testname testcreate)
    ADD_TEST (
        NAME ${testname}-clearall
        COMMAND    ${CMAKE_COMMAND}
            -E remove
            ${testname}.out
            ${testname}.out.err
            ${testname}.ddl.out
            ${testname}.ddl.out.err
            ${testname}.hdf
    )
    ADD_TEST (
        NAME ${testname}
        COMMAND "${CMAKE_COMMAND}"
            -D "TEST_PROGRAM=$<TARGET_FILE:hdf_${testname}>"
            -D "TEST_ARGS:STRING="
            -D "TEST_FOLDER=${PROJECT_BINARY_DIR}"
            -D "TEST_EXPECT=0"
            -D "TEST_OUTPUT=${testname}.out"
            -D "TEST_REFERENCE=${testname}.tst"
            -P "${HDF4EX_RESOURCES_DIR}/runTest.cmake"
    )
    SET_TESTS_PROPERTIES(${testname} PROPERTIES DEPENDS ${testname}-clearall)
    IF (HDF4_BUILD_TOOLS AND ${testcreate} STREQUAL "1")
      ADD_TEST (
          NAME ${testname}-HDP
          COMMAND "${CMAKE_COMMAND}"
              -D "TEST_PROGRAM=$<TARGET_FILE:hdf4::hdp>"
              -D "TEST_ARGS:STRING=${ARGN};${testname}.hdf"
              -D "TEST_FOLDER=${PROJECT_BINARY_DIR}"
              -D "TEST_OUTPUT=${testname}.ddl.out"
              -D "TEST_EXPECT=0"
              -D "TEST_REFERENCE=${testname}.ddl"
              -P "${HDF4EX_RESOURCES_DIR}/runTest.cmake"
      )
      SET_TESTS_PROPERTIES(${testname}-HDP PROPERTIES DEPENDS ${testname})
    ENDIF (HDF4_BUILD_TOOLS AND ${testcreate} STREQUAL "1")
  ENDMACRO (ADD_H4_TEST)

  FOREACH (example ${h4examples})
    SET (testsrc "${PROJECT_SOURCE_DIR}/testfiles/${example}")
    SET (testdest "${PROJECT_BINARY_DIR}/${example}")
    ADD_CUSTOM_COMMAND (
        OUTPUT     "${testdest}.tst"
        COMMAND    ${CMAKE_COMMAND}
        ARGS       -E copy_if_different "${testsrc}.tst" "${testdest}.tst"
        DEPENDS    "${testsrc}.tst"
    )
    list(APPEND HDF4Examples_HDF_GR_TEST_FILES "${testdest}.tst")
    IF (HDF4_BUILD_TOOLS)
      ADD_CUSTOM_COMMAND (
          OUTPUT     "${testdest}.ddl"
          COMMAND    ${CMAKE_COMMAND}
          ARGS       -E copy_if_different "${testsrc}.ddl" "${testdest}.ddl"
          DEPENDS    "${testsrc}.ddl"
      )
      list(APPEND HDF4Examples_HDF_GR_TEST_FILES "${testdest}.ddl")
    ENDIF (HDF4_BUILD_TOOLS)
  ENDFOREACH (example ${h4examples})

  FOREACH (example ${h4examples_use})
    SET (testsrc "${PROJECT_SOURCE_DIR}/testfiles/${example}")
    SET (testdest "${PROJECT_BINARY_DIR}/${example}")
    ADD_CUSTOM_COMMAND (
        OUTPUT     "${testdest}.tst"
        COMMAND    ${CMAKE_COMMAND}
        ARGS       -E copy_if_different "${testsrc}.tst" "${testdest}.tst"
        DEPENDS    "${testsrc}.tst"
    )
    list(APPEND HDF4Examples_HDF_GR_TEST_FILES "${testdest}.tst")
  ENDFOREACH (example ${h4examples_use})

  FOREACH (ex_file ${h4examples_files})
    SET (testsrc "${PROJECT_SOURCE_DIR}/testfiles/${ex_file}")
    SET (testdest "${PROJECT_BINARY_DIR}/${ex_file}")
    ADD_CUSTOM_COMMAND (
        OUTPUT     "${testdest}"
        COMMAND    ${CMAKE_COMMAND}
        ARGS       -E copy_if_different "${testsrc}" "${testdest}"
        DEPENDS    "${testsrc}"
    )
    list(APPEND HDF4Examples_HDF_GR_TEST_FILES "${testdest}")
  ENDFOREACH (ex_file ${h4examples_files})

  add_custom_target(HDF4Examples_HDF_GR-files ALL COMMENT "Copying files needed by GR tests"
                    DEPENDS ${HDF4Examples_HDF_GR_TEST_FILES})

  FOREACH (example ${h4examples})
    ADD_H4_TEST (${example} 1 dumpvg)
  ENDFOREACH (example ${h4examples})

  FOREACH (example ${h4examples_use})
    ADD_H4_TEST (${example} 0 dumpvg)
  ENDFOREACH (example ${h4examples_use})
ENDIF (BUILD_TESTING)
