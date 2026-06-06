import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/portfolio_data.dart';
import '../models/project.dart';
import '../theme/app_theme.dart';
import '../widgets/project_card.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _selectedCategory = 'All';

  final List<Project> _allProjects = PortfolioData.projects;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    // Filter projects based on choice
    final filteredProjects = _selectedCategory == 'All'
        ? _allProjects
        : _allProjects.where((p) => p.category == _selectedCategory).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 36),
          
          // Filter Chips
          _buildFilterRow(),
          const SizedBox(height: 40),
          
          // Projects Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredProjects.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : (isTablet ? 2 : 1),
              mainAxisSpacing: 28,
              crossAxisSpacing: 28,
              childAspectRatio: isDesktop ? 0.85 : 0.95,
            ),
            itemBuilder: (context, index) {
              final project = filteredProjects[index];
              return ProjectCard(
                key: ValueKey('${project.title}_$_selectedCategory'),
                project: project,
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.easeOut);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.laptop, color: AppTheme.primary, size: 20),
            SizedBox(width: 10),
            Text(
              'PORTFOLIO PROJECTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 3,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: AppTheme.primaryGradient,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0, duration: 400.ms);
  }

  Widget _buildFilterRow() {
    final categories = [
      'All',
      ...PortfolioData.projects.map((project) => project.category).toSet(),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((category) {
        final isSelected = _selectedCategory == category;
        return ChoiceChip(
          label: Text(
            category,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() {
                _selectedCategory = category;
              });
            }
          },
          selectedColor: AppTheme.primary.withValues(alpha: 0.35),
          backgroundColor: const Color(0xFF1E293B).withValues(alpha: 0.6),
          checkmarkColor: Colors.white,
          side: BorderSide(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1.2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        );
      }).toList(),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }
}
