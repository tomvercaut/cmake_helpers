# A helper function to add / create a Catch2 (version 3) test application.
#
# The function sets the CXX_STANDARD and OUTPUT_NAME property of the
# test application.
# Application target dependencies are also defined if specified.
#
# The include directory in the current source and binary directory are set as
# private.
#
# Arguments
# =========
#
# Options:
#   VERBOSE: print additional information on the arguments added to the
#            function
#
# Arguments with one value:
#   APP_NAME: name of the test application [REQUIRED]
#   CXX_STANDARD: specified which C++ features are required to build the
#                 application [defaults to C++20]
#   APP_OUTPUT_NAME: name of the test application executable [default: APP_NAME]
#
# Arguments with one or more values:
#   APP_PRIVATE_SOURCES: private sources of the application [preferred]
#   APP_PRIVATE_LIBRARIES: private libraries (not part of the API) [preferred]
#   APP_DEPENDENCIES: CMake dependencies of the application
#

function(add_catch2v3_test)
    set(options VERBOSE)
    set(oneValueArgs APP_NAME CXX_STANDARD APP_OUTPUT_NAME)
    set(multiValueArgs APP_PRIVATE_SOURCES APP_PRIVATE_LIBRARIES APP_DEPENDENCIES)
    cmake_parse_arguments(F "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # One value arguments
    if (NOT DEFINED F_APP_NAME)
        message(FATAL_ERROR "APP_NAME is not defined")
    elseif ("${F_APP_NAME}" STREQUAL "")
        message(FATAL_ERROR "APP_NAME is empty")
    endif()

    if (NOT DEFINED F_CXX_STANDARD)
        set(F_CXX_STANDARD 20)
    endif()

    if (NOT DEFINED F_APP_OUTPUT_NAME)
        set(F_APP_OUTPUT_NAME ${F_APP_NAME})
    elseif("${F_APP_OUTPUT_NAME}" STREQUAL "")
        set(F_APP_OUTPUT_NAME ${F_APP_NAME})
    endif()

    # Multi-value arguments
    if (NOT DEFINED F_APP_PRIVATE_SOURCES)
        set(F_APP_PRIVATE_SOURCES_LENGTH 0)
    else()
        list(LENGTH F_APP_PRIVATE_SOURCES F_APP_PRIVATE_SOURCES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_PRIVATE_LIBRARIES)
        set(F_APP_PRIVATE_LIBRARIES_LENGTH 0)
    else()
        list(LENGTH F_APP_PRIVATE_LIBRARIES F_APP_PRIVATE_LIBRARIES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_DEPENDENCIES)
        set(F_APP_DEPENDENCIES_LENGTH 0)
    endif ()
    list(LENGTH F_APP_DEPENDENCIES F_APP_DEPENDENCIES_LENGTH)

    if(${F_VERBOSE})
        message(STATUS "Adding test application: ${F_APP_NAME}")
        message("  Output name: ${F_APP_OUTPUT_NAME}")
        message("  C++ standard: ${F_CXX_STANDARD}")

        message("  Private sources: ")
        FOREACH(T IN LISTS F_APP_PRIVATE_SOURCES)
            message("    ${T}")
        ENDFOREACH()

        message("  Private libraries: ")
        FOREACH(T IN LISTS F_APP_PRIVATE_LIBRARIES)
            message("    ${T}")
        ENDFOREACH()

        message("  Dependencies: ")
        FOREACH(T IN LISTS F_APP_DEPENDENCIES)
            message("    ${T}")
        ENDFOREACH()
    endif()

    add_executable(${F_APP_NAME})
    set_property(TARGET ${F_APP_NAME} PROPERTY CXX_STANDARD ${F_CXX_STANDARD})
    set_property(TARGET ${F_APP_NAME} PROPERTY OUTPUT_NAME ${F_APP_OUTPUT_NAME})
    if (${F_APP_DEPENDENCIES_LENGTH} GREATER 0)
        add_dependencies(${F_APP_NAME} ${F_APP_DEPENDENCIES})
    endif ()

    target_include_directories(${F_APP_NAME}
        PRIVATE
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
    )

    if (${F_APP_PRIVATE_SOURCES_LENGTH} GREATER 0)
        target_sources("${F_APP_NAME}" PRIVATE ${F_APP_PRIVATE_SOURCES})
    endif()

    if (${F_APP_PRIVATE_LIBRARIES_LENGTH} GREATER 0)
        target_link_libraries("${F_APP_NAME}" PRIVATE ${F_APP_PRIVATE_LIBRARIES})
    endif ()

    include(CTest)
    include(Catch)
    catch_discover_tests(${F_APP_NAME})
endfunction()
