# A helper function to add / create an application.
#
# The function sets the CXX_STANDARD, VERSION and OUTPUT_NAME property of the
# application.
# Application target dependencies are also defined if specified.
#
# The include directory in the current source and binary directory are set as
# private. Private headers are added to the private HEADERS FILE_SET.
#
# CMake packaging version, configuration and installation is also set within
# the function.
#
# In order to configure the CMake packaging version it expects a
# ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${LIB_NAME}-config.cmake.in file to be
# present within the project.
#
# If the current source directory contains a app_name.h.in, it will be
# configured to a private header file.
#
# Arguments
# =========
#
# Options:
#   VERBOSE: print additional information on the arguments added to the
#            function
#
# Arguments with one value:
#   APP_NAME: name of the application [REQUIRED]
#   APP_CMAKE_NAMESPACE: CMake namespace  [REQUIRED]
#   CXX_STANDARD: specified which C++ features are required to build the
#                 application [defaults to C++20]
#   APP_VERSION: set the build version of the application [REQUIRED]
#   APP_OUTPUT_NAME: name of the application executable [default: APP_NAME]
#   APP_PRIVATE_INCLUDE_DIR: private include directory name used during the configuration of app_name.h.in [default: APP_NAME]
#
# Arguments with one or more values:
#   APP_PUBLIC_SOURCES: public sources of the application
#   APP_PRIVATE_SOURCES: private sources of the application [preferred]
#   APP_PUBLIC_LIBRARIES: public libraries (part of the API)
#   APP_PRIVATE_LIBRARIES: private libraries (not part of the API) [preferred]
#   APP_DEPENDENCIES: CMake dependencies of the application
#

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

function(add_app)
    set(options VERBOSE)
    set(oneValueArgs APP_NAME APP_CMAKE_NAMESPACE CXX_STANDARD APP_VERSION APP_OUTPUT_NAME APP_PRIVATE_INCLUDE_DIR)
    set(multiValueArgs APP_PUBLIC_SOURCES APP_PRIVATE_SOURCES APP_PUBLIC_LIBRARIES APP_PRIVATE_LIBRARIES APP_PRIVATE_HEADERS APP_DEPENDENCIES)
    cmake_parse_arguments(F "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    # One value arguments
    if (NOT DEFINED F_APP_NAME)
        message(FATAL_ERROR "APP_NAME is not defined")
    elseif ("${F_APP_NAME}" STREQUAL "")
        message(FATAL_ERROR "APP_NAME is empty")
    endif()

    if (NOT DEFINED F_APP_CMAKE_NAMESPACE)
        message(FATAL_ERROR "APP_CMAKE_NAMESPACE is not defined")
    elseif ("${F_APP_CMAKE_NAMESPACE}" STREQUAL "")
        message(FATAL_ERROR "APP_CMAKE_NAMESPACE is empty")
    endif()

    if (NOT DEFINED F_CXX_STANDARD)
        set(F_CXX_STANDARD 20)
    endif()

    if (NOT DEFINED F_APP_VERSION)
        message(FATAL_ERROR "APP_VERSION is not defined")
    elseif ("${F_APP_VERSION}" STREQUAL "")
        message(FATAL_ERROR "APP_VERSION is empty")
    endif()

    if (NOT DEFINED F_APP_OUTPUT_NAME)
        set(F_APP_OUTPUT_NAME ${F_APP_NAME})
    elseif("${F_APP_OUTPUT_NAME}" STREQUAL "")
        set(F_APP_OUTPUT_NAME ${F_APP_NAME})
    endif()

    if (NOT DEFINED F_APP_PRIVATE_INCLUDE_DIR)
        set(F_APP_PRIVATE_INCLUDE_DIR ${F_APP_NAME})
    elseif("${F_APP_PRIVATE_INCLUDE_DIR}" STREQUAL "")
        set(F_APP_PRIVATE_INCLUDE_DIR ${F_APP_NAME})
    endif()

    # Multi-value arguments
    if (NOT DEFINED F_APP_PUBLIC_SOURCES)
        set(F_APP_PUBLIC_SOURCES_LENGTH 0)
    else()
        list(LENGTH F_APP_PUBLIC_SOURCES F_APP_PUBLIC_SOURCES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_PRIVATE_SOURCES)
        set(F_APP_PRIVATE_SOURCES_LENGTH 0)
    else()
        list(LENGTH F_APP_PRIVATE_SOURCES F_APP_PRIVATE_SOURCES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_PUBLIC_LIBRARIES)
        set(F_APP_PUBLIC_LIBRARIES_LENGTH 0)
    else()
        list(LENGTH F_APP_PUBLIC_LIBRARIES F_APP_PUBLIC_LIBRARIES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_PRIVATE_LIBRARIES)
        set(F_APP_PRIVATE_LIBRARIES_LENGTH 0)
    else()
        list(LENGTH F_APP_PRIVATE_LIBRARIES F_APP_PRIVATE_LIBRARIES_LENGTH)
    endif ()

    if (NOT DEFINED F_APP_PRIVATE_HEADERS)
        set(F_APP_PRIVATE_HEADERS "")
    endif ()
    list(LENGTH F_APP_PRIVATE_HEADERS F_APP_PRIVATE_HEADERS_LENGTH)

    if (NOT DEFINED F_APP_DEPENDENCIES)
        set(F_APP_DEPENDENCIES_LENGTH 0)
    endif ()
    list(LENGTH F_APP_DEPENDENCIES F_APP_DEPENDENCIES_LENGTH)

    if(${F_VERBOSE})

        message(STATUS "Adding application: ${F_APP_NAME}")
        message("  Version: ${F_APP_VERSION}")
        message("  Output name: ${F_APP_OUTPUT_NAME}")
        message("  CMAKE namespace: ${F_APP_CMAKE_NAMESPACE}")
        message("  C++ standard: ${F_CXX_STANDARD}")
        message("  Private include dir: ${F_APP_PRIVATE_INCLUDE_DIR}")

        message("  Public sources: ")
        FOREACH(T IN LISTS F_APP_PUBLIC_SOURCES)
            message("    ${T}")
        ENDFOREACH()

        message("  Private sources: ")
        FOREACH(T IN LISTS F_APP_PRIVATE_SOURCES)
            message("    ${T}")
        ENDFOREACH()

        message("  Private headers: ")
        FOREACH(T IN LISTS F_APP_PRIVATE_HEADERS)
            message("    ${T}")
        ENDFOREACH()

        message("  Public libraries: ")
        FOREACH(T IN LISTS F_APP_PUBLIC_LIBRARIES)
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

    if (EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/app_name.h.in")
        configure_file("${CMAKE_CURRENT_SOURCE_DIR}/app_name.h.in" "${CMAKE_CURRENT_BINARY_DIR}/include/${F_APP_PRIVATE_INCLUDE_DIR}/app_name.h" @ONLY)
        list(APPEND F_APP_PRIVATE_HEADERS "${CMAKE_CURRENT_BINARY_DIR}/include/${F_APP_PRIVATE_INCLUDE_DIR}/app_name.h")
    endif ()
    list(LENGTH F_APP_PRIVATE_HEADERS F_APP_PRIVATE_HEADERS_LENGTH)

    add_executable(${F_APP_NAME})
    set_property(TARGET ${F_APP_NAME} PROPERTY CXX_STANDARD ${F_CXX_STANDARD})
    set_property(TARGET ${F_APP_NAME} PROPERTY VERSION ${F_APP_VERSION})
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

    if (${F_APP_PRIVATE_HEADERS_LENGTH} GREATER 0)
        target_sources(${F_APP_NAME}
            PRIVATE
            FILE_SET HEADERS
            BASE_DIRS
            ${CMAKE_CURRENT_SOURCE_DIR}/include
            ${CMAKE_CURRENT_BINARY_DIR}/include
            FILES
            ${F_APP_PRIVATE_HEADERS}
        )
    endif()

    if (${F_APP_PUBLIC_SOURCES_LENGTH} GREATER 0)
        target_sources(${F_APP_NAME} PUBLIC ${F_APP_PUBLIC_SOURCES})
    endif()

    if (${F_APP_PRIVATE_SOURCES_LENGTH} GREATER 0)
        target_sources("${F_APP_NAME}" PRIVATE ${F_APP_PRIVATE_SOURCES})
    endif()

    if (${F_APP_PUBLIC_LIBRARIES_LENGTH} GREATER 0)
        target_link_libraries("${F_APP_NAME}" PUBLIC ${F_APP_PUBLIC_LIBRARIES})
    endif ()


    if (${F_APP_PRIVATE_LIBRARIES_LENGTH} GREATER 0)
        target_link_libraries("${F_APP_NAME}" PRIVATE ${F_APP_PRIVATE_LIBRARIES})
    endif ()

    configure_package_config_file(
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${F_APP_NAME}-config.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_APP_NAME}-config.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_APP_NAME}
    )

    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_APP_NAME}-config-version.cmake
        VERSION ${F_APP_VERSION}
        COMPATIBILITY AnyNewerVersion
    )

    install(EXPORT ${F_APP_NAME}-targets
        FILE ${F_APP_NAME}-targets.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_APP_NAME}
        NAMESPACE ${F_APP_CMAKE_NAMESPACE}::
    )
    install(TARGETS ${F_APP_NAME}
        EXPORT ${F_APP_NAME}-targets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
    install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_APP_NAME}-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_APP_NAME}-config-version.cmake
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_APP_NAME}
    )

endfunction()