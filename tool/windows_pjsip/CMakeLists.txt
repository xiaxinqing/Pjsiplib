cmake_minimum_required(VERSION 3.24)
project(pjsip_ffi_windows LANGUAGES C CXX)

if(NOT WIN32)
  message(FATAL_ERROR "This wrapper is only intended for Windows builds")
endif()
if(NOT DEFINED PJPROJECT_ROOT)
  message(FATAL_ERROR "Pass -DPJPROJECT_ROOT=<path-to-pjproject>")
endif()

# PJSIP is built statically, then the APIs used by Dart FFI are exported from
# one DLL. This avoids shipping a graph of PJSIP DLLs and keeps Dart loading
# identical to macOS: one library owns the complete PJSUA runtime.
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(PJ_SKIP_EXPERIMENTAL_NOTICE ON CACHE BOOL "" FORCE)
set(PJLIB_WITH_SSL openssl CACHE STRING "" FORCE)
set(PJMEDIA_WITH_VIDEO OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_OPUS_CODEC OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_WEBRTC_AEC OFF CACHE BOOL "" FORCE)
set(PJMEDIA_WITH_AUDIODEV_WASAPI ON CACHE BOOL "" FORCE)

add_subdirectory("${PJPROJECT_ROOT}" pjproject-build EXCLUDE_FROM_ALL)

add_library(pjsip_ffi SHARED
  pjsip_ffi_stub.c
  pjsip_ffi.def
)
target_link_libraries(pjsip_ffi PRIVATE pjsua-lib)
target_compile_definitions(pjsip_ffi PRIVATE WIN32_LEAN_AND_MEAN NOMINMAX)
set_target_properties(pjsip_ffi PROPERTIES
  OUTPUT_NAME pjsip
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
)
