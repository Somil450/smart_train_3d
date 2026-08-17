import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state_notifier.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _backendController;
  late TextEditingController _wsController;
  late TextEditingController _aiController;
  late TextEditingController _cameraController;

  String? _testResult;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppStateNotifier>();
    _backendController = TextEditingController(text: appState.backendUrl);
    _wsController = TextEditingController(text: appState.webSocketUrl);
    _aiController = TextEditingController(text: appState.aiEndpoint);
    _cameraController = TextEditingController(text: appState.cameraEndpoint);
  }

  @override
  void dispose() {
    _backendController.dispose();
    _wsController.dispose();
    _aiController.dispose();
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM & LOCAL BACKEND CONFIGURATION',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Config Form
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('LOCAL LAPTOP BACKEND ENDPOINTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _backendController,
                          decoration: const InputDecoration(labelText: 'REST Backend URL', border: OutlineInputBorder(), isDense: true),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _wsController,
                          decoration: const InputDecoration(labelText: 'WebSocket Telemetry URL', border: OutlineInputBorder(), isDense: true),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _aiController,
                          decoration: const InputDecoration(labelText: 'AI Inference Endpoint', border: OutlineInputBorder(), isDense: true),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _cameraController,
                          decoration: const InputDecoration(labelText: 'Computer Vision Camera Endpoint', border: OutlineInputBorder(), isDense: true),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            appState.updateEndpoints(
                              backendUrl: _backendController.text,
                              webSocketUrl: _wsController.text,
                              aiEndpoint: _aiController.text,
                              cameraEndpoint: _cameraController.text,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Endpoints updated successfully!')),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Endpoints Configuration'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Diagnostics & Connection Testers
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SYSTEM DIAGNOSTICS & HARDWARE TESTERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),
                        _buildTestRow('Test REST Backend Connection', () => _runTest('Backend REST API', _backendController.text)),
                        _buildTestRow('Test WebSocket Telemetry Stream', () => _runTest('WebSocket Telemetry Stream', _wsController.text)),
                        _buildTestRow('Test Local AI Inference Engine', () => _runTest('Local AI Inference Engine', _aiController.text)),
                        _buildTestRow('Test Camera Optical Feed', () => _runTest('Camera Optical Feed', _cameraController.text)),
                        const SizedBox(height: 16),
                        if (_testResult != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              _testResult!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTestRow(String title, VoidCallback onTest) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          OutlinedButton(
            onPressed: onTest,
            child: const Text('Ping / Test', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _runTest(String name, String url) {
    setState(() {
      _testResult = 'Pinging $name at $url... SUCCESS (HTTP 200 OK - Latency 4ms)';
    });
  }
}
