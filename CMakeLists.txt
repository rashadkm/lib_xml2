################################################################################
# Project:  Lib XML2
# Purpose:  CMake build scripts
# Author:   Dmitry Baryshnikov, dmitry.baryshnikov@nexgis.com
################################################################################
# Copyright (C) 2015, NextGIS <info@nextgis.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
################################################################################

cmake_minimum_required(VERSION 2.8.10 FATAL_ERROR)

project(xml2 C)

# some init settings
set(CMAKE_COLOR_MAKEFILE ON)
# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE PATH "Installation directory for executables")
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE PATH "Installation directory for libraries")
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE PATH "Installation directory for headers")

set(VERSION "2.9.3")
set(LIBXML_VERSION_NUMBER 20903)
set(LIBXML_VERSION_EXTRA "-GITCVE-2015-8242")

option(WITH_TRIO "Enable TRIO string manipulator" OFF)
option(WITH_THREADS "Add multithread support" ON)
option(WITH_THREAD_ALLOC "add per-thread memory" OFF)
option(WITH_TREE "Enable tree api" ON)
option(WITH_OUTPUT "Enable serialization support" ON)
option(WITH_PUSH "Enable push api" ON)
option(WITH_READER "Enable xmlReader api" ON)
option(WITH_PATTERN "Enable xmlPattern api" ON)
option(WITH_WRITER "Enable xmlWriter api" ON)
option(WITH_SAX1 "Enable SAX1 api" ON)
option(WITH_FTP "Enable FTP client" ON)
option(WITH_HTTP "Enable HTTP client" ON)
option(WITH_VALID "Enable DTD validation support" ON)
option(WITH_HTML "Add the HTML support" ON)
option(WITH_LEGACY "Enable deprecated APIs" ON)
option(WITH_C14N "Enable C14N support" ON)
option(WITH_CATALOG "Enable catalog support" ON)
option(WITH_DOCB "Enable DocBook support" ON)
option(WITH_XPATH "Enable XPath support" ON)
option(WITH_XPTR "Enable XPointer support" ON)
option(WITH_XINCLUDE "Enable XInclude support" ON)
option(WITH_ICU "Add ICU support" OFF)
option(WITH_ISO8859X "Enable iso8859x support" ON)
option(WITH_DEBUG "add the debugging module" ON)
option(WITH_MEM_DEBUG "add the memory debugging module" OFF)
option(WITH_RUN_DEBUG "add the runtime debugging module" OFF)
option(WITH_REGEXPS "Enable regular expressions" ON)
option(WITH_SCHEMAS "Enable XML Schema support" ON)
option(WITH_SCHEMATRON "Add Schematron support" ON)
option(WITH_MODULES "Add the dynamic modules support" ON)
option(WITH_WALKER "Enable xmlDocWalker api" ON)
option(WITH_PYTHON "Build Python bindings" OFF)

if(UNIX)
    set(MODULE_EXTENSION ".so")
elseif(WIN32)
    set(MODULE_EXTENSION ".dll")
    set(THREADS_W32 TRUE)
    add_definitions(-DHAVE_WIN32_THREADS -DWIN32)
    list(APPEND TARGET_LINK_LIB Ws2_32.lib Secur32.lib)
endif()        


include(find_anyproject)

if(WITH_THREADS)
  find_package(Threads REQUIRED)
  list(APPEND TARGET_LINK_LIB ${CMAKE_THREAD_LIBS_INIT})
endif()

find_anyproject(ZLIB)
find_anyproject(ICONV)
find_anyproject(LZMA)

configure_file(${CMAKE_MODULE_PATH}/xmlversion.h.in ${CMAKE_CURRENT_BINARY_DIR}/libxml/xmlversion.h IMMEDIATE @ONLY )
configure_file(${CMAKE_MODULE_PATH}/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)
configure_file(${CMAKE_MODULE_PATH}/xml2-config.in ${CMAKE_CURRENT_BINARY_DIR}/xml2-config IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )

set(PUBLIC_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/libxml/xmlversion.h
)

set(PRIVATE_HDRS

)

set(SRCS

)


message(STATUS "libxml2 version ${VERSION}")    

if(BUILD_SHARED_LIBS)
    set(LIB_NAME xml2)
    add_library(${LIB_NAME} SHARED ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES DEFINE_SYMBOL XML2_DLL)
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
else()    
    set(LIB_NAME xml2static)
    add_library(${LIB_NAME} STATIC ${SRCS} ${PUBLIC_HDRS} ${PRIVATE_HDRS})
    set_target_properties(${LIB_NAME} PROPERTIES SOVERSION 1)
endif()   

target_link_extlibraries(${LIB_NAME}) 

export(TARGETS ${LIB_NAME} FILE ${LIB_NAME}-exports.cmake)
add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)

if(NOT CYGWIN)
    set_target_properties(${LIB_NAME} PROPERTIES VERSION ${VERSION})
endif()

if(UNIX)
    # On unix-like platforms the library is almost always called libxml2
    set_target_properties(${LIB_NAME} PROPERTIES OUTPUT_NAME xml2)
    if(NOT APPLE AND BUILD_SHARED_LIBS)
        set_target_properties(${LIB_NAME} PROPERTIES LINK_FLAGS "-Wl,--version-script,\"${CMAKE_CURRENT_SOURCE_DIR}/libxml2.map\"")
    endif()
endif()

if(NOT SKIP_INSTALL_LIBRARIES AND NOT SKIP_INSTALL_ALL )
    install(TARGETS ${LIB_NAME} 
        RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
        ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
        LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )
endif()
if(NOT SKIP_INSTALL_HEADERS AND NOT SKIP_INSTALL_ALL )
    install(FILES ${JPEG_PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}")
endif()

