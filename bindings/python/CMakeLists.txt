find_package(Python COMPONENTS Interpreter Development)
find_package(SWIG REQUIRED)

cmake_policy(SET CMP0078 OLD)
cmake_policy(SET CMP0086 OLD)
include(UseSWIG)

message(STATUS "Building for python${PYTHON_VERSION_MAJOR}")


include_directories(${CMAKE_SOURCE_DIR})
include_directories(${Python_INCLUDE_DIRS})

if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # using 64bit architecture
    set(CMAKE_SWIG_FLAGS "-DSWIGWORDSIZE64")
endif()

# The libdnf API is under development now. This enables it for internal usage.
set(CMAKE_SWIG_FLAGS ${CMAKE_SWIG_FLAGS} "-DLIBDNF_UNSTABLE_API")

function(libdnf_swig_module name)
    set(source ../swig/${name}.i)
    set_source_files_properties(${source} PROPERTIES CPLUSPLUS ON)
    swig_add_module(${name} python ${source})

    foreach(lib ${ARGN})
        swig_link_libraries(${name} ${lib})
    endforeach()

    install(TARGETS _${name} LIBRARY DESTINATION ${Python_STDARCH}/libdnf)
    install(FILES ${CMAKE_BINARY_DIR}/bindings/python/${name}.py DESTINATION ${Python_STDARCH}/libdnf  COMPONENT "python${PYTHON_VERSION_MAJOR}")
endfunction()

libdnf_swig_module(error libdnf ${Python_LIBRARIES})
libdnf_swig_module(common_types libdnf ${Python_LIBRARIES})
libdnf_swig_module(conf libdnf ${Python_LIBRARIES})
libdnf_swig_module(module libdnf ${Python_LIBRARIES})
libdnf_swig_module(repo libdnf ${Python_LIBRARIES})
libdnf_swig_module(smartcols libdnf ${Python_LIBRARIES})
libdnf_swig_module(transaction libdnf ${Python_LIBRARIES})
libdnf_swig_module(utils libdnf ${Python_LIBRARIES} ${SQLite3_LIBRARIES})

configure_file(__init__.py ${CMAKE_CURRENT_BINARY_DIR}/__init__.py COPYONLY)
install(FILES __init__.py DESTINATION ${Python_STDARCH}/libdnf COMPONENT "python${PYTHON_VERSION_MAJOR}")

if(${PYTHON_VERSION_MAJOR} GREATER_EQUAL "3")
	set("CPACK_DEBIAN_PYTHON${PYTHON_VERSION_MAJOR}_PACKAGE_NAME" "python${PYTHON_VERSION_MAJOR}-libdnf" PARENT_SCOPE)
else()
	set("CPACK_DEBIAN_PYTHON${PYTHON_VERSION_MAJOR}_PACKAGE_NAME" "python-libdnf" PARENT_SCOPE)
endif()

set("CPACK_DEBIAN_PYTHON${PYTHON_VERSION_MAJOR}_DEPENDS" "libpython${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} (>=${PYTHON_VERSION_STRING}~), python${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} (>=${PYTHON_VERSION_STRING}~), ${CPACK_DEBIAN_LIB_PACKAGE_NAME}" PARENT_SCOPE)
