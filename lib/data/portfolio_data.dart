import 'package:flutter/material.dart';

import '../models/portfolio_state_model.dart';

class PortfolioData {
  static const String name = 'Anandhu Anil';
  static const String shortName = 'Anandhu';
  static const String initials = 'AA';
  static const String role = 'Computer Engineering Student & Flutter Developer';
  static const String location = 'Kerala, India';
  static const String email = 'anandhuanil.dev@gmail.com';
  static const String phone = '+91 XXXXX XXXXX';

  static const String githubUrl = 'https://github.com/AnandhuAnil';
  static const String linkedinUrl = 'https://linkedin.com/in/anandhuanil';
  static const String instagramUrl = 'https://instagram.com';
  static const String resumeUrl =
      'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';

  static const String headline =
      'I build responsive Flutter and web apps with clean UI, practical features, and reliable user flows.';

  static const String heroSummary =
      'A Computer Engineering student from Kerala focused on Flutter, Dart, React, Firebase, and full-stack web projects. I enjoy turning ideas into polished apps that are easy to use, easy to maintain, and ready to share with recruiters or teams.';

  static const String aboutOne =
      "I'm Anandhu Anil, a Computer Engineering student from Kerala, India. I work across mobile and web development, with a strong interest in Flutter, Dart, React, Firebase, and practical product design.";

  static const String aboutTwo =
      'This portfolio brings together my certificates, projects, skills, learning journey, contact details, and resume so recruiters and collaborators can understand my work quickly from one LinkedIn-pinned link.';

  static const List<Map<String, String>> quickFacts = [
    {'value': '10+', 'label': 'Projects Built'},
    {'value': '5+', 'label': 'Certificates'},
    {'value': '2+', 'label': 'Years Coding'},
  ];

  static const List<Map<String, dynamic>> skills = [
    {'name': 'Flutter', 'percentage': 0.90, 'icon': Icons.phone_android, 'color': Color(0xFF38BDF8)},
    {'name': 'Dart', 'percentage': 0.88, 'icon': Icons.gps_fixed, 'color': Color(0xFF00B4AB)},
    {'name': 'React', 'percentage': 0.82, 'icon': Icons.sync, 'color': Color(0xFF61DAFB)},
    {'name': 'Node.js', 'percentage': 0.75, 'icon': Icons.hub, 'color': Color(0xFF22C55E)},
    {'name': 'Firebase', 'percentage': 0.80, 'icon': Icons.local_fire_department, 'color': Color(0xFFFFCA28)},
    {'name': 'MongoDB', 'percentage': 0.70, 'icon': Icons.storage, 'color': Color(0xFF47A248)},
    {'name': 'JavaScript', 'percentage': 0.85, 'icon': Icons.javascript, 'color': Color(0xFFF7DF1E)},
    {'name': 'HTML', 'percentage': 0.92, 'icon': Icons.html, 'color': Color(0xFFE34F26)},
    {'name': 'CSS', 'percentage': 0.86, 'icon': Icons.css, 'color': Color(0xFF1572B6)},
    {'name': 'Git', 'percentage': 0.85, 'icon': Icons.device_hub, 'color': Color(0xFFF97316)},
    {'name': 'GitHub', 'percentage': 0.88, 'icon': Icons.code, 'color': Colors.white},
    {'name': 'REST APIs', 'percentage': 0.85, 'icon': Icons.lan, 'color': Color(0xFF14B8A6)},
  ];

  static final List<ProjectModel> projects = [
    ProjectModel(
      title: 'Hygieno',
      subtitle: 'Community Waste Management App',
      description:
          'A platform for citizens to request waste pickup, report issues, and help local administrative teams manage cleaner public spaces with faster follow-up.',
      technologies: const ['React', 'Node.js', 'MongoDB', 'CSS', 'Vercel'],
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

  static final List<CertificationModel> certifications = [
    CertificationModel(
      title: 'AI Prompting & Engineering Certificate',
      issuingOrganization: 'Google Cloud / Coursera',
      imageBase64: '',
      pdfBase64: '',
      pdfUrl: '',
      credentialUrl: 'https://coursera.org',
      date: 'Ongoing',
    ),
    CertificationModel(
      title: 'Flutter & Dart Course Completion',
      issuingOrganization: 'Udemy / London App Brewery',
      imageBase64: '',
      pdfBase64: '',
      pdfUrl: '',
      credentialUrl: 'https://udemy.com',
      date: 'Ongoing',
    ),
    CertificationModel(
      title: 'LinkedIn Learning Certificates',
      issuingOrganization: 'LinkedIn Learning',
      imageBase64: '',
      pdfBase64: '',
      pdfUrl: '',
      credentialUrl: 'https://linkedin.com',
      date: 'Ongoing',
    ),
    CertificationModel(
      title: 'Project Expo Participation Certificate',
      issuingOrganization: 'State Technical Expo Committee',
      imageBase64: '',
      pdfBase64: '',
      pdfUrl: '',
      credentialUrl: githubUrl,
      date: 'Ongoing',
    ),
  ];

  static const List<Map<String, dynamic>> experience = [
    {
      'title': 'Project Expo Participation',
      'subtitle': 'Innovation Showcase',
      'duration': 'Jan 2026',
      'description':
          'Presented Hygieno, a community waste management app, with a focus on citizen reporting, request tracking, and practical social impact.',
      'icon': Icons.lightbulb,
    },
    {
      'title': 'Technical Workshops',
      'subtitle': 'Continuous Learning',
      'duration': '2025 - 2026',
      'description':
          'Practiced modern app architecture, responsive UI, state management, Firebase workflows, and performance-minded web development.',
      'icon': Icons.person_pin,
    },
    {
      'title': 'AI Prompting Learning Journey',
      'subtitle': 'Generative AI Engineering',
      'duration': 'Late 2025',
      'description':
          'Studied structured prompting, context design, and AI-assisted development workflows for smarter software interfaces.',
      'icon': Icons.psychology,
    },
    {
      'title': 'Web Development Activities',
      'subtitle': 'Frontend and UI Design',
      'duration': '2024 - 2025',
      'description':
          'Built responsive websites and UI templates using HTML, CSS, JavaScript, layout systems, SEO basics, and clean visual hierarchy.',
      'icon': Icons.code,
    },
  ];
}
