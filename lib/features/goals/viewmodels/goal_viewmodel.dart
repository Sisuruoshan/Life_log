import 'dart:async';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../repositories/goal_repository.dart';

class GoalViewModel extends ChangeNotifier {
  final GoalRepository _repository = GoalRepository();
  StreamSubscription? _subscription;
  
  List<GoalModel> _goals = [];
  bool _isLoading = false;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  void loadGoals(String userId) {
    if (_subscription != null) return; // Prevent multiple subscriptions
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getGoals(userId).listen((goalList) {
      _goals = goalList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _goals = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    await _repository.addGoal(goal);
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _repository.updateGoal(goal);
  }

  Future<void> deleteGoal(String id) async {
    await _repository.deleteGoal(id);
  }

  Future<void> toggleGoalCompletion(GoalModel goal) async {
    final updatedGoal = goal.copyWith(isCompleted: !goal.isCompleted);
    await _repository.updateGoal(updatedGoal);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
