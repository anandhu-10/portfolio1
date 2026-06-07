import 'package:flutter/material.dart';

import '../models/portfolio_state_model.dart';
import 'certification_data.dart';

class PortfolioData {
  static const String name = 'Anandhu Anil';
  static const String shortName = 'Anandhu';
  static const String initials = 'AA';
  static const String role = 'Aspiring Software Engineer | Flutter & Web Developer';
  static const String location = 'Changanacherry, Kerala, India';
  static const String email = 'anandhuanil.dev@gmail.com';
  static const String phone = '+91 XXXXX XXXXX';

  static const String githubUrl = 'https://github.com/AnandhuAnil';
  static const String linkedinUrl = 'https://www.linkedin.com/in/anandhu-anil-936324325/';
  static const String instagramUrl = 'https://instagram.com';
  static const String resumeUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  static const String headline =
      '🚀 Aspiring Software Engineer | Flutter Developer | Full-Stack Web Developer | AI & Cloud Computing Enthusiast | Open to Learning & Innovation';

  static const String heroSummary =
      'Computer Engineering student at APJ Abdul Kalam Technological University (KTU) focused on Flutter, React, Node.js, Firebase, Cloud Computing, and Generative AI. I love building clean, functional applications and exploring next-generation technologies.';

  static const String aboutOne =
      "I'm Anandhu Anil, an Aspiring Software Engineer and Computer Engineering student at APJ Abdul Kalam Technological University (KTU). I build cross-platform mobile apps, responsive full-stack websites, and integrate cloud and AI solutions.";

  static const String aboutTwo =
      'Through academic events like CodeCraft 2.0 and conclaves on Generative AI, I continuously expand my practical skills. This portfolio brings together my projects, certifications, and technical experience to show my growth and readiness for collaborative development teams.';

  static const String educationDegree = 'Degree / Diploma in Computer Engineering';
  static const String educationOrg = 'APJ Abdul Kalam Technological University (KTU)';
  static const String educationDuration = 'Ongoing';
  static const String careerGoals = 'To excel as a software engineer, building scalable mobile and web applications while incorporating AI and cloud-native solutions to solve real-world community problems.';

  static const List<Map<String, String>> quickFacts = [
    {'value': '10+', 'label': 'Projects Built'},
    {'value': '8+', 'label': 'Certifications'},
    {'value': '2+', 'label': 'Years Coding'},
  ];

  static const List<Map<String, dynamic>> skills = [
    {'name': 'Flutter', 'percentage': 0.90, 'icon': Icons.phone_android, 'color': Color(0xFF38BDF8)},
    {'name': 'Python', 'percentage': 0.85, 'icon': Icons.terminal, 'color': Color(0xFF3776AB)},
    {'name': 'React.js', 'percentage': 0.85, 'icon': Icons.sync, 'color': Color(0xFF61DAFB)},
    {'name': 'Node.js', 'percentage': 0.80, 'icon': Icons.hub, 'color': Color(0xFF22C55E)},
    {'name': 'MongoDB', 'percentage': 0.75, 'icon': Icons.storage, 'color': Color(0xFF47A248)},
    {'name': 'Firebase', 'percentage': 0.80, 'icon': Icons.local_fire_department, 'color': Color(0xFFFFCA28)},
    {'name': 'Cloud Computing', 'percentage': 0.80, 'icon': Icons.cloud, 'color': Color(0xFF0080FF)},
    {'name': 'Generative AI', 'percentage': 0.80, 'icon': Icons.psychology, 'color': Color(0xFF9E00FF)},
    {'name': 'GitHub', 'percentage': 0.88, 'icon': Icons.code, 'color': Colors.white},
  ];

  static final List<ProjectModel> projects = [
    ProjectModel(
      title: 'Hygieno',
      subtitle: 'Community Waste Management App',
      description:
          'A full-stack platform for citizens to request waste pickup, report issues, and help local administrative teams manage cleaner spaces. Built with React.js, Node.js, MongoDB, Vercel V0, and custom CSS.',
      technologies: const ['ReactJS', 'NodeJS', 'MongoDB', 'Vercel V0', 'CSS'],
      imageBase64: '',
      githubUrl: githubUrl,
      liveUrl: 'https://hygieno-waste.vercel.app',
      category: 'Full Stack',
    ),
    ProjectModel(
      title: 'Haritha Karma Sena Web',
      subtitle: 'Waste Management Awareness Portal',
      description:
          'A responsive awareness portal for waste segregation, local schedules, service information, and community education around responsible disposal.',
      technologies: const ['HTML', 'CSS', 'JavaScript', 'Responsive UI'],
      imageBase64: '',
      githubUrl: githubUrl,
      liveUrl: 'https://haritha-karma.vercel.app',
      category: 'Web',
    ),
    ProjectModel(
      title: 'EduSphere',
      subtitle: 'Student Collaboration Dashboard',
      description:
          'A Flutter app concept for attendance, task tracking, notices, resources, and student productivity workflows with Firebase-ready architecture.',
      technologies: const ['Flutter', 'Dart', 'Firebase', 'Provider', 'Material 3'],
      imageBase64: '',
      githubUrl: githubUrl,
      liveUrl: githubUrl,
      category: 'Flutter',
    ),
  ];

  static final List<CertificationModel> certifications = CertificationData.list;

  static const List<Map<String, dynamic>> experience = [
    {
      'title': 'CodeCraft 2.0 Python Event',
      'subtitle': 'Participant & Competitor',
      'duration': '2026',
      'description':
          'Built Python scripting solutions and solved programming fundamental challenges under speed constraints, showcasing logic and core coding capabilities.',
      'icon': Icons.code,
    },
    {
      'title': 'Generative AI Conclave',
      'subtitle': 'International Conclave Participant',
      'duration': '2025',
      'description':
          'Explored the future of Generative AI applications and Education 3.0 paradigms, studying practical integration methods and prompting schemas.',
      'icon': Icons.psychology,
    },
    {
      'title': 'Cloud Computing Pacelab',
      'subtitle': 'Hands-on Cloud Training',
      'duration': '2025',
      'description':
          'Studied cloud architectures, hosting configurations, serverless environments, and storage systems through practical labs.',
      'icon': Icons.cloud,
    },
    {
      'title': 'Full-Stack Waste Management Project',
      'subtitle': 'Hygieno Project Developer',
      'duration': '2025 - 2026',
      'description':
          'Implemented the backend and frontend for the Hygieno trash tracking app using React.js, Node.js, MongoDB, Vercel, and custom CSS.',
      'icon': Icons.delete_outline,
    },
  ];
}
