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

            // 2. 拨号盘
            if (uiState.accId != -1 && uiState.currentCall == null)
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

            // 3. 通话状态展示 (拨出/通话中/来电)
            if (uiState.currentCall != null) _buildCallUI(uiState, service),

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

  Widget _buildCallUI(PjsipUIState uiState, PjsipService service) {
    final call = uiState.currentCall!;
    final isIncoming = call.isIncoming;
    // 已接通后不再显示“接听”按钮，只保留挂断。
    final showAnswer = isIncoming && !call.isConnected;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        children: [
          Text(
            call.statusLabel,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showAnswer) ...[
                ElevatedButton.icon(
                  onPressed: () => service.answerCall(),
                  icon: const Icon(Icons.call),
                  label: const Text('接听'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
              ],
              if (call.isConnected) ...[
                ElevatedButton.icon(
                  onPressed: () => call.isOnHold
                      ? service.unholdCall()
                      : service.holdCall(),
                  icon: Icon(call.isOnHold ? Icons.play_arrow : Icons.pause),
                  label: Text(call.isOnHold ? '恢复' : '保持'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 20),
              ],
              ElevatedButton.icon(
                onPressed: () => service.hangupCall(),
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
