import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
import 'utils/platform_helper.dart';
import 'widgets/admin/session_timeout_listener.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Custom Error Boundary recovery screen for unexpected rendering crashes
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('Flutter rendering error: ${details.exception}');
    debugPrint('Stacktrace: ${details.stack}');
    
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF151B2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 64),
                const SizedBox(height: 20),
                const Text(
                  'Application Exception',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A rendering error occurred. The details have been logged and you can reload the page to restore the state.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => reloadApp(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reload Portfolio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }
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
          print('[UI Rebuild] Consumer rebuilt. isLoading: ${stateProvider.isLoading}, certs count: ${stateProvider.isLoading ? 0 : stateProvider.state.certifications.length}, projects count: ${stateProvider.isLoading ? 0 : stateProvider.state.projects.length}');
          final String title = stateProvider.isLoading
              ? 'Portfolio'
              : '${stateProvider.state.profile.name} | ${stateProvider.state.profile.role}';

          return MaterialApp(
            title: title,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            initialRoute: '/',
            builder: (context, child) => SessionTimeoutListener(
              child: child ?? const SizedBox(),
            ),
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
