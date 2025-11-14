import 'package:flutter/material.dart';
import '../admin/admin_dashboard.dart';
import 'package:provider/provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:job_portel_application/widget/%20job_tile.dart';
import 'package:job_portel_application/screen/auth/login_screen.dart';
import 'package:job_portel_application/screen/user/%20job_detail_screen.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final PageController _pageController = PageController();

  int currentSlide = 0;
  String? selectedJobType;
  String? selectedExperience;
  String? selectedLocation;
  String? selectedSalaryRange;

  List<String> sliderTexts = [
    "Find Your Dream Job Today!",
    "Top Companies Are Hiring Now",
    "Boost Your Career with the Right Opportunity",
    "Simple Search. Better Results.",
    "Apply Smarter, Not Harder.",
  ];

  List<String> jobTypes = ['Full-time', 'Part-time', 'Contract'];
  List<String> experienceLevels = ['Fresher', 'Mid', 'Senior'];
  List<String> locations = ['Onsite', 'Remote', 'Hybrid'];
  List<String> salaryRanges = ['0-10000', '10000-50000', '50000+'];

  @override
  void initState() {
    super.initState();
    final jp = Provider.of<JobProvider>(context, listen: false);
    jp.loadInitial();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >
          _scrollCtrl.position.maxScrollExtent - 200) {
        jp.loadMore();
      }
    });

    Future.delayed(const Duration(milliseconds: 600), autoSlide);
  }

  void autoSlide() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      currentSlide = (currentSlide + 1) % sliderTexts.length;
      _pageController.animateToPage(
        currentSlide,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      autoSlide();
    });
  }

  List<dynamic> _applyFilters(List<dynamic> jobs) {
    final filteredJobs = jobs.where((job) {
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch =
          job.title.toLowerCase().contains(query) ||
          job.company.toLowerCase().contains(query) ||
          job.location.toLowerCase().contains(query);

      final matchesJobType =
          selectedJobType == null || job.jobType == selectedJobType;
      final matchesExperience =
          selectedExperience == null ||
          job.experienceLevel == selectedExperience;
      final matchesLocation =
          selectedLocation == null || job.workLocation == selectedLocation;

      final matchesSalary =
          selectedSalaryRange == null ||
          (selectedSalaryRange == '0-10000' && job.salary <= 10000) ||
          (selectedSalaryRange == '10000-50000' &&
              job.salary > 10000 &&
              job.salary <= 50000) ||
          (selectedSalaryRange == '50000+' && job.salary > 50000);

      return matchesSearch &&
          matchesJobType &&
          matchesExperience &&
          matchesLocation &&
          matchesSalary;
    }).toList();

    return filteredJobs;
  }

  @override
  Widget build(BuildContext context) {
    final jp = Provider.of<JobProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    final filteredJobs = _applyFilters(jp.jobs);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          if (auth.userModel?.isAdmin == true)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboard()),
                );
              },
              icon: const Icon(Icons.admin_panel_settings),
            ),
          PopupMenuButton(
            icon: const Icon(Icons.menu, size: 28),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        auth.userModel?.email ?? 'No Email',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'logout') {
                auth.signOut();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Logged out successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search jobs, companies, tags...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
              onChanged: (v) => setState(() {}),
            ),
          ),

          // Filters + Salary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        'Job Type',
                        jobTypes,
                        selectedJobType,
                        (val) => setState(() => selectedJobType = val),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: _buildDropdown(
                        'Location',
                        locations,
                        selectedLocation,
                        (val) => setState(() => selectedLocation = val),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDropdown(
                        'Experience',
                        experienceLevels,
                        selectedExperience,
                        (val) => setState(() => selectedExperience = val),
                      ),
                    ),
                    const SizedBox(width: 8),

                    Expanded(
                      child: _buildDropdown(
                        'Salary',
                        salaryRanges,
                        selectedSalaryRange,
                        (val) => setState(() => selectedSalaryRange = val),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Slider Section
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _pageController,
              itemCount: sliderTexts.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      sliderTexts[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Job List
          Expanded(
            child: RefreshIndicator(
              color: Colors.purple,
              onRefresh: () => jp.refresh(),
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: filteredJobs.length + (jp.hasMore ? 1 : 0),
                itemBuilder: (context, idx) {
                  if (idx >= filteredJobs.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final job = filteredJobs[idx];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailScreen(job: job),
                        ),
                      ),
                      child: Card(
                        elevation: 5,
                        shadowColor: Colors.purple.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              JobTile(job: job),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _infoBox(
                                    Icons.location_on,
                                    job.workLocation ?? "Onsite",
                                    Colors.blue,
                                  ),
                                  _infoBox(
                                    Icons.schedule,
                                    job.jobType ?? "Full-time",
                                    Colors.green,
                                  ),
                                  _infoBox(
                                    Icons.star,
                                    job.experienceLevel ?? "Fresher",
                                    Colors.orange,
                                  ),
                                  _infoBox(
                                    Icons.monetization_on,
                                    "${job.salary.toStringAsFixed(0)}",
                                    Colors.purple,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoBox(IconData icon, String text, Color color) {
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
          const SizedBox(width: 4),
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

  Widget _buildDropdown(
    String hint,
    List<String> options,
    String? selected,
    Function(String?) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: selected,
        hint: Text(hint),
        underline: const SizedBox(),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
