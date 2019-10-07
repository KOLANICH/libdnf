set(LIBDNF_SRCS
    dnf-advisorypkg.cpp
    dnf-advisoryref.cpp
    dnf-advisory.cpp
    hy-goal.cpp
    hy-iutil.cpp
    log.cpp
    nevra.cpp
    nsvcap.cpp
    dnf-reldep.cpp
    dnf-reldep-list.cpp
    hy-package.cpp
    hy-packageset.cpp
    hy-query.cpp
    dnf-sack.cpp
    hy-selector.cpp
    hy-subject.cpp
    hy-util.cpp
    dnf-db.cpp
    dnf-context.cpp
    dnf-goal.cpp
    dnf-keyring.cpp
    dnf-lock.cpp
    dnf-package.cpp
    dnf-packagedelta.cpp
    dnf-repo-loader.cpp
    dnf-rpmts.cpp
    dnf-repo.cpp
    dnf-state.cpp
    dnf-transaction.cpp
    dnf-utils.cpp
)

include_directories(transaction)
add_subdirectory("transaction")

configure_file("config.h.in" ${CMAKE_CURRENT_SOURCE_DIR}/config.h)
configure_file("dnf-version.h.in"  ${CMAKE_CURRENT_SOURCE_DIR}/dnf-version.h)
configure_file("libdnf.pc.in" ${CMAKE_CURRENT_BINARY_DIR}/libdnf.pc @ONLY)

add_subdirectory(goal)
add_subdirectory(repo)
add_subdirectory(module)
add_subdirectory(utils)
add_subdirectory(conf)
add_subdirectory(sack)
add_subdirectory(plugin)

set(LIBDNF_SRCS ${LIBDNF_SRCS} ${GOAL_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${MODULE_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${UTILS_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${CONF_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${SACK_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${REPO_SOURCES})
set(LIBDNF_SRCS ${LIBDNF_SRCS} ${PLUGIN_SOURCES})

add_library(libdnf SHARED ${LIBDNF_SRCS})
target_link_libraries(libdnf
    ${CMAKE_DL_LIBS}
    ${REPO_LIBRARIES}
    ${GLIB_LIBRARIES}
    ${GLIB_GOBJECT_LIBRARIES}
    ${GLIB_GIO_LIBRARIES}
    ${GLIB_GIO_UNIX_LIBRARIES}
    ${LibSolv_LIBRARIES}
    ${LibSolvExt_LIBRARIES}
    ${OPENSSL_CRYPTO_LIBRARY}
    ${RPM_LIBRARIES}
    ${SCOLS_LIBRARIES}
    ${SQLite3_LIBRARIES}
    ${JSONC_LIBRARIES}
    ${LIBMODULEMD_LIBRARIES}
    ${SMARTCOLS_LIBRARIES}
    ${GPGME_VANILLA_LIBRARIES}
)

if(ENABLE_RHSM_SUPPORT)
    target_link_libraries(libdnf ${RHSM_LIBRARIES})
endif()

set(DNF_SO_VERSION 2)
set_target_properties(libdnf PROPERTIES OUTPUT_NAME "dnf")
set_target_properties(libdnf PROPERTIES SOVERSION ${DNF_SO_VERSION})

set(LIBHAWKEY_headers
    hy-goal.h
    hy-nevra.h
    hy-package.h
    hy-packageset.h
    hy-query.h
    hy-repo.h
    hy-selector.h
    hy-subject.h
    hy-types.h
    hy-util.h
)

set(LIBDNF_headers
    config.h
    log.hpp
    nevra.hpp
    nsvcap.hpp
    dnf-advisory.h
    dnf-advisorypkg.h
    dnf-advisoryref.h
    dnf-db.h
    dnf-context.h
    dnf-enums.h
    dnf-goal.h
    dnf-keyring.h
    dnf-lock.h
    dnf-package.h
    dnf-packagedelta.h
    dnf-repo-loader.h
    dnf-rpmts.h
    dnf-sack.h
    dnf-reldep.h
    dnf-reldep-list.h
    dnf-repo.h
    dnf-state.h
    dnf-transaction.h
    dnf-types.h
    dnf-utils.h
    dnf-version.h
    libdnf.h
)

message(STATUS "Building for python${PYTHON_VERSION_MAJOR}")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/libdnf.pc
    DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR}/pkgconfig
    COMPONENT "dev"
)
install(FILES ${LIBDNF_headers} DESTINATION include/libdnf COMPONENT "dev")
install(FILES ${LIBHAWKEY_headers} DESTINATION include/libdnf COMPONENT "libhawkey_dev")
install(TARGETS libdnf LIBRARY DESTINATION ${CMAKE_INSTALL_FULL_LIBDIR} COMPONENT "lib")
install(FILES "README.plugins" DESTINATION "${CMAKE_INSTALL_FULL_LIBDIR}/libdnf/plugins" RENAME "README" COMPONENT "lib")

set(CPACK_DEBIAN_LIB_PACKAGE_NAME "libdnf")
set(CPACK_DEBIAN_DEV_PACKAGE_NAME "${CPACK_DEBIAN_LIB_PACKAGE_NAME}-dev")
set(CPACK_DEBIAN_LIBHAWKEY_DEV_PACKAGE_NAME "libhawkey-dev")

set(CPACK_DEBIAN_LIB_PACKAGE_DEPENDS "libglib${GLIB_VERSION_MAJOR}.0-0 (>=${GLIB_VERSION}~);libgpgme${GPGME_VERSION_MAJOR}1 (>=${GPGME_VERSION}~);libssl${LIBCRYPTO_VERSION_MAJOR}.${LIBCRYPTO_VERSION_MINOR} (>=${OPENSSL_VERSION}~);libjson-c4 (>=${JSONC_VERSION}~);librpm8 (>=${RPM_VERSION}~);librepo (>=${REPO_VERSION});libsolv${LibSolv_VERSION_MAJOR} (>=${LibSolv_VERSION}~);libsolvext${LibSolvExt_VERSION_MAJOR} (>=${LibSolvExt_VERSION}~);libsqlite${SQLite3_VERSION_MAJOR}-0 (>=${SQLite3_VERSION}~);libmodulemd${LIBMODULEMD_VERSION_MAJOR} (>=${LIBMODULEMD_VERSION}~);libsmartcols1 (>=${SMARTCOLS_VERSION_MAJOR}.${SMARTCOLS_VERSION_MINOR}~)")

set(CPACK_DEBIAN_LIBHAWKEY_DEV_DEPENDS "${CPACK_DEBIAN_DEV_PACKAGE_NAME}")

set(CPACK_DEBIAN_DEV_PACKAGE_DEPENDS "libglib${GLIB_VERSION_MAJOR}.0-dev (>=${GLIB_VERSION}~);libsolv${LibSolv_VERSION_MAJOR}-dev (>=${LibSolv_VERSION}~);libsolvext${LibSolvExt_VERSION_MAJOR}-dev (>=${LibSolvExt_VERSION}~);librpm-dev (>=${RPM_VERSION}~);${CPACK_DEBIAN_LIB_PACKAGE_NAME}")

list(JOIN CPACK_DEBIAN_DEV_PACKAGE_DEPENDS ", " CPACK_DEBIAN_DEV_PACKAGE_DEPENDS)

if(ENABLE_RHSM_SUPPORT)
	list(APPEND CPACK_DEBIAN_LIB_PACKAGE_DEPENDS "librhsm (>=${RHSM_VERSION}~)")
endif()

if(WITH_ZCHUNK)
	list(APPEND CPACK_DEBIAN_LIB_PACKAGE_DEPENDS "libzchunk (>=${ZCHUNKLIB_VERSION}~)")
endif()

list(JOIN CPACK_DEBIAN_LIB_PACKAGE_DEPENDS ", " CPACK_DEBIAN_LIB_PACKAGE_DEPENDS)

pass_through_cpack_vars()