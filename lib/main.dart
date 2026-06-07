import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/portfolio_data.dart';
import 'theme/app_theme.dart';
import 'utils/scroll_controller_provider.dart';
import 'widgets/custom_app_bar.dart';
import 'widgets/custom_drawer.dart';

import 'sections/hero_section.dart';
import 'sections/about_section.dart';
import 'sections/skills_section.dart';
import 'sections/projects_section.dart';
import 'sections/certifications_section.dart';
import 'sections/experience_section.dart';
import 'sections/contact_section.dart';
import 'sections/footer_section.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScrollControllerProvider(),
      child: MaterialApp(
        title: '${PortfolioData.name} | ${PortfolioData.role}',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const PortfolioHome(),
      ),
    );
  }
}

class PortfolioHome extends StatelessWidget {
  const PortfolioHome({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollProvider = Provider.of<ScrollControllerProvider>(context, listen: false);

    // List of all portfolio sections matching the scroll provider indexes
    final List<Widget> sections = [
      const HeroSection(),
      const AboutSection(),
      const SkillsSection(),
      const ProjectsSection(),
      const CertificationsSection(),
      const ExperienceSection(),
      const ContactSection(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SingleChildScrollView(
          controller: scrollProvider.scrollController,
          child: Column(
            children: [
              // Map each section to a Container synced to navigation keys
              ...List.generate(sections.length, (index) {
                return Container(
                  key: scrollProvider.sectionKeys[index],
                  child: sections[index],
                );
              }),
              
              // Footer sits at the very bottom
              const FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}
