# A helper function to add / create a library.
#
# The function sets the CXX_STANDARD and VERSION property of the library.
# It also defined the public and private FILE_SET and libraries.
#
# CMake packaging version, configuration and installation is also set within
# the function.
# In order to configure the CMake packaging version it expects a
# ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${LIB_NAME}-config.cmake.in file to be
# present within the project.
#
#
#
# Arguments
# =========
#
# Options:
#   VERBOSE: print additional information on the arguments added to the
#            function
#
# Arguments with one value:
#   LIB_NAME: name of the library [REQUIRED]
#   LIB_CMAKE_NAMESPACE: CMake namespace  [REQUIRED]
#   LIB_ALIAS_NAME: alias for the library name [REQUIRED]
#   CXX_STANDARD: specified which C++ features are required to build the
#                 library [defaults to C++20]
#   LIB_VERSION: set the build version of the library
#
# Arguments with one or more values:
#   LIB_PUBLIC_HEADERS: public headers of the library (part of the API)
#   LIB_PRIVATE_SOURCES: private sources of the library (not part of the API)
#   LIB_PUBLIC_LIBRARIES: public libraries (part of the API)
#   LIB_PRIVATE_LIBRARIES: private libraries (not part of the API)
#   LIB_PRIVATE_HEADERS: private headers (not part of the API)
#

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

function(add_lib)
    set(options VERBOSE)
    set(oneValueArgs LIB_NAME LIB_CMAKE_NAMESPACE LIB_ALIAS_NAME CXX_STANDARD LIB_VERSION)
    set(multiValueArgs LIB_PUBLIC_HEADERS LIB_PRIVATE_SOURCES LIB_PUBLIC_LIBRARIES LIB_PRIVATE_LIBRARIES LIB_PRIVATE_HEADERS)
    cmake_parse_arguments(F "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT DEFINED F_LIB_NAME)
        message(FATAL_ERROR "LIB_NAME is not defined")
    elseif ("${F_LIB_NAME}" STREQUAL "")
        message(FATAL_ERROR "LIB_NAME is empty")
    endif ()

    if (NOT DEFINED F_LIB_CMAKE_NAMESPACE)
        message(FATAL_ERROR "LIB_CMAKE_NAMESPACE is not defined")
    elseif ("${F_LIB_CMAKE_NAMESPACE}" STREQUAL "")
        message(FATAL_ERROR "LIB_CMAKE_NAMESPACE is empty")
    endif ()

    if (NOT DEFINED F_LIB_ALIAS_NAME)
        message(FATAL_ERROR "LIB_ALIAS_NAME is not defined")
    elseif ("${F_LIB_ALIAS_NAME}" STREQUAL "")
        message(FATAL_ERROR "LIB_ALIAS_NAME is empty")
    endif ()

    if (NOT DEFINED F_CXX_STANDARD)
        set(F_CXX_STANDARD 20)
    endif ()

    if (NOT DEFINED F_LIB_VERSION)
        message(FATAL_ERROR "LIB_VERSION is not defined")
    elseif ("${F_LIB_VERSION}" STREQUAL "")
        message(FATAL_ERROR "LIB_VERSION is empty")
    endif ()

    if (NOT DEFINED F_LIB_PUBLIC_HEADERS)
        set(F_LIB_PUBLIC_HEADERS_LENGTH 0)
    else ()
        list(LENGTH F_LIB_PUBLIC_HEADERS F_LIB_PUBLIC_HEADERS_LENGTH)
    endif ()

    if (NOT DEFINED F_LIB_PRIVATE_SOURCES)
        set(F_LIB_PRIVATE_SOURCES_LENGTH 0)
    else ()
        list(LENGTH F_LIB_PRIVATE_SOURCES F_LIB_PRIVATE_SOURCES_LENGTH)
    endif ()

    if (NOT DEFINED F_LIB_PUBLIC_LIBRARIES)
        set(F_LIB_PUBLIC_LIBRARIES_LENGTH 0)
    else ()
        list(LENGTH F_LIB_PUBLIC_LIBRARIES F_LIB_PUBLIC_LIBRARIES_LENGTH)
    endif ()

    if (NOT DEFINED F_LIB_PRIVATE_LIBRARIES)
        set(F_LIB_PRIVATE_LIBRARIES_LENGTH 0)
    else ()
        list(LENGTH F_LIB_PRIVATE_LIBRARIES F_LIB_PRIVATE_LIBRARIES_LENGTH)
    endif ()

    if (NOT DEFINED F_LIB_PRIVATE_HEADERS)
        set(F_LIB_PRIVATE_HEADERS "")
    endif ()
    list(LENGTH F_LIB_PRIVATE_HEADERS F_LIB_PRIVATE_HEADERS_LENGTH)


    if (${F_VERBOSE})
        message(STATUS "Adding library: ${F_LIB_NAME}")
        message("  Version: ${F_LIB_VERSION}")
        message("  CMAKE namespace: ${F_LIB_CMAKE_NAMESPACE}")
        message("  Alias: ${F_LIB_ALIAS_NAME}")
        message("  C++ standard: ${F_CXX_STANDARD}")
        message("  Private include dir: ${F_LIB_PRIVATE_INCLUDE_DIR}")

        message("  Public headers: ")
        FOREACH (T IN LISTS F_LIB_PUBLIC_HEADERS)
            message("    ${T}")
        ENDFOREACH ()

        message("  Private sources: ")
        FOREACH (T IN LISTS F_LIB_PRIVATE_SOURCES)
            message("    ${T}")
        ENDFOREACH ()

        message("  Private headers: ")
        FOREACH (T IN LISTS F_LIB_PRIVATE_HEADERS)
            message("    ${T}")
        ENDFOREACH ()

        message("  Public libraries: ")
        FOREACH (T IN LISTS F_LIB_PUBLIC_LIBRARIES)
            message("    ${T}")
        ENDFOREACH ()

        message("  Private libraries: ")
        FOREACH (T IN LISTS F_LIB_PRIVATE_LIBRARIES)
            message("    ${T}")
        ENDFOREACH ()
    endif ()

    add_library("${F_LIB_NAME}")
    add_library("${F_LIB_CMAKE_NAMESPACE}::${F_LIB_ALIAS_NAME}" ALIAS "${F_LIB_NAME}")
    set_property(TARGET "${F_LIB_NAME}" PROPERTY CXX_STANDARD ${F_CXX_STANDARD})
    set_property(TARGET "${F_LIB_NAME}" PROPERTY VERSION ${F_LIB_VERSION})

    target_include_directories("${F_LIB_NAME}"
            PUBLIC
            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
            $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
            )

    if (${F_LIB_PUBLIC_HEADERS_LENGTH} GREATER 0)
        target_sources("${F_LIB_NAME}"
                PUBLIC
                FILE_SET HEADERS
                BASE_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/include
                FILES
                ${F_LIB_PUBLIC_HEADERS}
                )
    endif ()

    if (${F_LIB_PRIVATE_HEADERS_LENGTH} GREATER 0)
        target_sources(${F_LIB_NAME}
                PRIVATE
                FILE_SET HEADERS
                BASE_DIRS
                ${CMAKE_CURRENT_SOURCE_DIR}/include
                FILES
                ${F_LIB_PRIVATE_HEADERS}
                )
    endif ()

    if (${F_LIB_PRIVATE_SOURCES_LENGTH} GREATER 0)
        target_sources("${F_LIB_NAME}" PRIVATE ${F_LIB_PRIVATE_SOURCES})
    endif ()

    if (${F_LIB_PUBLIC_LIBRARIES_LENGTH} GREATER 0)
        target_link_libraries("${F_LIB_NAME}" PUBLIC ${F_LIB_PUBLIC_LIBRARIES})
    endif ()


    if (${F_LIB_PRIVATE_LIBRARIES_LENGTH} GREATER 0)
        target_link_libraries("${F_LIB_NAME}" PRIVATE ${F_LIB_PRIVATE_LIBRARIES})
    endif ()

    configure_package_config_file(
            ${CMAKE_CURRENT_SOURCE_DIR}/cmake/${F_LIB_NAME}-config.cmake.in
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_LIB_NAME}-config.cmake
            INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_LIB_NAME}
    )

    write_basic_package_version_file(
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_LIB_NAME}-config-version.cmake
            VERSION ${F_LIB_VERSION}
            COMPATIBILITY AnyNewerVersion
    )

    write_basic_package_version_file(
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_LIB_NAME}-config-version.cmake
            VERSION ${F_LIB_VERSION}
            COMPATIBILITY AnyNewerVersion
    )

    install(EXPORT ${F_LIB_NAME}-targets
            FILE ${F_LIB_NAME}-targets.cmake
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_LIB_NAME}
            NAMESPACE ${F_LIB_CMAKE_NAMESPACE}::
            )
    install(TARGETS ${F_LIB_NAME}
            EXPORT ${F_LIB_NAME}-targets
            RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
            LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
            ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            FILE_SET HEADERS
            )
    install(FILES
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_LIB_NAME}-config.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/cmake/${F_LIB_NAME}-config-version.cmake
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${F_LIB_NAME}
            )

endfunction()