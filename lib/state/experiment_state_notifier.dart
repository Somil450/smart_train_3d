import 'dart:async';
import 'package:flutter/material.dart';
import '../models/experiment/experiment.dart';
import '../repositories/experiment_repository.dart';

class ExperimentStateNotifier extends ChangeNotifier {
  final ExperimentRepository _repository;

  List<ExperimentRecord> _experiments = [];
  ExperimentRecord? _activeExperiment;
  bool _isExecuting = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  ExperimentStateNotifier(this._repository);

  List<ExperimentRecord> get experiments => List.unmodifiable(_experiments);
  ExperimentRecord? get activeExperiment => _activeExperiment;
  bool get isExecuting => _isExecuting;
  int get elapsedSeconds => _elapsedSeconds;

  Future<void> loadExperiments(String trainId) async {
    try {
      _experiments = await _repository.getExperiments(trainId);
      notifyListeners();
    } catch (_) {}
  }

  void startExperiment(String trainId, String expectedFault, ComponentConfig config, double load, double speed, String notes) {
    _activeExperiment = ExperimentRecord(
      id: 'EXP_${DateTime.now().millisecondsSinceEpoch}',
      trainId: trainId,
      startTime: DateTime.now(),
      expectedFault: expectedFault,
      configuration: config,
      loadKg: load,
      speedRpm: speed,
      status: ExperimentStatus.running,
      notes: notes,
    );
    _isExecuting = true;
    _elapsedSeconds = 0;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      notifyListeners();
    });
  }

  Future<void> stopExperiment(String detectedFault, double confidence) async {
    _timer?.cancel();
    _isExecuting = false;

    if (_activeExperiment != null) {
      final finished = _activeExperiment!.copyWith(
        endTime: DateTime.now(),
        status: ExperimentStatus.completed,
        detectedFault: detectedFault,
        confidence: confidence,
      );
      await _repository.saveExperiment(finished);
      _experiments.insert(0, finished);
      _activeExperiment = finished;
    }
    notifyListeners();
  }

  void resetActiveExperiment() {
    _activeExperiment = null;
    _elapsedSeconds = 0;
    notifyListeners();
  }
}
