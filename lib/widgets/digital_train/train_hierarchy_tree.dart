import 'package:flutter/material.dart';
import '../../models/train/component.dart';
import '../common/status_chip.dart';

class TrainHierarchyTree extends StatelessWidget {
  final List<TrainComponent> components;
  final String? selectedComponentId;
  final Function(String componentId) onSelectComponent;

  const TrainHierarchyTree({
    super.key,
    required this.components,
    required this.selectedComponentId,
    required this.onSelectComponent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: components.length,
      itemBuilder: (context, index) {
        return _buildNode(context, components[index]);
      },
    );
  }

  Widget _buildNode(BuildContext context, TrainComponent node) {
    final isSelected = selectedComponentId == node.id;
    final theme = Theme.of(context);

    if (node.children.isEmpty) {
      return ListTile(
        dense: true,
        selected: isSelected,
        selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
        title: Text(node.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        subtitle: Text('ID: ${node.id}'),
        trailing: StatusChip.fromComponentStatus(node.status),
        onTap: () => onSelectComponent(node.id),
      );
    }

    return ExpansionTile(
      dense: true,
      initiallyExpanded: true,
      title: Text(node.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.bold, fontSize: 13)),
      subtitle: Text('ID: ${node.id}'),
      trailing: StatusChip.fromComponentStatus(node.status),
      children: node.children.map((child) => _buildNode(context, child)).toList(),
    );
  }
}
