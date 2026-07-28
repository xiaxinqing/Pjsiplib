# VPhone PJSIP Bridge

这个目录放 VPhone 自己的 PJSIP 共享库包装层代码，不修改 PJSIP 源码。

## 为什么需要这一层

`on_call_tsx_state` 能拿到 SIP transaction 状态码和原因，例如 `486 Busy Here`、
`603 Decline`、`408 Request Timeout`。但是 PJSIP 传给回调的是
`pjsip_transaction*` 和 `pjsip_event*` 原生指针，这些指针生命周期很短。

Flutter/Dart 的 `NativeCallable.listener` 会把回调异步投递到 Dart 主线程。等
Dart 真正执行时，原生指针可能已经失效，macOS 上会出现 `EXC_BAD_ACCESS`
闪退。

所以这里在 dylib 内部同步复制少量普通字段到固定数组里，Dart 只通过
`vphone_get_call_info_snapshot()` 查询复制后的安全值。

## 后续升级 PJSIP 时要记住

不要改 `third_path/pjproject` 里的 PJSIP 源码。升级 PJSIP 后，只要 GitHub
Actions 继续把 `vphone_pjsip_bridge.c` 编进最终 `libpjsip.dylib` /
`pjsip.dll` / `libpjsip.so` 即可。

构建产物必须导出这些函数：

- `vphone_apply_call_snapshot_callbacks`
- `vphone_get_call_info_snapshot`
- `vphone_clear_call_info_snapshot`
- `vphone_clear_all_call_info_snapshots`

workflow 里已经加了导出符号校验，缺少这些函数时会直接构建失败，避免发出
没有快照能力的 PJSIP 库。
