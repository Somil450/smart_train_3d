import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/ai/anomaly_result.dart';
import '../../state/ai_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../core/utils/formatters.dart';

class FaultDetectionPage extends StatelessWidget {
  const FaultDetectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final aiState = context.watch<AIStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    final anomaly = aiState.anomalyResult;
    final prediction = aiState.faultPrediction;
    final explanation = aiState.explanation;

    final isAnomalous = anomaly?.status == AnomalyStatus.anomalous;
    final anomalyScore = anomaly?.anomalyScore ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI FAULT DETECTION & DIAGNOSIS PIPELINE',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => aiState.loadAIData(appState.selectedTrainId),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Re-trigger AI Inference'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3-STAGE VISUAL PIPELINE HEADER
          Row(
            children: [
              Expanded(
                child: _buildStageHeader(
                  context,
                  stepNumber: 'STAGE 1',
                  title: 'ANOMALY DETECTION',
                  icon: Icons.search,
                  isActive: true,
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Expanded(
                child: _buildStageHeader(
                  context,
                  stepNumber: 'STAGE 2',
                  title: 'CLASSIFICATION',
                  icon: Icons.category,
                  isActive: isAnomalous,
                ),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              Expanded(
                child: _buildStageHeader(
                  context,
                  stepNumber: 'STAGE 3',
                  title: 'LOCALIZATION',
                  icon: Icons.my_location,
                  isActive: isAnomalous,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pipeline Body Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1: Stage 1 (Anomaly Result) & Stage 2 (Classification Probabilities)
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Stage 1 Card: Anomaly Score & Status
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'STAGE 1: ANOMALY DETECTION ENGINE',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isAnomalous ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isAnomalous ? 'ANOMALOUS' : 'NORMAL',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isAnomalous ? Colors.red.shade900 : Colors.green.shade900,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  Formatters.formatPercentage(anomalyScore / 100),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isAnomalous ? Colors.red : Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Overall Signal Anomaly Confidence Score'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: (anomalyScore / 100).clamp(0.0, 1.0),
                              minHeight: 10,
                              borderRadius: BorderRadius.circular(5),
                              color: isAnomalous ? Colors.red : Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stage 2 Card: Classification Probabilities
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STAGE 2: MULTI-CLASS FAULT PROBABILITIES',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            if (prediction == null || prediction.probabilities.isEmpty)
                              const Text('No fault classification results')
                            else
                              ...prediction.probabilities.map((prob) {
                                final isPrimary = prob.faultType == prediction.primaryFault;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              if (isPrimary)
                                                const Icon(Icons.star, color: Colors.amber, size: 16)
                                              else
                                                const Icon(Icons.circle, size: 8, color: Colors.grey),
                                              const SizedBox(width: 6),
                                              Text(
                                                prob.faultType,
                                                style: TextStyle(
                                                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            Formatters.formatPercentage(prob.confidence),
                                            style: TextStyle(
                                              fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                                              color: isPrimary ? Colors.purple : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: prob.confidence.clamp(0.0, 1.0),
                                        minHeight: 6,
                                        borderRadius: BorderRadius.circular(3),
                                        color: isPrimary ? Colors.purple : Colors.blue.shade200,
                                        backgroundColor: theme.dividerColor,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Column 2: Stage 3 (Localization) & AI Explanation Evidence
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    // Stage 3 Card: Hierarchical Fault Localization
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STAGE 3: HIERARCHICAL FAULT LOCALIZATION',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: theme.dividerColor),
                              ),
                              child: Column(
                                children: [
                                  _buildLocalizationStep('Train Unit', appState.selectedTrainId, isTerminal: false),
                                  _buildLocalizationStep('Carriage Section', 'Rear Bogie Carriage', isTerminal: false),
                                  _buildLocalizationStep('Sub-Assembly', 'Rear Bogie Axle 4 Set', isTerminal: false),
                                  _buildLocalizationStep(
                                    'Fault Component',
                                    prediction?.localizedComponentId ?? 'BEARING_REAR_02',
                                    isTerminal: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (prediction != null) {
                                    appState.selectComponent(prediction.localizedComponentId);
                                    appState.setCurrentRoute(AppRoute.dashboard);
                                  }
                                },
                                icon: const Icon(Icons.center_focus_strong, size: 16),
                                label: const Text('Focus Component on Digital Twin'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Explanation & Evidence
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book, color: Colors.blue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'STRUCTURED AI EVIDENCE & EXPLANATION',
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              explanation?.summary ?? 'Analysis isolating peak impact signals.',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 12),
                            const Text('Primary Signal Indicator:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(explanation?.primarySignal ?? 'Rear Bogie Z-Axis Vibration & Bearing Temp',
                                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold)),
                            const Divider(height: 20),
                            const Text('Extracted Signal Evidence:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            if (explanation == null || explanation.evidence.isEmpty)
                              const Text('No evidence recorded')
                            else
                              ...explanation.evidence.map((ev) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(ev.description, style: const TextStyle(fontSize: 11)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          ev.changePercentage,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                                        ),
                                      ),
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

  Widget _buildStageHeader(
    BuildContext context, {
    required String stepNumber,
    required String title,
    required IconData icon,
    required bool isActive,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: isActive ? theme.colorScheme.primaryContainer.withOpacity(0.4) : theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(icon, color: isActive ? theme.colorScheme.primary : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepNumber,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? theme.colorScheme.primary : Colors.grey),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizationStep(String level, String val, {required bool isTerminal}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(isTerminal ? Icons.location_on : Icons.subdirectory_arrow_right,
              size: 16, color: isTerminal ? Colors.red : Colors.grey),
          const SizedBox(width: 8),
          Text('$level: ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isTerminal ? FontWeight.bold : FontWeight.w600,
              color: isTerminal ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }
}
