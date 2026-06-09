import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/skill_card.dart';
import 'package:provider/provider.dart';
import '../utils/confirm_dialog.dart';

class SkillsSection extends StatelessWidget {
  const SkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final skillsList = stateProvider.state.skills;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 1024;
    final isTablet = size.width >= 640 && size.width < 1024;

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, stateProvider),
          const SizedBox(height: 24),
          
          if (skillsList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('No skills added yet.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            // Responsive Skills Grid using Extent builder
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: skillsList.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: isDesktop ? 260 : 320,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: isDesktop ? 3.0 : (size.width < 480 ? 3.6 : 2.6),
              ),
              itemBuilder: (context, index) {
                final skill = skillsList[index];
                
                // Parse hex color safely
                Color accentColor;
                try {
                  accentColor = Color(int.parse(skill.colorHex));
                } catch (_) {
                  accentColor = AppTheme.primary;
                }

                final widgetCard = SkillCard(
                  name: skill.name,
                  // ignore: non_const_argument_for_const_parameter
                  icon: IconData(skill.iconCodePoint, fontFamily: skill.iconFontFamily),
                  accentColor: accentColor,
                ).animate().fadeIn(delay: (index * 50).ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));

                if (stateProvider.editMode) {
                  return Stack(
                    children: [
                      widgetCard,
                      Positioned(
                        top: 8,
                        right: 8,
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
                                  builder: (context) => EditSkillDialog(
                                    initialSkill: skill,
                                    onSave: (s) => stateProvider.editSkill(index, s),
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
                                    title: 'Delete Skill',
                                    content: 'Are you sure you want to delete the skill "${skill.name}"? This action cannot be undone.',
                                  );
                                  if (confirmed) {
                                    stateProvider.deleteSkill(index);
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
            const Icon(Icons.account_tree, color: AppTheme.secondary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'SKILLS & EXPERIENCE',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
                letterSpacing: 2,
              ),
            ),
            if (provider.editMode)
              EditSectionButton(
                onTap: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false, // Prevent accidental dismiss and data loss
                  builder: (context) => EditSkillDialog(
                    onSave: (s) => provider.addSkill(s),
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
