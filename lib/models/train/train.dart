import 'component.dart';

enum TrainStatus {
  normal,
  warning,
  critical,
  offline,
}

class Train {
  final String id;
  final String name;
  final TrainStatus status;
  final double healthScore;
  final String location;
  final DateTime lastUpdated;
  final List<TrainComponent> components;
  final List<String> activeFaults;

  Train({
    required this.id,
    required this.name,
    required this.status,
    required this.healthScore,
    required this.location,
    required this.lastUpdated,
    required this.components,
    required this.activeFaults,
  });

  Train copyWith({
    String? id,
    String? name,
    TrainStatus? status,
    double? healthScore,
    String? location,
    DateTime? lastUpdated,
    List<TrainComponent>? components,
    List<String>? activeFaults,
  }) {
    return Train(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      healthScore: healthScore ?? this.healthScore,
      location: location ?? this.location,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      components: components ?? this.components,
      activeFaults: activeFaults ?? this.activeFaults,
    );
  }

  /// Returns all components of type bogie in the train hierarchy
  List<TrainComponent> get bogies {
    final List<TrainComponent> result = [];
    void search(List<TrainComponent> list) {
      for (final comp in list) {
        if (comp.type == ComponentType.bogie) {
          result.add(comp);
        }
        search(comp.children);
      }
    }
    search(components);
    return result;
  }

  /// Recursively find a component by ID within the train hierarchy
  TrainComponent? findComponent(String componentId) {
    TrainComponent? searchInList(List<TrainComponent> list) {
      for (final comp in list) {
        if (comp.id == componentId) return comp;
        final foundInChild = searchInList(comp.children);
        if (foundInChild != null) return foundInChild;
      }
      return null;
    }

    return searchInList(components);
  }

  /// Find the parent bogie of a specific component ID
  TrainComponent? findParentBogie(String componentId) {
    for (final bogie in bogies) {
      if (bogie.id == componentId) return bogie;
      if (_containsComponent(bogie.children, componentId)) {
        return bogie;
      }
    }
    return null;
  }

  bool _containsComponent(List<TrainComponent> list, String targetId) {
    for (final comp in list) {
      if (comp.id == targetId) return true;
      if (_containsComponent(comp.children, targetId)) return true;
    }
    return false;
  }
}
