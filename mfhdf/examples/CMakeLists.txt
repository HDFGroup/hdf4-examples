cmake_minimum_required (VERSION 2.8.6)
PROJECT (HDF4Examples_MFHDF)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
SET (examples
    SD_create_sds
    SD_write_to_sds
    SD_write_slab
    SD_alter_sds_values
    SD_unlimited_sds
    SD_compress_sds
    SD_mv_sds_to_external
    SD_read_from_sds
    SD_read_subsets
    SD_get_info
    SD_find_sds_by_name
    SD_set_get_dim_info
    SD_dimscale_vs_sds
    SD_set_attr
    SD_get_attr
    SD_chunking_example
)

IF (BUILD_TESTING)
  # Remove any output file left over from previous test run
  ADD_TEST (
      NAME MFHDF_EXAMPLES-clearall-objects
      COMMAND    ${CMAKE_COMMAND}
          -E remove 
          SDS.hdf
          SDSchunked.hdf
          SDScompressed.hdf
          SDSUNLIMITED.hdf
          SLABS.hdf
          ExternalSDS
  )
  IF (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (MFHDF_EXAMPLES-clearall-objects PROPERTIES DEPENDS ${last_test} LABELS ${PROJECT_NAME})
  ELSE (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (MFHDF_EXAMPLES-clearall-objects PROPERTIES LABELS ${PROJECT_NAME})
  ENDIF (NOT "${last_test}" STREQUAL "")
  SET (last_test "MFHDF_EXAMPLES-clearall-objects")
ENDIF (BUILD_TESTING)

FOREACH (example ${examples})
  ADD_EXECUTABLE (mf_${example} ${PROJECT_SOURCE_DIR}/${example}.c)
  TARGET_NAMING (mf_${example} ${LIB_TYPE})
  TARGET_LINK_LIBRARIES (mf_${example} ${LINK_LIBS})
  IF (BUILD_TESTING)
    ADD_TEST (NAME mftest_${example} COMMAND $<TARGET_FILE:mf_${example}>)
    IF (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (mftest_${example} PROPERTIES DEPENDS ${last_test} LABELS ${PROJECT_NAME})
    ELSE (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (mftest_${example} PROPERTIES LABELS ${PROJECT_NAME})
    ENDIF (NOT "${last_test}" STREQUAL "")
    SET (last_test "mftest_${example}")
  ENDIF (BUILD_TESTING)
ENDFOREACH (example ${examples})
