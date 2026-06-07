import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_state_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_container.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _passwordController = TextEditingController();
  bool _isAuthenticated = false;
  String? _authError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() {
    if (_passwordController.text == 'admin123') {
      setState(() {
        _isAuthenticated = true;
        _authError = null;
      });
    } else {
      setState(() {
        _authError = 'Incorrect password. Try "admin123".';
      });
    }
  }

  Future<void> _handleImport(BuildContext context, PortfolioStateProvider provider) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final jsonStr = utf8.decode(bytes);
          final success = await provider.importConfig(jsonStr);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success
                      ? 'Portfolio configuration imported successfully!'
                      : 'Invalid configuration file.',
                ),
                backgroundColor: success ? Colors.green : Colors.redAccent,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _confirmReset(BuildContext context, PortfolioStateProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBg,
          title: const Text('Reset Portfolio?', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
          content: const Text(
            'This will delete all custom edits from your local storage and reset the portfolio to default developer data. This cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                provider.resetToDefaults();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Portfolio reset to default configuration.'),
                    backgroundColor: AppTheme.secondary,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PortfolioStateProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Signature Logo
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: '< ',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: AppTheme.primary,
                        ),
                        children: [
                          TextSpan(
                            text: 'Admin Panel',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: ' /',
                            style: TextStyle(color: AppTheme.secondary),
                          ),
                          TextSpan(
                            text: ' >',
                            style: TextStyle(color: AppTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  if (!_isAuthenticated) ...[
                    // Password Prompt Card
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Authentication Required',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Enter the password to activate edit triggers and manage database features.',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              errorText: _authError,
                            ),
                            onFieldSubmitted: (_) => _verifyPassword(),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _verifyPassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Unlock Settings'),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                            child: const Text('Back to Portfolio', style: TextStyle(color: AppTheme.textSecondary)),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Authenticated Admin Settings Card
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Manage Portfolio',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green, width: 0.8),
                                ),
                                child: const Text(
                                  'Unlocked',
                                  style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Edit Mode Toggle
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Enable Edit Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Overlay interactive edit icons directly on the home page.', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            trailing: Switch(
                              value: provider.editMode,
                              activeColor: AppTheme.primary,
                              onChanged: (val) => provider.setEditMode(val),
                            ),
                          ),
                          const Divider(color: AppTheme.border, height: 32),

                          // Backup Data Actions
                          const Text(
                            'Configuration Backups',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: provider.exportConfig,
                            icon: const Icon(Icons.download, size: 16),
                            label: const Text('Export JSON Config'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _handleImport(context, provider),
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('Import JSON Config'),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.secondary),
                            ),
                          ),
                          const Divider(color: AppTheme.border, height: 32),

                          // Danger Zone
                          const Text(
                            'Danger Zone',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => _confirmReset(context, provider),
                            icon: const Icon(Icons.restore_outlined, size: 16, color: Colors.white),
                            label: const Text('Reset to Code Defaults', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.15),
                              side: const BorderSide(color: Colors.redAccent),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Return to Portfolio'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
