import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:job_portel_application/models/job_model.dart';

class JobTile extends StatelessWidget {
  final Job job;
  const JobTile({required this.job, super.key});

  // Map categories to images from the web
  String getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'engineering':
        return 'https://img.icons8.com/color/96/000000/engineer.png';
      case 'design':
        return 'https://img.icons8.com/color/96/000000/graphic-design.png';
      case 'banking/finance':
        return 'https://img.icons8.com/color/96/000000/bank.png';
      case 'ingo/ngo/teaching':
        return 'https://img.icons8.com/color/96/000000/teacher.png';
      case 'developer':
        return 'https://img.icons8.com/color/96/000000/source-code.png';
      case 'sales':
        return 'https://img.icons8.com/color/96/000000/sales-performance.png';
      case 'product':
        return 'https://img.icons8.com/color/96/000000/product.png';
      case 'guider':
        return 'https://img.icons8.com/color/96/000000/compass.png';
      case 'hospital':
        return 'https://img.icons8.com/color/96/000000/hospital-room.png';
      default:
        return 'https://img.icons8.com/color/96/000000/job.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMEd();

    List<Widget> infoWidgets = [];

    if (job.title.isNotEmpty) {
      infoWidgets.add(
        Text(
          job.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );
      infoWidgets.add(const SizedBox(height: 6));
    }

    if (job.company.isNotEmpty) {
      infoWidgets.add(Text(job.company, style: const TextStyle(fontSize: 14)));
      infoWidgets.add(const SizedBox(height: 6));
    }

    if (job.location.isNotEmpty || job.category.isNotEmpty) {
      String locCat = '';
      if (job.location.isNotEmpty) locCat += job.location;
      if (job.location.isNotEmpty && job.category.isNotEmpty) locCat += ' • ';
      if (job.category.isNotEmpty) locCat += job.category;

      infoWidgets.add(
        Text(locCat, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      );
      infoWidgets.add(const SizedBox(height: 8));
    }

    if (job.tags.isNotEmpty) {
      infoWidgets.add(
        Wrap(
          spacing: 6,
          children: job.tags
              .take(3)
              .map(
                (t) =>
                    Chip(label: Text(t, style: const TextStyle(fontSize: 12))),
              )
              .toList(),
        ),
      );
      infoWidgets.add(const SizedBox(height: 8));
    }

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                getCategoryImage(job.category),
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.work, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Job info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: infoWidgets,
              ),
            ),
            // Salary & date
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // if (job.salary > 0)
                //   Text(
                //     '${job.salary.toStringAsFixed(0)} Npr',
                //     style: const TextStyle(fontWeight: FontWeight.bold),
                //   ),
                // if (job.salary > 0) const SizedBox(height: 8),
                Text(
                  df.format(job.postedAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
