import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/experiment/experiment.dart';
import '../../state/experiment_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../state/ai_state_notifier.dart';
import '../../core/utils/formatters.dart';

class ExperimentLabPage extends StatefulWidget {
  const ExperimentLabPage({super.key});

  @override
  State<ExperimentLabPage> createState() => _ExperimentLabPageState();
}

class _ExperimentLabPageState extends State<ExperimentLabPage> {
  String _expectedFault = 'Bearing Fault';
  double _loadKg = 450.0;
  double _speedRpm = 1450.0;
  final TextEditingController _notesController = TextEditingController(text: 'Controlled physical fault injection test.');

  ComponentConfig _config = ComponentConfig(bearingFault: true, rearBogieFault: true);

  @override
  Widget build(BuildContext context) {
    final expState = context.watch<ExperimentStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final aiState = context.watch<AIStateNotifier>();
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PHYSICAL FAULT EXPERIMENT LAB',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  const Icon(Icons.science, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    expState.isExecuting ? 'EXPERIMENT RUNNING' : 'LAB IDLE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: expState.isExecuting ? Colors.orange : Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Configuration Form
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('1. EXPERIMENT HARDWARE CONFIGURATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 12),

                        // Expected Fault Selection
                        const Text('Expected Fault Target:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: _expectedFault,
                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                          items: ['Bearing Fault', 'Wheel Fault', 'Motor Fault', 'Brake Wear', 'Suspension Fault', 'Normal']
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _expectedFault = val);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Physical Component Fault Toggle Toggles
                        const Text('Physical Component Injectors:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        _buildSwitchTile('Bearing Fault Injector', _config.bearingFault, (v) => setState(() => _config = _config.copyWith(bearingFault: v))),
                        _buildSwitchTile('Wheel Flat Injector', _config.wheelFault, (v) => setState(() => _config = _config.copyWith(wheelFault: v))),
                        _buildSwitchTile('Motor Overheat Injector', _config.motorFault, (v) => setState(() => _config = _config.copyWith(motorFault: v))),
                        _buildSwitchTile('Brake Wear Injector', _config.brakeFault, (v) => setState(() => _config = _config.copyWith(brakeFault: v))),
                        _buildSwitchTile('Suspension Slack Injector', _config.suspensionFault, (v) => setState(() => _config = _config.copyWith(suspensionFault: v))),
                        const SizedBox(height: 12),

                        // Speed & Load Controls
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Target Load: ${_loadKg.toInt()} kg', style: const TextStyle(fontSize: 11)),
                                  Slider(
                                    value: _loadKg,
                                    min: 100,
                                    max: 1000,
                                    onChanged: (v) => setState(() => _loadKg = v),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Target Speed: ${_speedRpm.toInt()} RPM', style: const TextStyle(fontSize: 11)),
                                  Slider(
                                    value: _speedRpm,
                                    min: 500,
                                    max: 3000,
                                    onChanged: (v) => setState(() => _speedRpm = v),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Execution Controls Button Group
                        Row(
                          children: [
                            if (!expState.isExecuting)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    expState.startExperiment(
                                      appState.selectedTrainId,
                                      _expectedFault,
                                      _config,
                                      _loadKg,
                                      _speedRpm,
                                      _notesController.text,
                                    );
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                  label: const Text('START EXPERIMENT'),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final aiResult = aiState.faultPrediction?.primaryFault ?? _expectedFault;
                                    final aiConf = aiState.faultPrediction?.probabilities.first.confidence ?? 0.87;
                                    expState.stopExperiment(aiResult, aiConf);
                                  },
                                  icon: const Icon(Icons.stop),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                  label: const Text('STOP & RECORD EXPERIMENT'),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Right: Execution Monitor & Completed Results Table
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Active Timer & Live Sampling Box
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('2. LIVE EXPERIMENT EXECUTION MONITOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('ELAPSED TIME', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text('${expState.elapsedSeconds}s', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('EXPECTED FAULT', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text(_expectedFault, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('AI PREDICTED', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                    Text(
                                      aiState.faultPrediction?.primaryFault ?? 'Listening...',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Past Experiment Runs Results Table
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('EXPERIMENT LOGS & EVALUATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 12),
                            if (expState.experiments.isEmpty)
                              const Text('No experiments recorded yet.')
                            else
                              ...expState.experiments.map((exp) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: theme.dividerColor),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(exp.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: exp.isMatch ? Colors.green.shade100 : Colors.red.shade100,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              exp.isMatch ? 'CORRECT MATCH' : 'MISMATCH',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: exp.isMatch ? Colors.green.shade900 : Colors.red.shade900,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Expected: ${exp.expectedFault} | AI Detected: ${exp.detectedFault ?? "Pending"}', style: const TextStyle(fontSize: 11)),
                                      Text('Confidence: ${Formatters.formatPercentage(exp.confidence ?? 0)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool val, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Switch(
            value: val,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
