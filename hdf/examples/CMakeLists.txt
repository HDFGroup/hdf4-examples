cmake_minimum_required (VERSION 2.8.10)
PROJECT (HDF4Examples_HDF C CXX)

#-----------------------------------------------------------------------------
# Define Sources
#-----------------------------------------------------------------------------
ADD_SUBDIRECTORY (${PROJECT_SOURCE_DIR}/AN   ${PROJECT_BINARY_DIR}/AN)
SET (examples
    h4ex_VD_create_vdatas 
    h4ex_VD_write_mixed_vdata
    h4ex_VD_write_mixed_vdata_struct 
    h4ex_VD_write_to_vdata
    h4ex_VD_read_from_vdata 
    h4ex_VD_read_mixed_vdata
    h4ex_VD_set_get_vdata_attr 
    h4ex_VD_create_onefield_vdatas
    h4ex_VD_get_vdata_info 
    h4ex_VD_locate_vdata 
    h4ex_VG_create_vgroup
#    h4ex_VG_add_sds_to_vgroup 
    h4ex_VG_insert_vdatas_to_vgroup
    h4ex_VG_set_get_vgroup_attr 
    h4ex_VG_vgroup_contents
    h4ex_VG_get_vgroup_info 
    h4ex_GR_create_and_write_image
    h4ex_GR_create_and_write_chunked_image
    h4ex_GR_modify_image 
    h4ex_GR_set_attribute 
    h4ex_GR_get_attribute
    h4ex_GR_write_palette 
    h4ex_GR_image_info 
    h4ex_GR_read_image
)

FOREACH (example ${examples})
  ADD_EXECUTABLE (hdf_${example} ${PROJECT_SOURCE_DIR}/${example}.c)
  TARGET_NAMING (hdf_${example} ${LIB_TYPE})
  TARGET_LINK_LIBRARIES (hdf_${example} ${LINK_LIBS})
ENDFOREACH (example ${examples})

ADD_EXECUTABLE (hdf_h4ex_VG_add_sds_to_vgroup ${PROJECT_SOURCE_DIR}/h4ex_VG_add_sds_to_vgroup.c)
TARGET_NAMING (hdf_h4ex_VG_add_sds_to_vgroup ${LIB_TYPE})
TARGET_LINK_LIBRARIES (hdf_h4ex_VG_add_sds_to_vgroup ${LINK_LIBS})

IF (BUILD_TESTING)
  # Remove any output file left over from previous test run
  ADD_TEST (
      NAME HDF_EXAMPLES-clearall-objects
      COMMAND    ${CMAKE_COMMAND}
          -E remove 
          General_Rimages.hdf
          General_Vdatas.hdf
          General_Vgroups.hdf
          Image_with_Palette.hdf
          Packed_Vdata.hdf
          Two_Vdatas.hdf
          Two_Vgroups.hdf
  )
  IF (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (HDF_EXAMPLES-clearall-objects PROPERTIES DEPENDS ${last_test} LABELS EXAMPLES)
  ELSE (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (HDF_EXAMPLES-clearall-objects PROPERTIES LABELS EXAMPLES)
  ENDIF (NOT "${last_test}" STREQUAL "")
  SET (last_test "HDF_EXAMPLES-clearall-objects")

  FOREACH (example ${examples})
    ADD_TEST (NAME hdftest_${example} COMMAND $<TARGET_FILE:hdf_${example}>)
    IF (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (hdftest_${example} PROPERTIES DEPENDS ${last_test} LABELS EXAMPLES)
    ELSE (NOT "${last_test}" STREQUAL "")
      SET_TESTS_PROPERTIES (hdftest_${example} PROPERTIES LABELS EXAMPLES)
    ENDIF (NOT "${last_test}" STREQUAL "")
    SET (last_test "hdftest_${example}")
  ENDFOREACH (example ${examples})

  ADD_TEST (NAME hdftest_h4ex_VG_add_sds_to_vgroup COMMAND $<TARGET_FILE:hdf_h4ex_VG_add_sds_to_vgroup>)
  IF (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (hdftest_h4ex_VG_add_sds_to_vgroup PROPERTIES DEPENDS ${last_test} LABELS EXAMPLES)
  ELSE (NOT "${last_test}" STREQUAL "")
    SET_TESTS_PROPERTIES (hdftest_h4ex_VG_add_sds_to_vgroup PROPERTIES LABELS EXAMPLES)
  ENDIF (NOT "${last_test}" STREQUAL "")
  SET (last_test "hdftest_h4ex_VG_add_sds_to_vgroup")
ENDIF (BUILD_TESTING)
