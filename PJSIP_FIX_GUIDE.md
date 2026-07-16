# PJSIP 通话瞬间挂断问题修复指南

## 问题诊断结果

### 根本原因
当前的 `pjsip.dll` **缺少14个关键函数**，导致：
1. ❌ **无法初始化音频设备** (`pjsua_enum_aud_devs`, `pjsua_set_snd_dev` 等缺失)
2. ❌ **接听来电失败**，错误码 `170488`
3. ❌ **拨打电话立即断开**，无法建立媒体通道

### 日志证据
```
🔔 printLog: ID ❌ 恢复坐席环境失败: Failed to lookup symbol 'pjsua_enum_aud_devs'
🔔 printLog: ID ❌ 接听失败: 170488
🔔 printLog: ID 📞 通话已结束: call=0 (DISCONNECTED)
```

### 缺失的函数列表
```
1. pjsua_enum_aud_devs          - 枚举音频设备 ⚠️ 关键
2. pjsua_set_snd_dev            - 设置音频设备 ⚠️ 关键
3. pjsua_get_snd_dev            - 获取音频设备 ⚠️ 关键
4. pjsua_acc_set_default        - 设置默认账号 ⚠️ 关键
5. pjsua_acc_del2               - 删除账号
6. pjsua_acc_del_param_default  - 账号删除参数
7. pjsua_call_dial_dtmf         - 发送DTMF按键音
8. pjsua_conf_get_signal_level  - 获取音频信号电平
9. pjsua_player_create          - 创建音频播放器
10. pjsua_player_destroy        - 销毁播放器
11. pjsua_player_get_conf_port  - 获取播放器端口
12. pjsua_recorder_create       - 创建录音器
13. pjsua_recorder_destroy      - 销毁录音器
14. pjsua_recorder_get_conf_port - 获取录音器端口
```

## 解决方案

### 方案1：重新编译完整的 PJSIP 库（推荐）

需要在 PJSIP 编译时导出所有必需的函数。

#### 步骤：

1. **修改导出定义文件**
   创建 `third_path/pjproject/pjsip.def` 文件，包含所有必需的导出函数。

2. **重新编译 PJSIP**
   ```bash
   cd third_path/pjproject
   
   # 配置编译选项，确保包含音频设备支持
   ./configure --prefix=/usr/local \
               --enable-shared \
               --disable-video \
               --disable-v4l2 \
               --disable-opencore-amr \
               --with-external-srtp
   
   # 编译
   make dep
   make
   
   # 生成 DLL（Windows 需要在 Visual Studio 环境中编译）
   ```

3. **Windows 编译**（需要在 Windows 上执行）
   - 打开 `third_path/pjproject/pjsip-apps/build/pjsua.vcxproj`
   - 使用 Visual Studio 2019+ 编译
   - 确保链接所有音频设备库

### 方案2：使用 GitHub Actions 自动编译（最简单）

项目已经配置了 `.github/workflows/build-pjsip-windows.yml`，但需要确保编译配置正确。

#### 检查编译配置：

查看 `.github/workflows/build-pjsip-windows.yml`，确保包含：
- 音频设备支持 (`PJMEDIA_AUDIO_DEV_HAS_PORTAUDIO=1`)
- 所有必需的函数导出

### 方案3：临时修复 - 添加函数存在性检查（临时方案）

在代码中添加函数检查，跳过缺失的功能：

```dart
// 在 pjsip_service.dart 中添加
bool _hasFunctionSupport(String functionName) {
  try {
    _bindings.lookup(functionName);
    return true;
  } catch (e) {
    return false;
  }
}

// 在使用前检查
if (_hasFunctionSupport('pjsua_enum_aud_devs')) {
  await refreshAudioDevices();
} else {
  _addLog('⚠️ 音频设备枚举不可用，使用默认设备');
}
```

但这只能**避免崩溃**，**不能解决通话问题**，因为音频设备初始化失败。

## 推荐操作步骤

### 立即行动：

1. **查看 GitHub Actions 构建日志**
   检查 `.github/workflows/build-pjsip-windows.yml` 的最近构建是否成功

2. **检查源码中的导出定义**
   查看是否有 `.def` 文件或 CMake 配置遗漏了函数导出

3. **重新触发 GitHub Actions 构建**（如果配置正确）
   或者手动在 Windows 上重新编译 PJSIP

### 验证修复：

编译完成后，使用检查脚本验证：
```bash
python tool/check_exports.py windows/Frameworks/pjsip.dll
```

应该显示：`MISSING: 0`（所有函数都已导出）

## 额外说明

### 为什么之前的库不完整？

可能原因：
1. 编译时使用了最小化配置，禁用了音频设备支持
2. `.def` 导出文件不完整
3. 链接时遗漏了 `pjsua` 相关的对象文件
4. 使用了精简版的 PJSIP 配置

### PJSIP 编译要求

完整的 VoIP 功能需要：
- ✅ SIP 协议栈 (已有)
- ✅ 媒体传输 (RTP/RTCP) (已有)
- ❌ 音频设备抽象层 (缺失)
- ✅ 编解码器 (PCMU/PCMA 已有)
- ❌ 会议桥接器完整功能 (部分缺失)

## 联系信息

如果需要帮助重新编译 PJSIP，请提供：
1. Visual Studio 版本
2. 编译环境信息
3. 是否有访问 GitHub Actions 的权限
