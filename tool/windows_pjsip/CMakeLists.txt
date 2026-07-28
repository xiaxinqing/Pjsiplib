cmake_minimum_required(VERSION 3.14)
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

# Enable SRTP and DTLS-SRTP support
set(PJMEDIA_WITH_SRTP ON CACHE BOOL "" FORCE)
set(PJ_DEP_SRTP bundled CACHE STRING "" FORCE)
set(SRTP_WITH_OPENSSL ON CACHE BOOL "" FORCE)

add_subdirectory("${PJPROJECT_ROOT}" pjproject-build EXCLUDE_FROM_ALL)

add_library(pjsip_ffi SHARED
  pjsip_ffi_stub.c
  ../pjsip_bridge/vphone_pjsip_bridge.c
  pjsip_ffi.def
)
target_include_directories(pjsip_ffi PRIVATE
  "${CMAKE_CURRENT_LIST_DIR}/../pjsip_bridge"
  # pjsua-lib 会把 pjlib 的 PUBLIC 编译宏传给 pjsip_ffi，其中包含
  # PJ_AUTOCONF=1。PJSIP 的 CMake 构建会把 sip_autoconf.h/config_auto.h
  # 生成到 binary dir，不在源码 include 目录里；wrapper 单独编译时必须
  # 显式加入这些生成目录，否则 Windows 会找不到 pjsip/sip_autoconf.h。
  # pjsip/sip_uri.h、pjsua.h 还会继续引用 pjlib-util、pjmedia、pjnath
  # 等源码头文件；这些 include 目录在 PJSIP 子 target 内部可见，但不会
  # 稳定传递给这个单独的 FFI wrapper，所以这里也显式补齐。
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
target_link_libraries(pjsip_ffi PRIVATE pjsua-lib)
target_compile_definitions(pjsip_ffi PRIVATE
  WIN32_LEAN_AND_MEAN
  NOMINMAX
  # Windows x64 是小端。这里显式声明字节序，避免 wrapper 单独编译时
  # PJSIP 头文件无法从架构宏推断大小端。
  PJ_IS_BIG_ENDIAN=0
  PJ_IS_LITTLE_ENDIAN=1
)
set_target_properties(pjsip_ffi PROPERTIES
  OUTPUT_NAME pjsip
  MSVC_RUNTIME_LIBRARY MultiThreadedDLL
)
