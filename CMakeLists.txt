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

cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)

project(xml2 C)

# some init settings
#set(CMAKE_COLOR_MAKEFILE ON)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()
option(BUILD_SHARED_LIBS  "Build shared libs." ON)

# set path to additional CMake modules
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})

set(INSTALL_BIN_DIR "${CMAKE_INSTALL_PREFIX}/bin" CACHE INTERNAL "Installation directory for executables" FORCE)
set(INSTALL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib" CACHE INTERNAL "Installation directory for libraries" FORCE)
set(INSTALL_INC_DIR "${CMAKE_INSTALL_PREFIX}/include" CACHE INTERNAL "Installation directory for headers" FORCE)
set(INSTALL_CMAKE_DIR "${CMAKE_INSTALL_PREFIX}/lib/cmake" CACHE INTERNAL "Installation cmake files" FORCE)


set(VERSION "2.9.3")
set(LIBXML_VERSION_NUMBER 20903)
set(LIBXML_VERSION_EXTRA "-GITCVE-2015-8242")
set(LIB_NAME ${PROJECT_NAME})
if(NOT BUILD_SHARED_LIBS)
  set(LIB_NAME ${PROJECT_NAME}static)
endif()   

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

#include(FindAnyProject)
include(SuperFind)

set(LibXml2_LINK_LIBS)

if(UNIX)
  set(MODULE_EXTENSION "${CMAKE_SHARED_LIBRARY_SUFFIX}")
elseif(WIN32)
  set(MODULE_EXTENSION "${CMAKE_LINK_LIBRARY_SUFFIX}")
  set(THREADS_W32 TRUE)
  add_definitions(-DHAVE_WIN32_THREADS -DWIN32)
  list(APPEND LibXml2_LINK_LIBS ws2_32.lib Secur32.lib)
  if (MSVC)
    add_definitions (-D_CRT_NONSTDC_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NON_CONFORMING_SWPRINTFS -D_CRT_SECURE_NO_DEPRECATE)
  endif()
endif()

if(WITH_THREADS)
  find_package(Threads REQUIRED)
  list(APPEND LibXml2_LINK_LIBS ${CMAKE_THREAD_LIBS_INIT})
  if(THREADS_FOUND)
    add_definitions(-DLIBXML_THREAD_ENABLED)
  endif()
endif()

#find_anyproject(ZLIB)
super_find_package(ZLIB)
include_directories(${ZLIB_INCLUDE_DIR})

#find_anyproject(ICONV)
# super_find_package(ICONV)
# include_directories(${ICONV_INCLUDE_DIR})

#find_anyproject(LibLZMA)
#super_find_package(LibLZMA REPOSITORY_NAME "lib_lzma" CMAKE_ARGS "-DCMAKE_C_FLAGS='-std=c99 -Wno-implicit-function-declaration'")
super_find_package(LibLZMA)
include_directories(${LibLZMA_INCLUDE_DIR})

include(configure)

configure_file(${CMAKE_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake IMMEDIATE @ONLY)

include_directories ( ${CMAKE_CURRENT_SOURCE_DIR}/include/ )
include_directories ( ${CMAKE_CURRENT_SOURCE_DIR} )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR}/include/ )
include_directories ( ${CMAKE_CURRENT_BINARY_DIR} )

set(PUBLIC_HDRS
    libxml.h
)

set(PUBLIC_HDRS_LIBXML2
    ${CMAKE_CURRENT_BINARY_DIR}/include/libxml/xmlversion.h
    include/libxml/c14n.h
    include/libxml/catalog.h
    include/libxml/chvalid.h
    include/libxml/debugXML.h
    include/libxml/dict.h
    include/libxml/DOCBparser.h
    include/libxml/encoding.h
    include/libxml/entities.h
    include/libxml/globals.h
    include/libxml/hash.h
    include/libxml/HTMLparser.h
    include/libxml/HTMLtree.h
    include/libxml/list.h
    include/libxml/nanoftp.h
    include/libxml/nanohttp.h
    include/libxml/parser.h
    include/libxml/parserInternals.h
    include/libxml/pattern.h
    include/libxml/relaxng.h
    include/libxml/SAX.h
    include/libxml/SAX2.h
    include/libxml/schemasInternals.h
    include/libxml/threads.h
    include/libxml/tree.h
    include/libxml/uri.h
    include/libxml/valid.h
    include/libxml/xinclude.h
    include/libxml/xlink.h
    include/libxml/xmlautomata.h
    include/libxml/xmlerror.h
    include/libxml/xmlexports.h
    include/libxml/xmlIO.h
    include/libxml/xmlmemory.h
    include/libxml/xmlmodule.h
    include/libxml/xmlreader.h
    include/libxml/xmlregexp.h
    include/libxml/xmlsave.h
    include/libxml/xmlschemas.h
    include/libxml/xmlschemastypes.h
    include/libxml/xmlstring.h
    include/libxml/xmlunicode.h		
    include/libxml/xmlwriter.h
    include/libxml/xpath.h
    include/libxml/xpathInternals.h
    include/libxml/xpointer.h
)

set(PRIVATE_HDRS
    ${CMAKE_CURRENT_BINARY_DIR}/config.h
    triodef.h
    trionan.h
    xzlib.h
)

set(SRCS
    c14n.c
    catalog.c
    chvalid.c
    buf.c
    debugXML.c
    dict.c
    DOCBparser.c
    encoding.c
    entities.c
    error.c
    globals.c
    hash.c
    HTMLparser.c
    HTMLtree.c
    legacy.c
    list.c
    nanoftp.c
    nanohttp.c
    parser.c
    parserInternals.c
    pattern.c
    relaxng.c
    SAX2.c
    SAX.c
    threads.c
    tree.c
    uri.c
    valid.c
    xinclude.c
    xlink.c
    xmlIO.c
    xmlmemory.c
    xmlreader.c
    xmlregexp.c
    xmlsave.c
    xmlschemas.c
    xmlschemastypes.c
    xmlunicode.c
    xmlwriter.c
    xpath.c
    xpointer.c
    xmlstring.c
    xzlib.c
)

if(WIN32)
    set(SRCS ${SRCS}
        # include/win32config.h wince stuf
        include/wsockcompat.h
    )	
    
endif()

include(util)
report_version(${PROJECT_NAME} ${VERSION})    
  
add_library(${LIB_NAME} ${SRCS} ${PUBLIC_HDRS} ${PUBLIC_HDRS_LIBXML2} ${PRIVATE_HDRS})

if(BUILD_SHARED_LIBS)
  set_target_properties(${LIB_NAME} PROPERTIES DEFINE_SYMBOL XML2_DLL)
endif()

if(NOT CYGWIN)
  set_target_properties(${LIB_NAME} PROPERTIES VERSION ${VERSION})
endif()

if(TARGET ZLIB)
  add_dependencies(${LIB_NAME} ZLIB)
endif()
if(TARGET LibLZMA)
  add_dependencies(${LIB_NAME} LibLZMA)
endif()

target_link_libraries(${LIB_NAME} ${ICONV_LIBRARIES} ${LIBLZMA_LIBRARIES} ${ZLIB_LIBRARIES} ${LibXml2_LINK_LIBS})



set(CMAKE_CONFIG_NAME "LibXml2")

export(TARGETS ${LIB_NAME} FILE ${CMAKE_CONFIG_NAME}Targets.cmake EXPORT_LINK_INTERFACE_LIBRARIES)
 
install(TARGETS ${LIB_NAME}
  EXPORT ${CMAKE_CONFIG_NAME}Targets
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}")

add_custom_target(uninstall COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)


install(TARGETS ${LIB_NAME} 
  RUNTIME DESTINATION "${INSTALL_BIN_DIR}"
  ARCHIVE DESTINATION "${INSTALL_LIB_DIR}"
  LIBRARY DESTINATION "${INSTALL_LIB_DIR}" )

install(FILES ${PUBLIC_HDRS} DESTINATION "${INSTALL_INC_DIR}")
install(FILES ${PUBLIC_HDRS_LIBXML2} DESTINATION "${INSTALL_INC_DIR}/libxml")











if(WIN32 AND NOT CYGWIN)
  set(DEF_INSTALL_CMAKE_DIR cmake)
else()
  set(DEF_INSTALL_CMAKE_DIR lib/cmake/libxml2)
endif()
set(INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
  "Installation directory for CMake files")

export(TARGETS ${LIB_NAME}
  FILE "${CMAKE_BINARY_DIR}/${CMAKE_CONFIG_NAME}Targets.cmake")

set(${CMAKE_CONFIG_NAME}_VERSION ${VERSION})
 
# Make relative paths absolute (needed later on)
foreach(p LIB BIN INCLUDE CMAKE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()

set(CONFIG_TYPE "NOCONFIG")
if(NOT "${CMAKE_BUILD_TYPE}" STREQUAL "")
  string(TOUPPER ${CMAKE_BUILD_TYPE} CONFIG_TYPE)
endif()

file(RELATIVE_PATH REL_INCLUDE_DIR "${INSTALL_CMAKE_DIR}"
  "${INSTALL_INC_DIR}")

# ... for the build tree
set(CONF_INCLUDE_DIRS "${CMAKE_SOURCE_DIR}/include")
configure_file("${CMAKE_SOURCE_DIR}/cmake/${CMAKE_CONFIG_NAME}Config.cmake.in"
  "${CMAKE_BINARY_DIR}/${CMAKE_CONFIG_NAME}Config.cmake" @ONLY)

# ... for the install tree
set(CONF_INCLUDE_DIRS "\${INSTALL_CMAKE_DIR}/${REL_INCLUDE_DIR}")
configure_file("${CMAKE_SOURCE_DIR}/cmake/${CMAKE_CONFIG_NAME}Config.cmake.in"
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${CMAKE_CONFIG_NAME}Config.cmake" @ONLY)
# ... for both
configure_file("${CMAKE_SOURCE_DIR}/cmake/${CMAKE_CONFIG_NAME}ConfigVersion.cmake.in"
  "${CMAKE_BINARY_DIR}/${CMAKE_CONFIG_NAME}ConfigVersion.cmake" @ONLY)
 
install(FILES
  "${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${CMAKE_CONFIG_NAME}Config.cmake"
  "${CMAKE_BINARY_DIR}/${CMAKE_CONFIG_NAME}ConfigVersion.cmake"
  DESTINATION ${DEF_INSTALL_CMAKE_DIR} )

# Install the export set for use with the install-tree
install(EXPORT ${CMAKE_CONFIG_NAME}Targets DESTINATION ${DEF_INSTALL_CMAKE_DIR})
