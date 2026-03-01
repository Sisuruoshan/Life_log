import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<GoalModel>> getGoals(String userId) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final goals = snapshot.docs
          .map((doc) => GoalModel.fromMap(doc.data(), doc.id))
          .toList();
      goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return goals;
    });
  }

  Future<void> addGoal(GoalModel goal) async {
    await _firestore.collection('goals').add(goal.toMap());
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _firestore.collection('goals').doc(goal.id).update(goal.toMap());
  }

  Future<void> deleteGoal(String id) async {
    await _firestore.collection('goals').doc(id).delete();
  }
}
