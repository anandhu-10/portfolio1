import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/portfolio_state_model.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';
import '../widgets/admin/edit_dialogs.dart';
import '../widgets/glass_container.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  Future<void> _submitForm(String recipientEmail, String recipientName) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      final uri = Uri(
        scheme: 'mailto',
        path: recipientEmail,
        queryParameters: {
          'subject': 'Portfolio enquiry from ${_nameController.text.trim()}',
          'body': '''
Hi $recipientName,

${_messageController.text.trim()}

Sender name: ${_nameController.text.trim()}
Sender email: ${_emailController.text.trim()}
''',
        },
      );

      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surface,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Opening your email app. Send the draft to reach $recipientName.',
                    style: const TextStyle(color: AppTheme.textPrimary, fontFamily: 'Outfit'),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              side: BorderSide(color: AppTheme.primary, width: 1),
            ),
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _messageController.clear();
      } finally {
        if (mounted) setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<PortfolioStateProvider>(context);
    final contact = stateProvider.state.contact;
    final profile = stateProvider.state.profile;
    final size = MediaQuery.of(context).size;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    final horizontalPadding = isDesktop ? size.width * 0.08 : (isTablet ? 48.0 : 24.0);
    final verticalPadding = isDesktop ? 100.0 : (isTablet ? 80.0 : 60.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, stateProvider, contact),
          const SizedBox(height: 48),
          
          ResponsiveLayout(
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: _buildContactInfo(contact),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 6,
                  child: _buildContactFormCard(contact.email, profile.name),
                ),
              ],
            ),
            tablet: Column(
              children: [
                _buildContactInfo(contact),
                const SizedBox(height: 36),
                _buildContactFormCard(contact.email, profile.name),
              ],
            ),
            mobile: Column(
              children: [
                _buildContactInfo(contact),
                const SizedBox(height: 32),
                _buildContactFormCard(contact.email, profile.name),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, PortfolioStateProvider provider, ContactModel contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.send, color: AppTheme.secondary, size: 20),
            const SizedBox(width: 10),
            const Text(
              'GET IN TOUCH',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondary,
                letterSpacing: 2,
              ),
            ),
            if (provider.editMode)
              EditSectionButton(
                onTap: () => showDialog(
                  context: context,
                  builder: (context) => EditContactDialog(
                    initialContact: contact,
                    onSave: (c) => provider.updateContact(c),
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

  Widget _buildContactInfo(ContactModel contact) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Let's Discuss Something Great",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Outfit',
            height: 1.2,
          ),
        ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
        const SizedBox(height: 16),
        const Text(
          'I am open to web development, mobile app work, collaborations, open-source projects, and developer internship opportunities. Use the form to open a ready-to-send email, or reach me through my social links.',
          style: TextStyle(
            fontSize: 14.5,
            color: AppTheme.textSecondary,
            height: 1.6,
          ),
        ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
        const SizedBox(height: 32),
        
        // Info lines
        _buildInfoTile(
          icon: Icons.mail,
          title: 'Email Me',
          content: contact.email,
          onTap: () => _launchUrl('mailto:${contact.email}'),
        ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),
        
        _buildInfoTile(
          icon: Icons.phone,
          title: 'Phone',
          content: contact.phone,
          onTap: () => _launchUrl('tel:${contact.phone.replaceAll(' ', '')}'),
        ).animate().fadeIn(delay: 450.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
        const SizedBox(height: 16),

        _buildInfoTile(
          icon: Icons.location_on,
          title: 'Location',
          content: contact.location,
          onTap: () {},
        ).animate().fadeIn(delay: 550.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
        
        const SizedBox(height: 32),
        
        // Social Media Buttons Row
        Row(
          children: [
            if (contact.linkedinUrl.isNotEmpty) ...[
              _buildSocialIcon(Icons.link, contact.linkedinUrl, 'LinkedIn'),
              const SizedBox(width: 14),
            ],
            if (contact.githubUrl.isNotEmpty) ...[
              _buildSocialIcon(Icons.code, contact.githubUrl, 'GitHub'),
              const SizedBox(width: 14),
            ],
            if (contact.instagramUrl.isNotEmpty)
              _buildSocialIcon(Icons.camera_alt, contact.instagramUrl, 'Instagram'),
          ],
        ).animate().fadeIn(delay: 650.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 0.8),
              ),
              child: Icon(icon, size: 18, color: AppTheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url, String label) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: AppTheme.textSecondary),
        onPressed: () => _launchUrl(url),
        hoverColor: AppTheme.primary.withValues(alpha: 0.12),
        splashRadius: 22,
        tooltip: label,
      ),
    );
  }

  Widget _buildContactFormCard(String recipientEmail, String recipientName) {
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send Me a Message',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 24),
            
            // Name Field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your name';
                return null;
              },
            ),
            const SizedBox(height: 18),
            
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please enter your email';
                final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                if (!regex.hasMatch(val.trim())) return 'Please enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 18),
            
            // Message Field
            TextFormField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'How can I help you?',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 80.0),
                  child: Icon(Icons.message_outlined, size: 20),
                ),
                alignLabelWithHint: true,
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) return 'Please write your message';
                return null;
              },
            ),
            const SizedBox(height: 28),
            
            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: AppTheme.primaryGradient,
                  boxShadow: AppTheme.neonShadow(color: AppTheme.primary, blur: 8.0),
                ),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitForm(recipientEmail, recipientName),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Send Message'),
                            SizedBox(width: 8),
                            Icon(Icons.send, size: 14),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
