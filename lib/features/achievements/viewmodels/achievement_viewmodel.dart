import 'dart:async';
import 'package:flutter/material.dart';
import '../models/achievement_model.dart';
import '../repositories/achievement_repository.dart';

class AchievementViewModel extends ChangeNotifier {
  final AchievementRepository _repository = AchievementRepository();
  StreamSubscription? _subscription;
  
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  List<AchievementModel> get achievements => _achievements;
  bool get isLoading => _isLoading;

  void loadAchievements(String userId) {
    if (_subscription != null) return; // Prevent multiple subscriptions
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.getAchievements(userId).listen((achievementList) {
      _achievements = achievementList;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _achievements = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addAchievement(AchievementModel achievement) async {
    await _repository.addAchievement(achievement);
  }

  Future<void> updateAchievement(AchievementModel achievement) async {
    await _repository.updateAchievement(achievement);
  }

  Future<void> deleteAchievement(String id) async {
    await _repository.deleteAchievement(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
