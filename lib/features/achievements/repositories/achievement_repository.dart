import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement_model.dart';

class AchievementRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AchievementModel>> getAchievements(String userId) {
    return _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        // Ensure no index requirements fail initially by omitting order if it errors. 
        // We'll see if creating simple queries is fine.
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AchievementModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addAchievement(AchievementModel achievement) async {
    await _firestore.collection('achievements').add(achievement.toMap());
  }

  Future<void> updateAchievement(AchievementModel achievement) async {
    await _firestore.collection('achievements').doc(achievement.id).update(achievement.toMap());
  }

  Future<void> deleteAchievement(String id) async {
    await _firestore.collection('achievements').doc(id).delete();
  }
}
