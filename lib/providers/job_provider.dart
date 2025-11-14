import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:job_portel_application/models/job_model.dart';
import 'package:job_portel_application/services/firebase+_service.dart';

class JobProvider extends ChangeNotifier {
  final FirebaseService _fs = FirebaseService();

  List<Job> jobs = [];
  bool loading = false;
  DocumentSnapshot? lastDoc;
  bool hasMore = true;

  // Filters / search state
  String searchQuery = '';
  String selectedCategory = 'All';
  String sortBy = 'recent';
  // fetch initial
  Future<void> loadInitial({int limit = 10}) async {
    loading = true;
    //notifyListeners();
    final snap = await FirebaseFirestore.instance
        .collection(_fs.jobsCol)
        .orderBy('postedAt', descending: true)
        .limit(limit)
        .get();
    jobs = snap.docs.map((d) => Job.fromDoc(d)).toList();
    if (snap.docs.isNotEmpty) lastDoc = snap.docs.last;
    hasMore = snap.docs.length == limit;
    loading = false;
    notifyListeners();
  }

  // Pagination
  Future<void> loadMore({int limit = 10}) async {
    if (!hasMore) return;
    loading = true;
    notifyListeners();
    Query q = FirebaseFirestore.instance
        .collection(_fs.jobsCol)
        .orderBy('postedAt', descending: true);
    if (lastDoc != null)
      q = q.startAfterDocument(lastDoc!).limit(limit);
    else
      q = q.limit(limit);
    final snap = await q.get();
    final newJobs = snap.docs.map((d) => Job.fromDoc(d)).toList();
    jobs.addAll(newJobs);
    if (snap.docs.isNotEmpty) lastDoc = snap.docs.last;
    hasMore = newJobs.length == limit;
    loading = false;
    notifyListeners();
  }

  // Create/Update/Delete
  Future<void> upsertJob(Job job) async {
    await _fs.upsertJob(job);
    await refresh();
  }

  Future<void> deleteJob(String id) async {
    await _fs.deleteJob(id);
    jobs.removeWhere((j) => j.id == id);
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadInitial();
  }

  // ----- Algorithms -----

  // 1) Simple search + relevance scoring (title + company + tags)
  List<Job> searchAndRank(String query) {
    if (query.trim().isEmpty) return jobs;
    final q = query.toLowerCase();
    List<MapEntry<Job, double>> scored = jobs
        .map((job) {
          double score = 0.0;
          if (job.title.toLowerCase().contains(q)) score += 5.0;
          if (job.company.toLowerCase().contains(q)) score += 3.0;
          if (job.description.toLowerCase().contains(q)) score += 1.0;
          for (var t in job.tags) if (t.toLowerCase().contains(q)) score += 2.0;
          return MapEntry(job, score);
        })
        .where((e) => e.value > 0)
        .toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  // 2) Filter and Sort
  List<Job> filterAndSort({String category = 'All', String sort = 'recent'}) {
    List<Job> list = List.from(jobs);
    if (category != 'All')
      list = list.where((j) => j.category == category).toList();

    if (sort == 'recent') {
      list.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    } else if (sort == 'salary_high') {
      list.sort((a, b) => b.salary.compareTo(a.salary));
    } else if (sort == 'salary_low') {
      list.sort((a, b) => a.salary.compareTo(b.salary));
    }
    return list;
  }
}
