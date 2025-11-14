import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import 'package:job_portel_application/models/job_model.dart';

class JobFormScreen extends StatefulWidget {
  final Job? editJob;
  const JobFormScreen({this.editJob, super.key});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _title = TextEditingController();
  final _keyskill = TextEditingController();
  final _requirement = TextEditingController();
  final _company = TextEditingController();
  final _desc = TextEditingController();
  final _location = TextEditingController();
  final _salary = TextEditingController();
  final _email = TextEditingController();

  String category = 'Engineering';
  List<String> tags = [];
  final _tagCtrl = TextEditingController();

  // New fields
  String jobType = 'Full-time';
  String workLocation = 'Onsite';
  String experienceLevel = 'Fresher';

  @override
  void initState() {
    super.initState();
    if (widget.editJob != null) {
      final j = widget.editJob!;
      _title.text = j.title;
      _company.text = j.company;
      _desc.text = j.description;
      _location.text = j.location;
      _requirement.text = j.requirement;
      _keyskill.text = j.keyskill;
      _salary.text = j.salary.toString();
      _email.text = j.email;
      category = j.category;
      tags = List.from(j.tags);
      jobType = j.jobType;
      workLocation = j.workLocation;
      experienceLevel = j.experienceLevel;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProv = Provider.of<JobProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editJob == null ? 'Create Job' : 'Edit Job'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Job Basic Info
            _buildCardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_title, 'Job Title'),
                  _buildTextField(_company, 'Company'),
                  _buildTextField(_location, 'Location'),
                  DropdownButtonFormField<String>(
                    value: category,
                    items:
                        [
                              'Engineering',
                              'Design',
                              'Banking/Finance',
                              'INGO/NGO/Teaching',
                              'Guider',
                              'Hospital',
                              'Developer',
                              'Sales',
                              'Product',
                              'Other',
                            ]
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() {
                      category = v ?? 'Engineering';
                    }),
                    decoration: _inputDecoration('Category'),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _salary,
                    'Salary',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _email,
                    'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Job Description Info
            _buildCardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_keyskill, 'Key Skills', maxLines: 3),
                  _buildTextField(_requirement, 'Requirements', maxLines: 3),
                  _buildTextField(_desc, 'Job Description', maxLines: 5),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Job Type / Work Location / Experience Level
            _buildCardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: jobType,
                    items: ['Full-time', 'Part-time', 'Contract']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => jobType = v ?? 'Full-time'),
                    decoration: _inputDecoration('Job Type'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: workLocation,
                    items: ['Onsite', 'Remote', 'Hybrid']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => workLocation = v ?? 'Onsite'),
                    decoration: _inputDecoration('Work Location'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: experienceLevel,
                    items: ['Fresher', 'Mid', 'Senior']
                        .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => experienceLevel = v ?? 'Fresher'),
                    decoration: _inputDecoration('Experience Level'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tags Section
            _buildCardSection(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tags',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Add a tag',
                            filled: true,
                            fillColor: Color(0xFFEFEFEF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          final t = _tagCtrl.text.trim();
                          if (t.isNotEmpty) {
                            setState(() {
                              tags.add(t);
                            });
                            _tagCtrl.clear();
                          }
                        },
                        icon: const Icon(Icons.add, color: Colors.purple),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: tags
                        .map(
                          (t) => Chip(
                            backgroundColor: Colors.purple.withOpacity(0.2),
                            label: Text(
                              t,
                              style: const TextStyle(color: Colors.purple),
                            ),
                            onDeleted: () {
                              setState(() {
                                tags.remove(t);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Create / Update Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color.fromARGB(255, 77, 101, 236),
              ),
              onPressed: () async {
                final title = _title.text.trim();
                if (title.isEmpty) return;

                final job = Job(
                  id: widget.editJob?.id ?? '',
                  title: title,
                  company: _company.text.trim(),
                  description: _desc.text.trim(),
                  location: _location.text.trim(),
                  category: category,
                  salary: double.tryParse(_salary.text.trim()) ?? 0,
                  postedAt: DateTime.now(),
                  tags: tags,
                  isActive: true,
                  keyskill: _keyskill.text.trim(),
                  requirement: _requirement.text.trim(),
                  email: _email.text.trim(),
                  jobType: jobType,
                  workLocation: workLocation,
                  experienceLevel: experienceLevel,
                );
                await jobProv.upsertJob(job);
                Navigator.pop(context);
              },
              child: Text(
                widget.editJob == null ? 'Create Job' : 'Update Job',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for TextFields
  Widget _buildTextField(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
      ),
    );
  }

  // Input Decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color.fromARGB(255, 246, 235, 235),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  // Card section with padding and shadow
  Widget _buildCardSection({required Widget child}) {
    return Card(
      elevation: 6,
      shadowColor: const Color.fromARGB(255, 41, 86, 222).withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}
