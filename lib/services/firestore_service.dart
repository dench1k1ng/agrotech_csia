import 'package:agrotech_hacakaton/screens/batches/batches_screen.dart';
import 'package:agrotech_hacakaton/widgets/batch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Сохранение новой партии
  Future<void> addBatch(Batch batch) async {
    try {
      await _db.collection('batches').add(batch.toMap());
    } catch (e) {
      print("Error adding batch: $e");
      rethrow;
    }
  }

  // Загрузка всех партий
  Future<List<Object>> getBatches() async {
    try {
      final snapshot = await _db.collection('batches').get();
      return snapshot.docs.map((doc) => Batch.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error getting batches: $e");
      return [];
    }
  }

  // Удаление партии
  Future<void> deleteBatch(String batchId) async {
    try {
      await _db.collection('batches').doc(batchId).delete();
    } catch (e) {
      print("Error deleting batch: $e");
      rethrow;
    }
  }
}
