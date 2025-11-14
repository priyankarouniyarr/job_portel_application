import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String description;
  final String location; // e.g., "Kathmandu, Nepal"
  final String category; // e.g., "Engineering"
  final double salary;
  final String keyskill;
  final String requirement;
  final DateTime postedAt;
  final List<String> tags;
  final bool isActive;
  final String email;

  // New fields
  final String jobType; // Full-time, Part-time, Contract
  final String workLocation; // Onsite, Remote, Hybrid
  final String experienceLevel; // Fresher, Mid, Senior

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.description,
    required this.location,
    required this.category,
    required this.salary,
    required this.keyskill,
    required this.requirement,
    required this.postedAt,
    required this.tags,
    required this.email,
    required this.isActive,
    required this.jobType,
    required this.workLocation,
    required this.experienceLevel,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'email': email,
      'company': company,
      'description': description,
      'location': location,
      'category': category,
      'salary': salary,
      'postedAt': Timestamp.fromDate(postedAt),
      'tags': tags,
      'keyskill': keyskill,
      'requirement': requirement,
      'isActive': isActive,
      'jobType': jobType,
      'workLocation': workLocation,
      'experienceLevel': experienceLevel,
    };
  }

  factory Job.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      company: data['company'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? '',
      salary: (data['salary'] ?? 0).toDouble(),
      keyskill: data['keyskill'] ?? '',
      requirement: data['requirement'] ?? '',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      tags: List<String>.from(data['tags'] ?? []),
      email: data['email'] ?? '',
      isActive: data['isActive'] ?? true,
      jobType: data['jobType'] ?? 'Full-time',
      workLocation: data['workLocation'] ?? 'Onsite',
      experienceLevel: data['experienceLevel'] ?? 'Fresher',
    );
  }
}
