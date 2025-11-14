import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:job_portel_application/models/job_model.dart';

class JobDetailScreen extends StatelessWidget {
  final Job job;
  const JobDetailScreen({required this.job, super.key});

  // Reusable card widget that hides if content is empty
  Widget buildFieldCard(
    IconData icon,
    String title,
    String? content,
    Color color,
  ) {
    if (content == null || content.trim().isEmpty)
      return const SizedBox.shrink();
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
      ),
    );
  }

  // Info Box for Work Location, Job Type, Experience Level
  Widget buildInfoBox(IconData icon, String text, Color color) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMMd();

    return Scaffold(
      // ---------------- BODY ----------------
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(job.title.toUpperCase()),
              background: Container(
                color: const Color.fromARGB(255, 68, 42, 236),
              ),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Company + Posted Date
                Text(
                  'Posted on: ${df.format(job.postedAt)}',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                if (job.company.isNotEmpty)
                  Text(
                    job.company,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 12),

                // Work Location, Job Type, Experience Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: buildInfoBox(
                        Icons.location_on,
                        job.workLocation ?? "Onsite",
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInfoBox(
                        Icons.schedule,
                        job.jobType ?? "Full-time",
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: buildInfoBox(
                        Icons.star,
                        job.experienceLevel ?? "Fresher",
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Salary
                buildFieldCard(
                  Icons.attach_money,
                  'Salary',
                  job.salary > 0 ? job.salary.toStringAsFixed(0) : null,
                  Colors.black,
                ),

                // Key Skills
                buildFieldCard(
                  Icons.engineering,
                  'Key Skills',
                  job.keyskill,
                  Colors.blue,
                ),

                // Requirements
                buildFieldCard(
                  Icons.check_circle,
                  'Requirements',
                  job.requirement,
                  Colors.green,
                ),

                // Job Description
                buildFieldCard(
                  Icons.description,
                  'Job Description',
                  job.description,
                  Colors.orange,
                ),

                const SizedBox(height: 120), // Space for Apply button
              ]),
            ),
          ),
        ],
      ),

      // ---------------- APPLY BUTTON ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              final recipientEmail =
                  job.email ??
                  'hr@${job.company.toLowerCase().replaceAll(' ', '')}.com';

              final emailUri = Uri(
                scheme: 'mailto',
                path: recipientEmail,
                queryParameters: {'subject': 'Application for ${job.title}'},
              );

              try {
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(
                    emailUri,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No email app installed')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            icon: const Icon(Icons.mail_outline, color: Colors.white),
            label: const Text(
              'Apply Now',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color.fromARGB(255, 68, 42, 236),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
