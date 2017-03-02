cmake_minimum_required (VERSION 3.2.2)
# --------------------------------------------------------------------
# Notes: When creating examples they should be prefixed
# with "f_ex_". This allows for easier filtering of the examples.
# --------------------------------------------------------------------
PROJECT (HDF4Examples_MFHDF_FORTRAN C CXX Fortran)

#-----------------------------------------------------------------------------
# Setup include Directories
#-----------------------------------------------------------------------------
INCLUDE_DIRECTORIES (
    ${CMAKE_Fortran_MODULE_DIRECTORY}
    ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
SET (examples
    h4ex_SD_create_sds
    h4ex_SD_write_to_sds
    h4ex_SD_write_slab
    h4ex_SD_alter_sds_values
    h4ex_SD_unlimited_sds
    h4ex_SD_mv_sds_to_external
    h4ex_SD_read_from_sds
    h4ex_SD_read_subsets
    #h4ex_SD_get_info
    h4ex_SD_find_sds_by_name
    h4ex_SD_set_get_dim_info
    #h4ex_SD_dimscale_vs_sds
    h4ex_SD_set_attr
    #h4ex_SD_get_attr
    h4ex_SD_compress_sds
    h4ex_SD_chunking_example
)
SET (skip_examples
    h4ex_SD_get_info
    h4ex_SD_dimscale_vs_sds
    h4ex_SD_get_attr
)

IF (BUILD_TESTING)
  # Remove any output file left over from previous test run
  ADD_TEST (
      NAME MFHDF_FORTRAN_EXAMPLES-clearall-objects
      COMMAND    ${CMAKE_COMMAND}
          -E remove
          SDS.hdf
          SDSchunked.hdf
          SDScompressed.hdf
          SDSUNLIMITED.hdf
          SLABS.hdf
  )
  IF (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (MFHDF_FORTRAN_EXAMPLES-clearall-objects PROPERTIES DEPENDS ${last_test} LABELS ${PROJECT_NAME})
  ELSE (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (MFHDF_FORTRAN_EXAMPLES-clearall-objects PROPERTIES LABELS ${PROJECT_NAME})
  ENDIF (NOT "${last_test}" STREQUAL "")
  SET (last_test "MFHDF_FORTRAN_EXAMPLES-clearall-objects")
ENDIF (BUILD_TESTING)

FOREACH (example ${examples})
  ADD_EXECUTABLE (f_exmf_${example} ${PROJECT_SOURCE_DIR}/${example}.f)
  TARGET_NAMING (f_exmf_${example} ${LIB_TYPE})
  TARGET_FORTRAN_WIN_PROPERTIES (f_exmf_${example} ${LIB_TYPE} "" "")
  SET_TARGET_PROPERTIES (f_exmf_${example} PROPERTIES LINKER_LANGUAGE Fortran)
  TARGET_LINK_LIBRARIES (f_exmf_${example} ${LINK_LIBS})
  IF (BUILD_TESTING)
    ADD_TEST (
        NAME f_exmftest_${example}
        COMMAND "${CMAKE_COMMAND}"
            -D "TEST_PROGRAM=$<TARGET_FILE:f_exmf_${example}>"
            -D "TEST_ARGS:STRING="
            -D "TEST_FOLDER=${PROJECT_BINARY_DIR}"
            -D "TEST_EXPECT=0"
            -D "TEST_SKIP_COMPARE=TRUE"
            -D "TEST_OUTPUT=${testname}.out"
            -D "TEST_LIBRARY_DIRECTORY=${CMAKE_TEST_LIB_DIRECTORY}"
            -P "${HDF4EX_RESOURCES_DIR}/runTest.cmake"
    )
    IF (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (f_exmftest_${example} PROPERTIES DEPENDS ${last_test} LABELS ${PROJECT_NAME})
    ELSE (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (f_exmftest_${example} PROPERTIES LABELS ${PROJECT_NAME})
    ENDIF (NOT "${last_test}" STREQUAL "")
    SET (last_test "f_exmftest_${example}")
  ENDIF (BUILD_TESTING)
ENDFOREACH (example ${examples})

FOREACH (example ${skip_examples})
  ADD_EXECUTABLE (f_exmf_${example} ${PROJECT_SOURCE_DIR}/${example}.f)
  TARGET_NAMING (f_exmf_${example} ${LIB_TYPE})
  TARGET_FORTRAN_WIN_PROPERTIES (f_exmf_${example} ${LIB_TYPE} "" "")
  SET_TARGET_PROPERTIES (f_exmf_${example} PROPERTIES LINKER_LANGUAGE Fortran)
  TARGET_LINK_LIBRARIES (f_exmf_${example} ${LINK_LIBS})
  IF (BUILD_TESTING)
    ADD_TEST (
        NAME f_exmftest_${example}
        COMMAND ${CMAKE_COMMAND} -E echo "SKIP f_exmftest_${example}"
    )
  ENDIF (BUILD_TESTING)
ENDFOREACH (example ${skip_examples})
