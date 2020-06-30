if(NOT WITH_MICRODNF)
    return()
endif()

# use any sources found under the current directory
file(GLOB_RECURSE MICRODNF_SOURCES *.cpp)

add_executable(microdnf ${MICRODNF_SOURCES})

target_link_libraries(microdnf PUBLIC libdnf libdnf-cli)
install(TARGETS microdnf RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "microdnf")

set(CPACK_DEBIAN_MICRODNF_PACKAGE_NAME "microdnf")
set(CPACK_DEBIAN_MICRODNF_PACKAGE_DEPENDS "${CPACK_DEBIAN_LIB_PACKAGE_NAME},${CPACK_DEBIAN_LIB_CLI_PACKAGE_NAME}")
pass_through_cpack_vars()
