/*
 * The implementation lives in the statically linked PJSIP targets.
 * The module-definition file exports the selected C symbols from those
 * archives as one DLL for Dart FFI.
 */
int pjsip_ffi_link_anchor(void) { return 0; }
