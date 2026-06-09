import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/certification_card.dart';
import '../utils/confirm_dialog.dart';

class CertificationsSection extends StatelessWidget {
  const CertificationsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final certifications = stateProvider.state.certifications;
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
          
          if (certifications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Text('No certifications added yet.', style: TextStyle(color: AppTheme.textSecondary)),
              ),
            )
          else
            // Responsive dynamic layout for Certificates
            Builder(
              builder: (context) {
                final int crossAxisCount = isDesktop ? 4 : (isTablet ? 2 : 1);
                final List<Widget> rows = [];
                for (int i = 0; i < certifications.length; i += crossAxisCount) {
                  final int end = (i + crossAxisCount < certifications.length)
                      ? i + crossAxisCount
                      : certifications.length;
                  final List<Widget> rowCards = [];
                  for (int j = i; j < end; j++) {
                    final cert = certifications[j];
                    final widgetCard = CertificationCard(
                      certification: cert,
                    ).animate().fadeIn(delay: (j * 75).ms, duration: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 300.ms);

                    Widget cardWithEdit = widgetCard;
                    if (stateProvider.editMode) {
                      cardWithEdit = Stack(
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
                                      builder: (context) => EditCertificationDialog(
                                        initialCert: cert,
                                        onSave: (c) => stateProvider.editCertification(j, c),
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
                                        title: 'Delete Certificate',
                                        content: 'Are you sure you want to delete the certificate "${cert.title}"? This action cannot be undone.',
                                      );
                                      if (confirmed) {
                                        stateProvider.deleteCertification(j);
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
                    rowCards.add(
                      Expanded(
                        child: cardWithEdit,
                      ),
                    );
                  }
                  
                  // Fill remaining spaces in the row to keep alignment
                  final int missing = crossAxisCount - rowCards.length;
                  for (int m = 0; m < missing; m++) {
                    rowCards.add(const Expanded(child: SizedBox()));
                  }
                  
                  // Add Spacing between elements in a row
                  final List<Widget> rowChildren = [];
                  for (int rIndex = 0; rIndex < rowCards.length; rIndex++) {
                    if (rIndex > 0) {
                      rowChildren.add(const SizedBox(width: 20));
                    }
                    rowChildren.add(rowCards[rIndex]);
                  }
                  
                  rows.add(
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: rowChildren,
                      ),
                    ),
                  );
                }
                
                // Add Spacing between rows in a column
                final List<Widget> columnChildren = [];
                for (int cIndex = 0; cIndex < rows.length; cIndex++) {
                  if (cIndex > 0) {
                    columnChildren.add(const SizedBox(height: 20));
                  }
                  columnChildren.add(rows[cIndex]);
                }
                
                return Column(
                  children: columnChildren,
                );
              }
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
            const Icon(Icons.emoji_events, color: AppTheme.secondary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'CERTIFICATIONS',
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
                  builder: (context) => EditCertificationDialog(
                    onSave: (c) => provider.addCertification(c),
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
