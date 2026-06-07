import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

import 'providers/portfolio_state_provider.dart';
import 'pages/admin_settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScrollControllerProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioStateProvider()),
      ],
      child: Consumer<PortfolioStateProvider>(
        builder: (context, stateProvider, child) {
          final String title = stateProvider.isLoading
              ? 'Portfolio'
              : '${stateProvider.state.profile.name} | ${stateProvider.state.profile.role}';

          return MaterialApp(
            title: title,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            initialRoute: '/',
            routes: {
              '/': (context) {
                if (stateProvider.isLoading) {
                  return const Scaffold(
                    backgroundColor: AppTheme.background,
                    body: Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    ),
                  );
                }
                return const PortfolioHome();
              },
              '/admin': (context) => const AdminSettingsPage(),
            },
          );
        },
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
