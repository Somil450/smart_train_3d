import 'package:flutter/material.dart';
import '../models/train/train.dart';
import '../models/train/component.dart';
import '../repositories/train_repository.dart';

class TrainStateNotifier extends ChangeNotifier {
  final TrainRepository _trainRepository;
  
  List<Train> _trains = [];
  bool _isLoading = false;
  String? _error;

  TrainStateNotifier(this._trainRepository);

  List<Train> get trains => _trains;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTrains(String selectedTrainId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trains = await _trainRepository.getTrains();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Train? getTrain(String trainId) {
    if (_trains.isEmpty) return null;
    try {
      return _trains.firstWhere((t) => t.id == trainId);
    } catch (_) {
      return _trains.first;
    }
  }

  TrainComponent? getComponent(String trainId, String componentId) {
    final train = getTrain(trainId);
    return train?.findComponent(componentId);
  }
}
