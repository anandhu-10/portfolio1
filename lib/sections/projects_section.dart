import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/portfolio_state_model.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/project_card.dart';
import '../utils/confirm_dialog.dart';

class ProjectsSection extends StatefulWidget {
  const ProjectsSection({super.key});

  @override
  State<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends State<ProjectsSection> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final projects = stateProvider.state.projects;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    // Filter projects based on choice
    final filteredProjects = _selectedCategory == 'All'
        ? projects
        : projects.where((p) => p.category == _selectedCategory).toList();

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, stateProvider),
          const SizedBox(height: 24),
          
          // Filter Chips
          _buildFilterRow(projects),
          const SizedBox(height: 24),
          
          if (filteredProjects.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  'No projects found.',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            )
          else
            // Layout switcher: ListView for mobile, GridView for tablet/desktop
            (!isDesktop && !isTablet)
                ? ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProjects.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 24),
                    itemBuilder: (context, index) => _buildProjectItem(
                      context: context,
                      project: filteredProjects[index],
                      projects: projects,
                      globalIndex: projects.indexOf(filteredProjects[index]),
                      stateProvider: stateProvider,
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProjects.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 3 : 2,
                      mainAxisSpacing: 28,
                      crossAxisSpacing: 28,
                      childAspectRatio: isDesktop ? 0.85 : 0.88,
                    ),
                    itemBuilder: (context, index) => _buildProjectItem(
                      context: context,
                      project: filteredProjects[index],
                      projects: projects,
                      globalIndex: projects.indexOf(filteredProjects[index]),
                      stateProvider: stateProvider,
                    ),
                  ),
        ],
      ),
    );
  }

  Widget _buildProjectItem({
    required BuildContext context,
    required ProjectModel project,
    required List<ProjectModel> projects,
    required int globalIndex,
    required PortfolioStateProvider stateProvider,
  }) {
    final widgetCard = ProjectCard(
      key: ValueKey('${project.title}_$_selectedCategory'),
      project: project,
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.easeOut);

    if (stateProvider.editMode) {
      return Stack(
        children: [
          widgetCard,
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.cardBg,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.edit_rounded, size: 14, color: AppTheme.primary),
                    onPressed: () => showDialog<void>(
                      context: context,
                      barrierDismissible: false, // Prevent accidental dismiss and data loss
                      builder: (context) => EditProjectDialog(
                        initialProject: project,
                        onSave: (p) => stateProvider.editProject(globalIndex, p),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.cardBg,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.delete_rounded, size: 14, color: Colors.redAccent),
                    onPressed: () async {
                      final confirmed = await showConfirmDeleteDialog(
                        context: context,
                        title: 'Delete Project',
                        content: 'Are you sure you want to delete "${project.title}"? This action cannot be undone.',
                      );
                      if (confirmed && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Deleting project from Firestore...')),
                        );
                        try {
                          await stateProvider.deleteProject(globalIndex);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Project deleted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete project: ${e.toString()}'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return widgetCard;
  }

  Widget _buildHeader(BuildContext context, PortfolioStateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.laptop, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'PORTFOLIO PROJECTS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
                letterSpacing: 2,
              ),
            ),
            if (provider.editMode)
              EditSectionButton(
                onTap: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false, // Prevent accidental dismiss and data loss
                  builder: (context) => EditProjectDialog(
                    onSave: (p) => provider.addProject(p),
                  ),
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

  Widget _buildFilterRow(List<ProjectModel> projects) {
    final categories = [
      'All',
      ...projects.map((project) => project.category).toSet(),
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
