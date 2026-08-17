import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../state/history_state_notifier.dart';
import '../../state/app_state_notifier.dart';
import '../../core/utils/formatters.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final historyState = context.watch<HistoryStateNotifier>();
    final appState = context.watch<AppStateNotifier>();
    final theme = Theme.of(context);

    final runs = historyState.runs;
    final selectedRun = historyState.selectedRun;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORICAL RUN RECORDS & DIAGNOSTIC REPLAY',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Filters Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search by Run ID, Fault Type, Component ID...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (val) => historyState.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String?>(
                      initialValue: historyState.filterCondition,
                      decoration: const InputDecoration(
                        labelText: 'Filter Condition',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: null, child: Text('All Conditions')),
                        DropdownMenuItem(value: 'Anomalous', child: Text('Anomalous')),
                        DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      ],
                      onChanged: (val) => historyState.setFilterCondition(val),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // History Runs Data Table & Detail Drawer Split
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Runs Table
              Expanded(
                flex: 6,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RUN LOGS (${runs.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        if (runs.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(child: Text('No historical runs match the search filter.')),
                          )
                        else
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              columns: const [
                                DataColumn(label: Text('Run ID')),
                                DataColumn(label: Text('Timestamp')),
                                DataColumn(label: Text('Condition')),
                                DataColumn(label: Text('Diagnosed Fault')),
                                DataColumn(label: Text('Component ID')),
                                DataColumn(label: Text('Confidence')),
                                DataColumn(label: Text('Health')),
                              ],
                              rows: runs.map((run) {
                                final isSelected = selectedRun?.runId == run.runId;
                                final isAnomalous = run.condition == 'Anomalous';

                                return DataRow(
                                  selected: isSelected,
                                  onSelectChanged: (_) => historyState.selectRun(run),
                                  cells: [
                                    DataCell(Text(run.runId, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(Formatters.formatDateTime(run.timestamp))),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isAnomalous ? Colors.red.shade100 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          run.condition,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isAnomalous ? Colors.red.shade900 : Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(run.faultType)),
                                    DataCell(Text(run.locationComponentId)),
                                    DataCell(Text(Formatters.formatPercentage(run.confidence))),
                                    DataCell(Text(Formatters.formatPercentage(run.healthScore / 100))),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Selected Run Detail Panel
              Expanded(
                flex: 4,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: selectedRun == null
                        ? const Center(child: Text('Select a run record to inspect full historical evidence and sensor logs.'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'RUN DETAILS: ${selectedRun.runId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () => historyState.selectRun(null),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              _buildDetailRow('Train ID', selectedRun.trainId),
                              _buildDetailRow('Timestamp', Formatters.formatDateTime(selectedRun.timestamp)),
                              _buildDetailRow('Duration', '${selectedRun.durationSeconds} seconds'),
                              _buildDetailRow('Condition Status', selectedRun.condition),
                              _buildDetailRow('Primary Fault', selectedRun.faultType),
                              _buildDetailRow('Localized Component', selectedRun.locationComponentId),
                              _buildDetailRow('AI Confidence', Formatters.formatPercentage(selectedRun.confidence)),
                              _buildDetailRow('Health Score', Formatters.formatPercentage(selectedRun.healthScore / 100)),
                              if (selectedRun.experimentId != null)
                                _buildDetailRow('Linked Experiment', selectedRun.experimentId!),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    appState.selectComponent(selectedRun.locationComponentId);
                                    appState.setCurrentRoute(AppRoute.dashboard);
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 16),
                                  label: const Text('Open Component on Dashboard'),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
