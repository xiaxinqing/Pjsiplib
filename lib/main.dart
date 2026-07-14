import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/services/pjsip_service.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PJSIP VoIP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final TextEditingController _numberController = TextEditingController(
    text: '6529',
  );

  @override
  Widget build(BuildContext context) {
    final uiState = ref.watch(pjsipServiceProvider);
    final service = ref.read(pjsipServiceProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('VoIP 调试终端 (PJSIP)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. 初始化 & 注册
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  onPressed: uiState.isInitialized
                      ? null
                      : () => service.init(),
                  icon: const Icon(Icons.power_settings_new),
                  label: const Text('初始化 PJSIP'),
                ),
                ElevatedButton.icon(
                  onPressed: (uiState.isInitialized && uiState.accId == -1)
                      ? () => service.register(
                          username: '6523',
                          password: 'veserve888',
                          host: '139.59.100.15',
                        )
                      : null,
                  icon: const Icon(Icons.login),
                  label: Text(
                    uiState.accId != -1
                        ? '已注册 (ID: ${uiState.accId})'
                        : '手动注册 (6523)',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: uiState.isInitialized
                      ? () => service.stop()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('停止引擎'),
                ),
              ],
            ),
            const Divider(height: 32),

            if (uiState.isInitialized) ...[
              _buildAudioDevicePanel(uiState, service),
              const Divider(height: 32),
            ],

            // 2. 拨号盘
            if (uiState.accId != -1 &&
                uiState.calls.length < 4 &&
                !uiState.hasConference)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _numberController,
                      decoration: const InputDecoration(
                        labelText: '输入分机号',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.dialpad),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: () => service.makeCall(_numberController.text),
                    icon: const Icon(Icons.call),
                    iconSize: 32,
                    // 使用 style 来配置颜色
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white, // 图标颜色 (对应你原先的 color)
                      backgroundColor: Colors.green, // 背景颜色 (解决报错)
                    ),
                  ),
                ],
              ),

            // 3. 多路通话状态展示
            if (uiState.calls.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.call, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '当前通话（${uiState.calls.length}/4）',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (uiState.isConferencePaused) ...[
                    const SizedBox(width: 12),
                    const Chip(
                      avatar: Icon(Icons.pause, size: 18),
                      label: Text('三方通话已暂停'),
                      visualDensity: VisualDensity.compact,
                    ),
                    if (uiState.activeCallId == null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: service.resumeConference,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('恢复三方通话'),
                      ),
                    ],
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 310),
                child: ListView(
                  shrinkWrap: true,
                  children: uiState.calls.values
                      .map(
                        (call) => _buildCallUI(
                          call,
                          isActive: uiState.activeCallId == call.callId,
                          isConferenceMember: uiState.isInConference(
                            call.callId,
                          ),
                          isConferencePaused: uiState.isConferencePaused,
                          canMergeWithActive:
                              !uiState.hasConference &&
                              call.isConnected &&
                              !call.isRemoteOnHold &&
                              uiState.activeCallId != null &&
                              uiState.activeCallId != call.callId,
                          service: service,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],

            const SizedBox(height: 20),
            // 4. 日志
            const Row(
              children: [
                Icon(Icons.terminal, size: 18),
                SizedBox(width: 8),
                Text('运行日志', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(8),
                  itemCount: uiState.logs.length,
                  itemBuilder: (context, index) {
                    final log = uiState.logs[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '[${DateFormat('HH:mm:ss').format(log.time)}] ${log.message}',
                        style: const TextStyle(
                          color: Colors.lightGreenAccent,
                          fontFamily: 'Courier',
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioDevicePanel(PjsipUIState uiState, PjsipService service) {
    final captureValue =
        uiState.captureDevices.any(
          (device) => device.id == uiState.selectedCaptureDeviceId,
        )
        ? uiState.selectedCaptureDeviceId
        : null;
    final playbackValue =
        uiState.playbackDevices.any(
          (device) => device.id == uiState.selectedPlaybackDeviceId,
        )
        ? uiState.selectedPlaybackDeviceId
        : null;
    final micLevel = (uiState.microphoneLevel / 255.0).clamp(0.0, 1.0);
    final speakerLevel = (uiState.speakerLevel / 255.0).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.headphones, size: 18),
            const SizedBox(width: 8),
            const Text('音频设备', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: service.refreshAudioDevices,
              icon: const Icon(Icons.refresh),
              label: const Text('刷新设备'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<int>(
                initialValue: captureValue,
                decoration: const InputDecoration(
                  labelText: '麦克风',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.mic),
                ),
                items: uiState.captureDevices
                    .map(
                      (device) => DropdownMenuItem<int>(
                        value: device.id,
                        child: Text(
                          device.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  service.setAudioDevices(captureDeviceId: value);
                },
              ),
            ),
            SizedBox(
              width: 320,
              child: DropdownButtonFormField<int>(
                initialValue: playbackValue,
                decoration: const InputDecoration(
                  labelText: '扬声器',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.volume_up),
                ),
                items: uiState.playbackDevices
                    .map(
                      (device) => DropdownMenuItem<int>(
                        value: device.id,
                        child: Text(
                          device.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  service.setAudioDevices(playbackDeviceId: value);
                },
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: () =>
                  service.setMicrophoneMuted(!uiState.isMicrophoneMuted),
              icon: Icon(uiState.isMicrophoneMuted ? Icons.mic_off : Icons.mic),
              label: Text(uiState.isMicrophoneMuted ? '取消麦克风静音' : '麦克风静音'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => service.setSpeakerMuted(!uiState.isSpeakerMuted),
              icon: Icon(
                uiState.isSpeakerMuted ? Icons.volume_off : Icons.volume_up,
              ),
              label: Text(uiState.isSpeakerMuted ? '取消扬声器静音' : '扬声器静音'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const SizedBox(width: 76, child: Text('麦克风电平')),
            Expanded(child: LinearProgressIndicator(value: micLevel)),
            const SizedBox(width: 16),
            const SizedBox(width: 76, child: Text('扬声器电平')),
            Expanded(child: LinearProgressIndicator(value: speakerLevel)),
          ],
        ),
      ],
    );
  }

  Widget _buildCallUI(
    CallInfo call, {
    required bool isActive,
    required bool isConferenceMember,
    required bool isConferencePaused,
    required bool canMergeWithActive,
    required PjsipService service,
  }) {
    final isIncoming = call.isIncoming;
    // 已接通后不再显示“接听”按钮，只保留挂断。
    final showAnswer = isIncoming && !call.isConnected;

    return Container(
      key: ValueKey(call.callId),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConferenceMember
              ? Colors.purpleAccent
              : (isActive ? Colors.greenAccent : Colors.blueGrey),
          width: isActive || isConferenceMember ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                call.statusLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                const Chip(
                  label: Text('当前'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
              if (isConferenceMember) ...[
                const SizedBox(width: 8),
                Chip(
                  avatar: Icon(
                    isConferencePaused ? Icons.pause : Icons.groups,
                    size: 18,
                  ),
                  label: Text(isConferencePaused ? '会议成员（暂停）' : '三方通话中'),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text('号码: ${call.remoteUri}'),
          // 接通后显示实时通话时长 (由 service 每秒刷新驱动)。
          if (call.isConnected) ...[
            const SizedBox(height: 8),
            Text(
              call.durationLabel,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              if (showAnswer) ...[
                ElevatedButton.icon(
                  onPressed: () => service.answerCall(call.callId),
                  icon: const Icon(Icons.call),
                  label: const Text('接听'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => service.rejectCall(call.callId),
                  icon: const Icon(Icons.call_end),
                  label: const Text('拒接'),
                ),
              ],
              if (call.isConnected && !isConferenceMember) ...[
                ElevatedButton.icon(
                  onPressed: () => call.isOnHold
                      ? service.unholdCall(call.callId)
                      : service.holdCall(call.callId),
                  icon: Icon(call.isOnHold ? Icons.play_arrow : Icons.pause),
                  label: Text(call.isOnHold ? '恢复' : '保持'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: call.isOnHold
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ],
              if (canMergeWithActive) ...[
                ElevatedButton.icon(
                  onPressed: () => service.mergeWithActiveCall(call.callId),
                  icon: const Icon(Icons.groups),
                  label: const Text('与当前通话合并'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
              if (isConferenceMember && !isConferencePaused) ...[
                ElevatedButton.icon(
                  onPressed: () => service.splitConference(call.callId),
                  icon: const Icon(Icons.call),
                  label: const Text('拆分并保留此路'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
              ElevatedButton.icon(
                onPressed: () => service.hangupCall(call.callId),
                icon: const Icon(Icons.call_end),
                label: const Text('挂断'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
