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

同样地，`pjmedia_transport_info` 包含平台相关的 socket 类型。Windows x64
使用 64 位 `pj_sock_t`，但 C `long` 仍是 32 位，不能让一份在 macOS 上生成
的 Dart FFI 结构直接解释它。媒体安全状态因此也由 Bridge 原生读取，并通过
固定宽度的 `vphone_media_security_snapshot` 返回。

PJSUA 没有向应用转发 DTLS-SRTP 协商成功的精确时刻。因此 Dart 在已有的
`on_call_media_state` 回调后读取固定宽度快照；如果配置或 SDP 表明需要 SRTP
但尚未激活，只在通话开始后的 1、3、8 秒有限确认，成功后立即停止，不持续
轮询。

## 后续升级 PJSIP 时要记住

升级 PJSIP 后无需重新应用源码补丁，只要确保 GitHub Actions 继续把
`vphone_pjsip_bridge.c` 编进最终 `libpjsip.dylib` / `pjsip.dll` /
`libpjsip.so` 即可。

构建产物必须导出这些函数：

- `vphone_apply_call_snapshot_callbacks`
- `vphone_get_call_info_snapshot`
- `vphone_clear_call_info_snapshot`
- `vphone_clear_all_call_info_snapshots`
- `vphone_get_call_media_security`

workflow 里已经加了导出符号校验，缺少这些函数时会直接构建失败，避免发出
没有快照能力的 PJSIP 库。
