# runTest.cmake executes a command and captures the output in a file. File is then compared
# against a reference file. Exit status of command can also be compared.
cmake_policy(SET CMP0007 NEW)

# arguments checking
if (NOT TEST_PROGRAM)
  message (FATAL_ERROR "Require TEST_PROGRAM to be defined")
endif (NOT TEST_PROGRAM)
#if (NOT TEST_ARGS)
#  message (STATUS "Require TEST_ARGS to be defined")
#endif (NOT TEST_ARGS)
if (NOT TEST_FOLDER)
  message ( FATAL_ERROR "Require TEST_FOLDER to be defined")
endif (NOT TEST_FOLDER)
if (NOT TEST_OUTPUT)
  message (FATAL_ERROR "Require TEST_OUTPUT to be defined")
endif (NOT TEST_OUTPUT)
if (NOT TEST_EXPECT)
  message (STATUS "Require TEST_EXPECT to be defined")
endif (NOT TEST_EXPECT)
#if (NOT TEST_FILTER)
#  message (STATUS "Require TEST_FILTER to be defined")
#endif (NOT TEST_FILTER)
if (NOT TEST_SKIP_COMPARE AND NOT TEST_REFERENCE)
  message (FATAL_ERROR "Require TEST_REFERENCE to be defined")
endif (NOT TEST_SKIP_COMPARE AND NOT TEST_REFERENCE)

#if (NOT TEST_ERRREF)
#  set (ERROR_APPEND 1)
#endif (NOT TEST_ERRREF)

message (STATUS "COMMAND: ${TEST_PROGRAM} ${TEST_ARGS}")

if (NOT TEST_INPUT)
  # run the test program, capture the stdout/stderr and the result var
  execute_process (
      COMMAND ${TEST_PROGRAM} ${TEST_ARGS}
      WORKING_DIRECTORY ${TEST_FOLDER}
      RESULT_VARIABLE TEST_RESULT
      OUTPUT_FILE ${TEST_OUTPUT}
      ERROR_FILE ${TEST_OUTPUT}.err
      OUTPUT_VARIABLE TEST_OUT
      ERROR_VARIABLE TEST_ERROR
  )
else (NOT TEST_INPUT)
  # run the test program with stdin, capture the stdout/stderr and the result var
  execute_process (
      COMMAND ${TEST_PROGRAM} ${TEST_ARGS}
      WORKING_DIRECTORY ${TEST_FOLDER}
      RESULT_VARIABLE TEST_RESULT
      INPUT_FILE ${TEST_INPUT}
      OUTPUT_FILE ${TEST_OUTPUT}
      ERROR_FILE ${TEST_OUTPUT}.err
      OUTPUT_VARIABLE TEST_OUT
      ERROR_VARIABLE TEST_ERROR
  )
endif (NOT TEST_INPUT)

message (STATUS "COMMAND Result: ${TEST_RESULT}")

#if (ERROR_APPEND)
#  file (READ ${TEST_FOLDER}/${TEST_OUTPUT}.err TEST_STREAM)
#  file (APPEND ${TEST_FOLDER}/${TEST_OUTPUT} "${TEST_STREAM}") 
#endif (ERROR_APPEND)

if (TEST_APPEND)
  file (APPEND ${TEST_FOLDER}/${TEST_OUTPUT} "${TEST_APPEND} ${TEST_RESULT}\n")
endif (TEST_APPEND)

# if the return value is !=${TEST_EXPECT} bail out
if (NOT ${TEST_RESULT} STREQUAL ${TEST_EXPECT})
  message ( FATAL_ERROR "Failed: Test program ${TEST_PROGRAM} exited != ${TEST_EXPECT}.\n${TEST_ERROR}")
endif (NOT ${TEST_RESULT} STREQUAL ${TEST_EXPECT})

message (STATUS "COMMAND Error: ${TEST_ERROR}")

if (TEST_MASK)
  file (READ ${TEST_FOLDER}/${TEST_OUTPUT} TEST_STREAM)
   string (REGEX REPLACE "Storage:[^\n]+\n" "Storage:   <details removed for portability>\n" TEST_STREAM "${TEST_STREAM}")
  file (WRITE ${TEST_FOLDER}/${TEST_OUTPUT} "${TEST_STREAM}")
endif (TEST_MASK)

if (TEST_FILTER)
  file (READ ${TEST_FOLDER}/${TEST_OUTPUT} TEST_STREAM)
   string (REGEX REPLACE "${TEST_FILTER}" "" TEST_STREAM "${TEST_STREAM}")
  file (WRITE ${TEST_FOLDER}/${TEST_OUTPUT} "${TEST_STREAM}")
endif (TEST_FILTER)

if (WIN32 AND NOT MINGW)
  file (READ ${TEST_FOLDER}/${TEST_REFERENCE} TEST_STREAM)
  file (WRITE ${TEST_FOLDER}/${TEST_REFERENCE} "${TEST_STREAM}")
endif (WIN32 AND NOT MINGW)

# now compare the output with the reference
execute_process (
    COMMAND ${CMAKE_COMMAND} -E compare_files ${TEST_FOLDER}/${TEST_OUTPUT} ${TEST_FOLDER}/${TEST_REFERENCE}
    RESULT_VARIABLE TEST_RESULT
)

# again, if return value is !=0 scream and shout
if (TEST_RESULT)
  message (FATAL_ERROR "Failed: The output of ${TEST_PROGRAM} did not match ${TEST_REFERENCE}")
endif (TEST_RESULT)

# everything went fine...
message ("Passed: The output of ${TEST_PROGRAM} matches ${TEST_REFERENCE}")

