import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:job_portel_application/models/job_model.dart';

class JobDetailScreenAdmin extends StatelessWidget {
  final Job job;
  const JobDetailScreenAdmin({required this.job, super.key});

  // 🔹 Reusable Card Builder
  Widget buildInfoCard(String title, String? content, IconData icon) {
    if (content == null || content.trim().isEmpty) return SizedBox.shrink();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMMd();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
        backgroundColor: const Color.fromARGB(255, 68, 42, 236),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Job Title
            Text(
              job.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // 🔹 Posted Date
            Text(
              "Posted on: ${df.format(job.postedAt)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // 🔹 Company
            buildInfoCard("Company", job.company, Icons.business),

            // 🔹 Location
            buildInfoCard("Location", job.location, Icons.location_on),

            // 🔹 Work Location (Onsite / Remote / Hybrid)
            buildInfoCard(
              "Work Location",
              job.workLocation,
              Icons.location_city,
            ),

            // 🔹 Job Type (Full-time / Part-time / Contract)
            buildInfoCard("Job Type", job.jobType, Icons.schedule),

            // 🔹 Experience Level (Fresher / Mid / Senior)
            buildInfoCard("Experience Level", job.experienceLevel, Icons.star),

            // 🔹 Category
            buildInfoCard("Category", job.category, Icons.work),

            // 🔹 Salary
            buildInfoCard(
              "Salary",
              job.salary > 0 ? "Rs. ${job.salary.toStringAsFixed(0)}" : null,
              Icons.monetization_on,
            ),

            // 🔹 Key Skills
            buildInfoCard("Key Skills", job.keyskill, Icons.engineering),

            // 🔹 Requirements
            buildInfoCard(
              "Requirements",
              job.requirement,
              Icons.check_circle_outline,
            ),

            // 🔹 Job Description
            buildInfoCard(
              "Job Description",
              job.description,
              Icons.description_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
