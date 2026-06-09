import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/timeline_item.dart';
import '../utils/confirm_dialog.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final timelineData = stateProvider.state.experience;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A).withValues(alpha: 0.4),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, stateProvider),
          const SizedBox(height: 24),
          
          if (timelineData.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('No experience records added yet.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            // Timeline list wrapper
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: timelineData.length,
              itemBuilder: (context, index) {
                final data = timelineData[index];
                
                final widgetCard = TimelineItem(
                  title: data.title,
                  subtitle: data.subtitle,
                  duration: data.duration,
                  description: data.description,
                  // ignore: non_const_argument_for_const_parameter
                  icon: IconData(data.iconCodePoint, fontFamily: data.iconFontFamily),
                  isLast: index == timelineData.length - 1,
                ).animate().fadeIn(delay: (index * 150).ms, duration: 500.ms).slideY(begin: 0.15, end: 0, duration: 500.ms);

                if (stateProvider.editMode) {
                  return Stack(
                    children: [
                      widgetCard,
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.cardBg,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.edit_rounded, size: 12, color: AppTheme.primary),
                                onPressed: () => showDialog<void>(
                                  context: context,
                                  barrierDismissible: false, // Prevent accidental dismiss and data loss
                                  builder: (context) => EditExperienceDialog(
                                    initialExperience: data,
                                    onSave: (e) => stateProvider.editExperience(index, e),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.cardBg,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_rounded, size: 12, color: Colors.redAccent),
                                onPressed: () async {
                                  final confirmed = await showConfirmDeleteDialog(
                                    context: context,
                                    title: 'Delete Experience',
                                    content: 'Are you sure you want to delete the experience item "${data.title}"? This action cannot be undone.',
                                  );
                                  if (confirmed) {
                                    stateProvider.deleteExperience(index);
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
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PortfolioStateProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'EXPERIENCE & ACHIEVEMENTS',
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
                  builder: (context) => EditExperienceDialog(
                    onSave: (e) => provider.addExperience(e),
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
}
