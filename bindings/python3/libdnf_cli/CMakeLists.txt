if(NOT WITH_LIBDNF_CLI)
    return()
endif()


message("Building bindings for python3: libdnf_cli")

set(INIT_FILE "${CMAKE_CURRENT_BINARY_DIR}/__init__.py")
file(REMOVE "${INIT_FILE}")
foreach(MODULE_NAME ${SWIG_LIBDNF_CLI_MODULES})
    add_python3_module(libdnf_cli ${MODULE_NAME})
    file(APPEND "${INIT_FILE}" "from . import ${MODULE_NAME}\n")
endforeach()


install(FILES "${INIT_FILE}"DESTINATION ${Python_SITEARCH}/libdnf_cli COMPONENT "python${Python_VERSION_MAJOR}_libdnf_cli")

set(LIB_CPACK_NAME "PYTHON${Python_VERSION_MAJOR}_LIBDNF_CLI")
set("CPACK_DEBIAN_${LIB_CPACK_NAME}_PACKAGE_NAME" "python${Python_VERSION_MAJOR}-${CPACK_DEBIAN_LIB_CLI_PACKAGE_NAME}" PARENT_SCOPE)
set("CPACK_DEBIAN_${LIB_CPACK_NAME}_PACKAGE_DEPENDS" "libpython${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} (>=${Python_VERSION}~), python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} (>=${Python_VERSION}~), ${CPACK_DEBIAN_LIB_CLI_PACKAGE_NAME}" PARENT_SCOPE)
