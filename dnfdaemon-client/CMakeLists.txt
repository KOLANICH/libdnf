if(NOT WITH_DNFDAEMON_CLIENT)
    return()
endif()


file(GLOB_RECURSE DNFDAEMON_CLIENT_SOURCES *.cpp)
add_executable(dnfdaemon-client main.cpp ${DNFDAEMON_CLIENT_SOURCES})
target_link_libraries(dnfdaemon-client PUBLIC libdnf libdnf-cli)
install(TARGETS dnfdaemon-client RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR} COMPONENT "daemon_client")

set(CPACK_DEBIAN_DAEMON_CLIENT_PACKAGE_NAME "dnfdaemon-client")
set(CPACK_DEBIAN_DAEMON_CLIENT_PACKAGE_DEPENDS "${CPACK_DEBIAN_LIB_PACKAGE_NAME},${CPACK_DEBIAN_LIB_CLI_PACKAGE_NAME}")
pass_through_cpack_vars()
