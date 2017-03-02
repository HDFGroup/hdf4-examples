cmake_minimum_required (VERSION 3.2.2)
PROJECT (HDF4Examples_HDF_VG C CXX)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
SET (h4examples
    h4ex_VG_add_sds_to_vgroup
    h4ex_VG_create_vgroup
)
SET (h4examples_use
    h4ex_VG_get_vgroup_info
    h4ex_VG_insert_vdatas_to_vgroup
    #h4ex_VG_set_get_vgroup_attr
    h4ex_VG_vgroup_contents
)
SET (h4examples_files
    General_Vgroups.hdf
    General_Vgroups2.hdf
    General_Vgroups3.hdf
    General_Vgroups4.hdf
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
            -D "TEST_LIBRARY_DIRECTORY=${CMAKE_TEST_LIB_DIRECTORY}"
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
              -D "TEST_LIBRARY_DIRECTORY=${CMAKE_TEST_LIB_DIRECTORY}"
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
    list(APPEND HDF4Examples_HDF_VG_TEST_FILES "${testdest}.tst")
    IF (HDF4_BUILD_TOOLS)
      ADD_CUSTOM_COMMAND (
          OUTPUT     "${testdest}.ddl"
          COMMAND    ${CMAKE_COMMAND}
          ARGS       -E copy_if_different "${testsrc}.ddl" "${testdest}.ddl"
          DEPENDS    "${testsrc}.ddl"
      )
      list(APPEND HDF4Examples_HDF_VG_TEST_FILES "${testdest}.ddl")
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
    list(APPEND HDF4Examples_HDF_VG_TEST_FILES "${testdest}.tst")
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
    list(APPEND HDF4Examples_HDF_VG_TEST_FILES "${testdest}")
  ENDFOREACH (ex_file ${h4examples_files})

  add_custom_target(HDF4Examples_HDF_VG-files ALL COMMENT "Copying files needed by VG tests"
                    DEPENDS ${HDF4Examples_HDF_VG_TEST_FILES})

  FOREACH (example ${h4examples})
    ADD_H4_TEST (${example} 1 dumpvg)
  ENDFOREACH (example ${h4examples})

  FOREACH (example ${h4examples_use})
    ADD_H4_TEST (${example} 0 dumpvg)
  ENDFOREACH (example ${h4examples_use})
ENDIF (BUILD_TESTING)
