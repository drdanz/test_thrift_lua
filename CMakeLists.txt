################################################################################
#                                                                              #
# Copyright (C) 2019 Fondazione Istitito Italiano di Tecnologia (IIT)          #
# All Rights Reserved.                                                         #
#                                                                              #
################################################################################

cmake_minimum_required(VERSION 3.12)

# UseSWIG generates now standard target names.
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.13)
  cmake_policy(SET CMP0078 OLD)
endif()

# UseSWIG honors SWIG_MODULE_NAME via -module flag.
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL 3.14)
  cmake_policy(SET CMP0086 OLD)
endif()

project(test_thrift_lua)

set(BUILD_SHARED_LIBS ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(YARP 3.3 REQUIRED)
foreach(_component conf OS sig dev)
  get_property(YARP_${_component}_INCLUDE_DIRS TARGET YARP::YARP_${_component} PROPERTY INTERFACE_INCLUDE_DIRECTORIES)
  include_directories(${YARP_${_component}_INCLUDE_DIRS})
endforeach()
include_directories(${YARP_BINDINGS})

find_package(Lua REQUIRED)
set(_CMAKE_INSTALL_LUADIR "${CMAKE_INSTALL_LIBDIR}/lua/${LUA_VERSION_MAJOR}.${LUA_VERSION_MINOR}")
set(CMAKE_INSTALL_LUADIR ${_CMAKE_INSTALL_LUADIR} CACHE PATH "lua bindings (${_CMAKE_INSTALL_LUADIR})")
mark_as_advanced(CMAKE_INSTALL_LUADIR)
if(NOT IS_ABSOLUTE ${CMAKE_INSTALL_LUADIR})
  set(CMAKE_INSTALL_FULL_LUADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LUADIR}")
else()
  set(CMAKE_INSTALL_FULL_LUADIR "${CMAKE_INSTALL_LUADIR}")
endif()

find_package(SWIG 3.0 REQUIRED)
include(${SWIG_USE_FILE})



# Create the C++ Library
add_library(protocol STATIC)
yarp_add_idl(IDL_GEN_FILES GoTo.thrift)
target_sources(protocol PRIVATE ${IDL_GEN_FILES})
target_link_libraries(protocol YARP::YARP_OS)


# Create a server
add_executable(textGoToServer)
target_sources(textGoToServer PRIVATE TextGoToServer.cpp)
target_link_libraries(textGoToServer PRIVATE protocol YARP::YARP_OS YARP::YARP_init)


# Create a client
add_executable(GoToClient)
target_sources(GoToClient PRIVATE GoToClient.cpp)
target_link_libraries(GoToClient PRIVATE protocol YARP::YARP_OS YARP::YARP_init)


# Create the Lua
set(SWIG_BINDINGS_SOURCE_FILE GoTo.i)
set_source_files_properties(${SWIG_BINDINGS_SOURCE_FILE} PROPERTIES CPLUSPLUS ON)
set(CMAKE_SWIG_OUTDIR "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LUADIR}")
set(CMAKE_SWIG_FLAGS -module GoTo)

swig_add_library(GoTo_lua
                 LANGUAGE lua
                 SOURCES ${SWIG_BINDINGS_SOURCE_FILE})
swig_link_libraries(GoTo_lua PRIVATE ${LUA_LIBRARY} protocol YARP::YARP_OS YARP::YARP_sig YARP::YARP_dev)
target_include_directories(${SWIG_MODULE_GoTo_lua_REAL_NAME} SYSTEM PRIVATE ${LUA_INCLUDE_DIR})
set_target_properties(${SWIG_MODULE_GoTo_lua_REAL_NAME} PROPERTIES PREFIX ""
                                                                   OUTPUT_NAME "GoTo"
                                                                   LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LUADIR}")

# Update RPATH
# if(NOT CMAKE_SKIP_RPATH AND NOT CMAKE_SKIP_INSTALL_RPATH)
#   file(RELATIVE_PATH _rel_path "${CMAKE_INSTALL_FULL_LUADIR}" "${CMAKE_INSTALL_FULL_LIBDIR}")
#   get_target_property(_current_rpath "${SWIG_MODULE_yarp_lua_REAL_NAME}" INSTALL_RPATH)
#   if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
#     list(APPEND _current_rpath "@loader_path/${_rel_path}")
#   else()
#     list(APPEND _current_rpath "\$ORIGIN/${_rel_path}")
#   endif()
#   set_target_properties(${SWIG_MODULE_yarp_lua_REAL_NAME} PROPERTIES INSTALL_RPATH "${_current_rpath}")
# endif()

install(TARGETS ${SWIG_MODULE_GoTo_lua_REAL_NAME}
        DESTINATION ${CMAKE_INSTALL_LUADIR})
