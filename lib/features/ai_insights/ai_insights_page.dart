import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/ai_state_notifier.dart';
import '../../core/utils/formatters.dart';

class AIInsightsPage extends StatelessWidget {
  const AIInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final aiState = context.watch<AIStateNotifier>();
    final theme = Theme.of(context);

    final exp = aiState.explanation;
    final pred = aiState.faultPrediction;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI MODEL INSIGHTS & EXPLANABILITY LAB',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Decision Card
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: Colors.purple, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'AI DECISION SUMMARY',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          exp?.summary ?? 'AI inference pipeline active.',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Model Confidence: ${Formatters.formatPercentage(exp?.confidence ?? 0.95)}',
                            style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                        const Divider(height: 24),
                        const Text('PRIMARY SIGNAL DRIVER:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Chip(
                          avatar: const Icon(Icons.bolt, size: 14),
                          label: Text(exp?.primarySignal ?? 'Bogie Vibration & Bearing Temp', style: const TextStyle(fontSize: 11)),
                          backgroundColor: Colors.purple.shade50,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Signal Importance Contributions
              Expanded(
                flex: 5,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FEATURE IMPORTANCE & SIGNAL CONTRIBUTION',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        if (exp == null || exp.evidence.isEmpty)
                          const Text('No evidence details available')
                        else
                          ...exp.evidence.map((ev) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(ev.description, style: const TextStyle(fontSize: 12)),
                                      Text(ev.significance, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: 0.85,
                                    minHeight: 6,
                                    borderRadius: BorderRadius.circular(3),
                                    color: Colors.purple,
                                    backgroundColor: theme.dividerColor,
                                  ),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Multi-Class Confusion Matrix / Confidence Distribution
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FAULT CLASSIFICATION PROBABILITY DISTRIBUTION',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  if (pred != null)
                    ...pred.probabilities.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            SizedBox(width: 180, child: Text(p.faultType, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: p.confidence.clamp(0.0, 1.0),
                                minHeight: 12,
                                borderRadius: BorderRadius.circular(6),
                                color: p.faultType == pred.primaryFault ? Colors.purple : Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: Text(
                                Formatters.formatPercentage(p.confidence),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
    );
  }
}
