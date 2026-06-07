import 'package:flutter/material.dart';
import '../../models/portfolio_state_model.dart';
import '../../theme/app_theme.dart';
import 'local_file_uploader.dart';

// Mapping list of selectable icons for skills & experiences
class IconOption {
  final String label;
  final IconData icon;
  IconOption(this.label, this.icon);
}

final List<IconOption> selectableIcons = [
  IconOption('Code', Icons.code_rounded),
  IconOption('Mobile', Icons.phone_android_rounded),
  IconOption('Dart/Target', Icons.gps_fixed_rounded),
  IconOption('React/Sync', Icons.sync_rounded),
  IconOption('NodeJS/Hub', Icons.hub_rounded),
  IconOption('Firebase/Fire', Icons.local_fire_department_rounded),
  IconOption('Database/Storage', Icons.storage_rounded),
  IconOption('Git/Hub', Icons.device_hub_rounded),
  IconOption('REST API/LAN', Icons.lan_rounded),
  IconOption('Education/School', Icons.school_rounded),
  IconOption('Job/Work', Icons.work_rounded),
  IconOption('Idea/Lightbulb', Icons.lightbulb_rounded),
  IconOption('AI/Brain', Icons.psychology_rounded),
  IconOption('Profile/Person', Icons.person_rounded),
  IconOption('Star/Achievement', Icons.star_rounded),
  IconOption('Terminal/CLI', Icons.terminal_rounded),
  IconOption('Web/Browser', Icons.language_rounded),
  IconOption('Settings/Tool', Icons.settings_applications_rounded),
];

// Color options for skills
class ColorOption {
  final String name;
  final Color color;
  final String hex;
  ColorOption(this.name, this.color, this.hex);
}

final List<ColorOption> selectableColors = [
  ColorOption('Electric Cyan', AppTheme.primary, '0xFF38BDF8'),
  ColorOption('Neon Purple', AppTheme.secondary, '0xFFA855F7'),
  ColorOption('Cyan Accent', AppTheme.accent, '0xFF00E5FF'),
  ColorOption('Emerald Green', const Color(0xFF22C55E), '0xFF22C55E'),
  ColorOption('Amber Yellow', const Color(0xFFFFCA28), '0xFFFFCA28'),
  ColorOption('Vibrant Orange', const Color(0xFFF97316), '0xFFF97316'),
  ColorOption('Soft Blue', const Color(0xFF1572B6), '0xFF1572B6'),
  ColorOption('Rose Red', const Color(0xFFE11D48), '0xFFE11D48'),
  ColorOption('White/Muted', Colors.white, '0xFFFFFFFF'),
];

// Base Dialog container to apply cohesive theme
Widget _buildBaseDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required VoidCallback onSave,
}) {
  return Dialog(
    backgroundColor: AppTheme.cardBg,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Container(
      constraints: const BoxConstraints(maxWidth: 550),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.textMuted),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppTheme.border, height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: content,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// 1. Profile Dialog
class EditProfileDialog extends StatefulWidget {
  final ProfileModel initialProfile;
  final void Function(ProfileModel profile) onSave;

  const EditProfileDialog({
    super.key,
    required this.initialProfile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _initialsController;
  late TextEditingController _taglineController;
  late TextEditingController _resumeUrlController;
  String _profilePhotoBase64 = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialProfile.name);
    _roleController = TextEditingController(text: widget.initialProfile.role);
    _initialsController = TextEditingController(text: widget.initialProfile.initials);
    _taglineController = TextEditingController(text: widget.initialProfile.tagline);
    _resumeUrlController = TextEditingController(text: widget.initialProfile.resumeUrl);
    _profilePhotoBase64 = widget.initialProfile.profilePhotoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _initialsController.dispose();
    _taglineController.dispose();
    _resumeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: 'Edit Profile Information',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final updated = ProfileModel(
            name: _nameController.text,
            role: _roleController.text,
            initials: _initialsController.text,
            tagline: _taglineController.text,
            profilePhotoBase64: _profilePhotoBase64,
            resumeUrl: _resumeUrlController.text,
            resumeBase64: widget.initialProfile.resumeBase64,
          );
          widget.onSave(updated);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            LocalFileUploader(
              label: 'Profile Photo',
              initialBase64: _profilePhotoBase64,
              allowedExtensions: const ['png', 'jpg', 'jpeg'],
              onFileLoaded: (base64) => _profilePhotoBase64 = base64,
            ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _roleController,
              decoration: const InputDecoration(labelText: 'Job Title'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialsController,
              decoration: const InputDecoration(labelText: 'Initials (e.g. AA)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taglineController,
              decoration: const InputDecoration(labelText: 'Headline Tagline'),
              maxLines: 2,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resumeUrlController,
              decoration: const InputDecoration(labelText: 'Fallback Resume PDF URL'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// 2. About Dialog
class EditAboutDialog extends StatefulWidget {
  final AboutModel initialAbout;
  final void Function(AboutModel about) onSave;

  const EditAboutDialog({
    super.key,
    required this.initialAbout,
    required this.onSave,
  });

  @override
  State<EditAboutDialog> createState() => _EditAboutDialogState();
}

class _EditAboutDialogState extends State<EditAboutDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bioOneController;
  late TextEditingController _bioTwoController;
  late TextEditingController _degreeController;
  late TextEditingController _orgController;
  late TextEditingController _durationController;
  late TextEditingController _goalsController;

  // Local copy of statistics
  List<Map<String, String>> _stats = [];

  @override
  void initState() {
    super.initState();
    _bioOneController = TextEditingController(text: widget.initialAbout.aboutOne);
    _bioTwoController = TextEditingController(text: widget.initialAbout.aboutTwo);
    _degreeController = TextEditingController(text: widget.initialAbout.educationDegree);
    _orgController = TextEditingController(text: widget.initialAbout.educationOrg);
    _durationController = TextEditingController(text: widget.initialAbout.educationDuration);
    _goalsController = TextEditingController(text: widget.initialAbout.careerGoals);
    _stats = List<Map<String, String>>.from(
      widget.initialAbout.statistics.map((e) => Map<String, String>.from(e)),
    );
  }

  @override
  void dispose() {
    _bioOneController.dispose();
    _bioTwoController.dispose();
    _degreeController.dispose();
    _orgController.dispose();
    _durationController.dispose();
    _goalsController.dispose();
    super.dispose();
  }

  void _addStat() {
    setState(() {
      _stats.add({'value': '0', 'label': 'New Label'});
    });
  }

  void _removeStat(int index) {
    setState(() {
      _stats.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: 'Edit About & Education',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final updated = AboutModel(
            aboutOne: _bioOneController.text,
            aboutTwo: _bioTwoController.text,
            educationDegree: _degreeController.text,
            educationOrg: _orgController.text,
            educationDuration: _durationController.text,
            careerGoals: _goalsController.text,
            statistics: _stats,
          );
          widget.onSave(updated);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _bioOneController,
              decoration: const InputDecoration(labelText: 'Who I Am (Paragraph 1)'),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioTwoController,
              decoration: const InputDecoration(labelText: 'Who I Am (Paragraph 2)'),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            const Text(
              'Education Details',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _degreeController,
              decoration: const InputDecoration(labelText: 'Degree / Diploma Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orgController,
              decoration: const InputDecoration(labelText: 'School / Organization'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (e.g. 2024 - 2026 / Ongoing)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _goalsController,
              decoration: const InputDecoration(labelText: 'Career Goals Summary'),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Facts / Statistics',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.secondary),
                ),
                TextButton.icon(
                  onPressed: _addStat,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Stat', style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _stats.length,
              itemBuilder: (context, idx) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: _stats[idx]['value'],
                          decoration: const InputDecoration(hintText: 'Value (e.g. 10+)'),
                          onChanged: (val) => _stats[idx]['value'] = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          initialValue: _stats[idx]['label'],
                          decoration: const InputDecoration(hintText: 'Label (e.g. Projects)'),
                          onChanged: (val) => _stats[idx]['label'] = val,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _removeStat(idx),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 3. Skill Add/Edit Dialog
class EditSkillDialog extends StatefulWidget {
  final SkillModel? initialSkill;
  final void Function(SkillModel skill) onSave;

  const EditSkillDialog({
    super.key,
    this.initialSkill,
    required this.onSave,
  });

  @override
  State<EditSkillDialog> createState() => _EditSkillDialogState();
}

class _EditSkillDialogState extends State<EditSkillDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  double _percentage = 0.8;
  late IconOption _selectedIcon;
  late ColorOption _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialSkill?.name ?? '');
    _percentage = widget.initialSkill?.percentage ?? 0.8;

    // Resolve matching icon option
    _selectedIcon = selectableIcons.firstWhere(
      (opt) => opt.icon.codePoint == widget.initialSkill?.iconCodePoint,
      orElse: () => selectableIcons.first,
    );

    // Resolve matching color option
    _selectedColor = selectableColors.firstWhere(
      (opt) => opt.hex == widget.initialSkill?.colorHex,
      orElse: () => selectableColors.first,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: widget.initialSkill == null ? 'Add New Skill' : 'Edit Skill',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final skill = SkillModel(
            name: _nameController.text,
            percentage: _percentage,
            iconCodePoint: _selectedIcon.icon.codePoint,
            iconFontFamily: _selectedIcon.icon.fontFamily ?? 'MaterialIcons',
            colorHex: _selectedColor.hex,
          );
          widget.onSave(skill);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Skill Name (e.g. Flutter)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),
            Text(
              'Proficiency: ${(_percentage * 100).toInt()}%',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            Slider(
              value: _percentage,
              min: 0.0,
              max: 1.0,
              divisions: 20,
              activeColor: _selectedColor.color,
              onChanged: (val) => setState(() => _percentage = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IconOption>(
              value: _selectedIcon,
              decoration: const InputDecoration(labelText: 'Skill Icon'),
              items: selectableIcons.map((opt) {
                return DropdownMenuItem<IconOption>(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(opt.icon, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(opt.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedIcon = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ColorOption>(
              value: _selectedColor,
              decoration: const InputDecoration(labelText: 'Brand Color'),
              items: selectableColors.map((opt) {
                return DropdownMenuItem<ColorOption>(
                  value: opt,
                  child: Row(
                    children: [
                      Container(width: 16, height: 16, color: opt.color),
                      const SizedBox(width: 12),
                      Text(opt.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedColor = val!),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Project Add/Edit Dialog
class EditProjectDialog extends StatefulWidget {
  final ProjectModel? initialProject;
  final void Function(ProjectModel project) onSave;

  const EditProjectDialog({
    super.key,
    this.initialProject,
    required this.onSave,
  });

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _descController;
  late TextEditingController _techController;
  late TextEditingController _githubController;
  late TextEditingController _liveController;
  late String _category;
  String _imageBase64 = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialProject?.title ?? '');
    _subtitleController = TextEditingController(text: widget.initialProject?.subtitle ?? '');
    _descController = TextEditingController(text: widget.initialProject?.description ?? '');
    _techController = TextEditingController(
      text: widget.initialProject?.technologies.join(', ') ?? '',
    );
    _githubController = TextEditingController(text: widget.initialProject?.githubUrl ?? '');
    _liveController = TextEditingController(text: widget.initialProject?.liveUrl ?? '');
    _category = widget.initialProject?.category ?? 'Flutter';
    _imageBase64 = widget.initialProject?.imageBase64 ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descController.dispose();
    _techController.dispose();
    _githubController.dispose();
    _liveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: widget.initialProject == null ? 'Add New Project' : 'Edit Project',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final techs = _techController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final proj = ProjectModel(
            title: _titleController.text,
            subtitle: _subtitleController.text,
            description: _descController.text,
            technologies: techs,
            imageBase64: _imageBase64,
            githubUrl: _githubController.text,
            liveUrl: _liveController.text,
            category: _category,
          );
          widget.onSave(proj);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            LocalFileUploader(
              label: 'Project Screenshot',
              initialBase64: _imageBase64,
              allowedExtensions: const ['png', 'jpg', 'jpeg'],
              onFileLoaded: (base64) => _imageBase64 = base64,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Project Title'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Short Subtitle/Tagline'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Project Category'),
              items: const [
                DropdownMenuItem(value: 'Flutter', child: Text('Flutter')),
                DropdownMenuItem(value: 'React', child: Text('React')),
                DropdownMenuItem(value: 'Full Stack', child: Text('Full Stack')),
                DropdownMenuItem(value: 'Web', child: Text('Web')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Project Description'),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _techController,
              decoration: const InputDecoration(
                labelText: 'Technologies Stack (Comma separated)',
                hintText: 'Flutter, Dart, Firebase, Provider',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'GitHub Repository URL'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _liveController,
              decoration: const InputDecoration(labelText: 'Live Demo URL'),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. Certification Add/Edit Dialog
class EditCertificationDialog extends StatefulWidget {
  final CertificationModel? initialCert;
  final void Function(CertificationModel cert) onSave;

  const EditCertificationDialog({
    super.key,
    this.initialCert,
    required this.onSave,
  });

  @override
  State<EditCertificationDialog> createState() => _EditCertificationDialogState();
}

class _EditCertificationDialogState extends State<EditCertificationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _orgController;
  late TextEditingController _dateController;
  late TextEditingController _linkController;
  String _imageBase64 = '';
  String _pdfBase64 = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialCert?.title ?? '');
    _orgController = TextEditingController(text: widget.initialCert?.issuingOrganization ?? '');
    _dateController = TextEditingController(text: widget.initialCert?.date ?? 'Ongoing');
    _linkController = TextEditingController(text: widget.initialCert?.credentialUrl ?? '');
    _imageBase64 = widget.initialCert?.imageBase64 ?? '';
    _pdfBase64 = widget.initialCert?.pdfBase64 ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _orgController.dispose();
    _dateController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: widget.initialCert == null ? 'Add New Certification' : 'Edit Certification',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final cert = CertificationModel(
            title: _titleController.text,
            issuingOrganization: _orgController.text,
            imageBase64: _imageBase64,
            pdfBase64: _pdfBase64,
            pdfUrl: '',
            credentialUrl: _linkController.text,
            date: _dateController.text,
          );
          widget.onSave(cert);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            LocalFileUploader(
              label: 'Certificate Preview (Image)',
              initialBase64: _imageBase64,
              allowedExtensions: const ['png', 'jpg', 'jpeg'],
              onFileLoaded: (base64) => _imageBase64 = base64,
            ),
            LocalFileUploader(
              label: 'Certificate Document (PDF) - Optional',
              initialBase64: _pdfBase64,
              allowedExtensions: const ['pdf'],
              onFileLoaded: (base64) => _pdfBase64 = base64,
            ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Certification Title'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _orgController,
              decoration: const InputDecoration(labelText: 'Issuing Organization'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Issue Date / Duration'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkController,
              decoration: const InputDecoration(labelText: 'Verification Credential URL'),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. Experience Add/Edit Dialog
class EditExperienceDialog extends StatefulWidget {
  final ExperienceModel? initialExperience;
  final void Function(ExperienceModel exp) onSave;

  const EditExperienceDialog({
    super.key,
    this.initialExperience,
    required this.onSave,
  });

  @override
  State<EditExperienceDialog> createState() => _EditExperienceDialogState();
}

class _EditExperienceDialogState extends State<EditExperienceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _durationController;
  late TextEditingController _descController;
  late IconOption _selectedIcon;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialExperience?.title ?? '');
    _subtitleController = TextEditingController(text: widget.initialExperience?.subtitle ?? '');
    _durationController = TextEditingController(text: widget.initialExperience?.duration ?? '');
    _descController = TextEditingController(text: widget.initialExperience?.description ?? '');

    _selectedIcon = selectableIcons.firstWhere(
      (opt) => opt.icon.codePoint == widget.initialExperience?.iconCodePoint,
      orElse: () => selectableIcons.first,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _durationController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: widget.initialExperience == null ? 'Add New Experience' : 'Edit Experience',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final exp = ExperienceModel(
            title: _titleController.text,
            subtitle: _subtitleController.text,
            duration: _durationController.text,
            description: _descController.text,
            iconCodePoint: _selectedIcon.icon.codePoint,
            iconFontFamily: _selectedIcon.icon.fontFamily ?? 'MaterialIcons',
          );
          widget.onSave(exp);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Position / Milestone'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subtitleController,
              decoration: const InputDecoration(labelText: 'Organization / Action'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (e.g. Jan 2026)'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IconOption>(
              value: _selectedIcon,
              decoration: const InputDecoration(labelText: 'Milestone Icon'),
              items: selectableIcons.map((opt) {
                return DropdownMenuItem<IconOption>(
                  value: opt,
                  child: Row(
                    children: [
                      Icon(opt.icon, size: 20, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(opt.label),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedIcon = val!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Short Description'),
              maxLines: 4,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}

// 7. Contact Dialog
class EditContactDialog extends StatefulWidget {
  final ContactModel initialContact;
  final void Function(ContactModel contact) onSave;

  const EditContactDialog({
    super.key,
    required this.initialContact,
    required this.onSave,
  });

  @override
  State<EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<EditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  late TextEditingController _instagramController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.initialContact.phone);
    _emailController = TextEditingController(text: widget.initialContact.email);
    _locationController = TextEditingController(text: widget.initialContact.location);
    _linkedinController = TextEditingController(text: widget.initialContact.linkedinUrl);
    _githubController = TextEditingController(text: widget.initialContact.githubUrl);
    _instagramController = TextEditingController(text: widget.initialContact.instagramUrl);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildBaseDialog(
      context: context,
      title: 'Edit Contact Details',
      onSave: () {
        if (_formKey.currentState!.validate()) {
          final updated = ContactModel(
            phone: _phoneController.text,
            email: _emailController.text,
            location: _locationController.text,
            linkedinUrl: _linkedinController.text,
            githubUrl: _githubController.text,
            instagramUrl: _instagramController.text,
          );
          widget.onSave(updated);
          Navigator.pop(context);
        }
      },
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email Address'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _linkedinController,
              decoration: const InputDecoration(labelText: 'LinkedIn URL'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _githubController,
              decoration: const InputDecoration(labelText: 'GitHub Profile URL'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instagramController,
              decoration: const InputDecoration(labelText: 'Instagram URL'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
    );
  }
}

class EditSectionButton extends StatelessWidget {
  final VoidCallback onTap;
  const EditSectionButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary.withValues(alpha: 0.5), width: 1),
            ),
            child: const Icon(
              Icons.edit_rounded,
              size: 14,
              color: AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}
