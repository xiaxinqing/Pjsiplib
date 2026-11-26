import 'dart:ffi';
import 'dart:isolate';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

/// Windows NLM counts IPv4 or IPv6 local connectivity, including an isolated LAN.
Future<bool> hasWindowsLanConnection() => Isolate.run(_readLocalConnectivity);

bool _readLocalConnectivity() => using((arena) {
  // COM initialization, the query and cleanup must stay on the same thread.
  final hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
  if (SUCCEEDED(hr)) {
    arena.onReleaseAll(CoUninitialize);
  } else if (hr != RPC_E_CHANGED_MODE) {
    throw WindowsException(hr);
  }

  final pointer = COMObject.createFromID(
    CLSID_NetworkListManager,
    IID_INetworkListManager,
    allocator: arena,
  );
  final manager = INetworkListManager(pointer)..detach();
  arena.onReleaseAll(manager.release);
  return manager.isConnected == VARIANT_TRUE;
});
