message("Building bindings for python3: libdnf")

set(INIT_FILE "${CMAKE_CURRENT_BINARY_DIR}/__init__.py")
file(REMOVE "${INIT_FILE}")
foreach(MODULE_NAME ${SWIG_LIBDNF_MODULES})
    add_python3_module(libdnf ${MODULE_NAME})
    file(APPEND "${INIT_FILE}" "from . import ${MODULE_NAME}\n")
endforeach()


install(FILES "${INIT_FILE}" DESTINATION ${Python_SITEARCH}/libdnf COMPONENT "python${Python_VERSION_MAJOR}_libdnf")


set(LIB_CPACK_NAME "PYTHON${Python_VERSION_MAJOR}_LIBDNF")
set("CPACK_DEBIAN_${LIB_CPACK_NAME}_PACKAGE_NAME" "python${Python_VERSION_MAJOR}-${CPACK_DEBIAN_LIB_PACKAGE_NAME}" PARENT_SCOPE)
set("CPACK_DEBIAN_${LIB_CPACK_NAME}_PACKAGE_DEPENDS" "libpython${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} (>=${Python_VERSION}~), python${Python_VERSION_MAJOR}.${Python_VERSION_MINOR} (>=${Python_VERSION}~), ${CPACK_DEBIAN_LIB_PACKAGE_NAME}" PARENT_SCOPE)
