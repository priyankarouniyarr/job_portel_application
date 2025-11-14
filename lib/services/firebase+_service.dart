import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portel_application/models/job_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String jobsCol = 'jobs';
  final String usersCol = 'users';

  // Create or update job
  Future<void> upsertJob(Job job) async {
    if (job.id.isEmpty) {
      await _db.collection(jobsCol).add(job.toMap());
    } else {
      await _db
          .collection(jobsCol)
          .doc(job.id)
          .set(job.toMap(), SetOptions(merge: true));
    }
  }

  Future<void> deleteJob(String id) async {
    await _db.collection(jobsCol).doc(id).delete();
  }

  // Single doc
  Future<Job> getJob(String id) async {
    final doc = await _db.collection(jobsCol).doc(id).get();
    return Job.fromDoc(doc);
  }

  // Cursor-based pagination
  Future<List<Job>> fetchJobs({
    DocumentSnapshot? startAfterDoc,
    int limit = 10,
    bool activeOnly = true,
  }) async {
    Query q = _db.collection(jobsCol).orderBy('postedAt', descending: true);
    if (activeOnly) q = q.where('isActive', isEqualTo: true);
    if (startAfterDoc != null) q = q.startAfterDocument(startAfterDoc);
    final snap = await q.limit(limit).get();
    return snap.docs.map((d) => Job.fromDoc(d)).toList();
  }

  // query snapshot stream for real-time updates (optional)
  Stream<List<Job>> jobsStream({int limit = 20}) {
    return _db
        .collection(jobsCol)
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Job.fromDoc(d)).toList());
  }

  // Future<bool> checkIsAdmin(String uid) async {
  //   final doc = await _db.collection(usersCol).doc(uid).get();
  //   if (!doc.exists) return false;
  //   final data = doc.data();
  //   if (data == null) return false;
  //   return data['isAdmin'] == true;
  // }
  Future<bool> checkIsAdmin(String uid) async {
    final doc = await _db.collection(usersCol).doc(uid).get();
    if (!doc.exists) return false;

    return doc["isAdmin"] == true;
  }

  Future<void> createUserRecord(
    String uid,
    String email, {
    bool isAdmin = false,
  }) async {
    await _db.collection(usersCol).doc(uid).set({
      'email': email,
      'isAdmin': isAdmin,
    }, SetOptions(merge: true));
  }
}
