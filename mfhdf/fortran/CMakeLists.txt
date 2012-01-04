cmake_minimum_required (VERSION 2.8.6)
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
    SD_create_sds 
    SD_write_to_sds 
    SD_write_slab 
    SD_alter_sds_values 
    SD_unlimited_sds
    SD_mv_sds_to_external 
    SD_read_from_sds 
    SD_read_subsets 
    #SD_get_info
    SD_find_sds_by_name 
    SD_set_get_dim_info 
    #SD_dimscale_vs_sds 
    SD_set_attr
    #SD_get_attr 
    SD_compress_sds 
    SD_chunking_example
)
SET (skip_examples
    SD_get_info
    SD_dimscale_vs_sds 
    SD_get_attr 
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
ENDIF (BUILD_TESTING)

FOREACH (example ${examples})
  ADD_EXECUTABLE (f_exmf_${example} ${PROJECT_SOURCE_DIR}/${example}.f)
  TARGET_NAMING (f_exmf_${example} ${LIB_TYPE})
  TARGET_FORTRAN_WIN_PROPERTIES (f_exmf_${example} "")
  SET_TARGET_PROPERTIES (f_exmf_${example} PROPERTIES LINKER_LANGUAGE Fortran)
  TARGET_LINK_LIBRARIES (f_exmf_${example} ${LINK_LIBS})
  IF (BUILD_TESTING)
    ADD_TEST (NAME f_exmftest_${example} COMMAND $<TARGET_FILE:f_exmf_${example}>)
    IF (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (f_exmftest_${example} PROPERTIES DEPENDS ${last_test} LABELS ${PROJECT_NAME})
    ELSE (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (f_exmftest_${example} PROPERTIES LABELS ${PROJECT_NAME})
    ENDIF (NOT "${last_test}" STREQUAL "")
  ENDIF (BUILD_TESTING)
ENDFOREACH (example ${examples})

FOREACH (example ${skip_examples})
  ADD_EXECUTABLE (f_exmf_${example} ${PROJECT_SOURCE_DIR}/${example}.f)
  TARGET_NAMING (f_exmf_${example} ${LIB_TYPE})
  TARGET_FORTRAN_WIN_PROPERTIES (f_exmf_${example} "")
  SET_TARGET_PROPERTIES (f_exmf_${example} PROPERTIES LINKER_LANGUAGE Fortran)
  TARGET_LINK_LIBRARIES (f_exmf_${example} ${LINK_LIBS})
  IF (BUILD_TESTING)
    ADD_TEST (NAME f_exmftest_${example} COMMAND ${CMAKE_COMMAND} -E echo "SKIP f_exmftest_${example}")
  ENDIF (BUILD_TESTING)
ENDFOREACH (example ${skip_examples})
