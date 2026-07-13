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
