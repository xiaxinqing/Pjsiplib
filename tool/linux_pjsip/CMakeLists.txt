cmake_minimum_required(VERSION 3.24)
project(pjsip_ffi_linux LANGUAGES C CXX)

if(NOT UNIX OR APPLE)
  message(FATAL_ERROR "This wrapper is only intended for Linux builds")
endif()
if(NOT DEFINED PJPROJECT_ROOT)
  message(FATAL_ERROR "Pass -DPJPROJECT_ROOT=<path-to-pjproject>")
endif()

# PJSIP is built as static PIC libraries, then re-exported from one shared
# object for Dart FFI. The Flutter Linux runner has $ORIGIN/lib in its rpath, so
# libpjsip.so can live next to Flutter's bundled native libraries.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(PJ_SKIP_EXPERIMENTAL_NOTICE ON CACHE BOOL "" FORCE)
set(PJLIB_WITH_SSL openssl CACHE STRING "" FORCE)
set(PJMEDIA_WITH_VIDEO OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_OPUS_CODEC OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_WEBRTC_AEC OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_AUDIODEV_ALSA ON CACHE BOOL "" FORCE)

add_subdirectory("${PJPROJECT_ROOT}" pjproject-build EXCLUDE_FROM_ALL)

add_library(pjsip_ffi SHARED
  ../windows_pjsip/pjsip_ffi_stub.c
  ../pjsip_bridge/vphone_pjsip_bridge.c
)
target_include_directories(pjsip_ffi PRIVATE
  "${CMAKE_CURRENT_LIST_DIR}/../pjsip_bridge"
  # pjsua-lib 会把 pjlib 的 PUBLIC 编译宏传给 pjsip_ffi，其中包含
  # PJ_AUTOCONF=1。PJSIP 的 CMake 构建会把 sip_autoconf.h/config_auto.h
  # 生成到 binary dir；显式加入这些目录，避免 wrapper 单独编译时找不到
  # autoconf 头文件。pjlib-util、pjmedia、pjnath 等源码头文件也会被
  # pjsip/pjsua 头文件间接引用；wrapper 单独编译时同样显式补齐，
  # 避免平台间 include 传播差异。
  "${PJPROJECT_ROOT}/pjlib/include"
  "${PJPROJECT_ROOT}/pjlib-util/include"
  "${PJPROJECT_ROOT}/pjnath/include"
  "${PJPROJECT_ROOT}/pjmedia/include"
  "${PJPROJECT_ROOT}/pjsip/include"
  "${CMAKE_CURRENT_BINARY_DIR}/pjproject-build/pjsip/include"
  "${CMAKE_CURRENT_BINARY_DIR}/pjproject-build/pjmedia/include"
  "${CMAKE_CURRENT_BINARY_DIR}/pjproject-build/pjlib/include"
  "${CMAKE_CURRENT_BINARY_DIR}/pjproject-build/pjlib-util/include"
)
target_compile_definitions(pjsip_ffi PRIVATE
  # vphone_pjsip_bridge.c 是单独编译进统一 FFI 动态库的，不一定能继承
  # PJSIP 子工程的 APP_CFLAGS。显式声明 autoconf 和小端，避免 ARM/x64
  # 平台头文件判断大小端时出现 “Endianness must be declared”。
  PJ_AUTOCONF=1
  PJ_IS_BIG_ENDIAN=0
  PJ_IS_LITTLE_ENDIAN=1
)
target_link_libraries(pjsip_ffi PRIVATE
  -Wl,--whole-archive
  pjsua-lib
  pjsip
  pjsip-simple
  pjsip-ua
  pjmedia
  pjmedia-codec
  pjmedia-audiodev
  pjnath
  pjlib-util
  pjlib-ssl
  pjlib
  -Wl,--no-whole-archive
)
target_link_options(pjsip_ffi PRIVATE
  -Wl,--no-undefined
)
set_target_properties(pjsip_ffi PROPERTIES
  OUTPUT_NAME pjsip
)
