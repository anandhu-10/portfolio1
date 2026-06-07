import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/portfolio_data.dart';
import '../models/portfolio_state_model.dart';

class PortfolioStateProvider extends ChangeNotifier {
  late PortfolioStateModel _state;
  bool _isLoading = true;
  bool _editMode = false;

  PortfolioStateModel get state => _state;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;

  PortfolioStateProvider() {
    _initData();
  }

  void toggleEditMode() {
    _editMode = !_editMode;
    notifyListeners();
  }

  void setEditMode(bool value) {
    _editMode = value;
    notifyListeners();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('portfolio_data');

      if (localJson != null && localJson.isNotEmpty) {
        // Load from LocalStorage
        _state = PortfolioStateModel.fromJson(jsonDecode(localJson) as Map<String, dynamic>);
      } else {
        // Try to load from assets/data/portfolio_data.json
        try {
          final assetJson = await rootBundle.loadString('assets/data/portfolio_data.json');
          if (assetJson.isNotEmpty) {
            _state = PortfolioStateModel.fromJson(jsonDecode(assetJson) as Map<String, dynamic>);
          } else {
            _loadDefaults();
          }
        } catch (_) {
          _loadDefaults();
        }
      }
    } catch (_) {
      _loadDefaults();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _loadDefaults() {
    // Reconstruct models from static PortfolioData
    final profile = ProfileModel(
      name: PortfolioData.name,
      role: PortfolioData.role,
      initials: PortfolioData.initials,
      tagline: PortfolioData.headline,
      profilePhotoBase64: '', // starts empty, falls back to code placeholders
      resumeUrl: PortfolioData.resumeUrl,
      resumeBase64: '',
    );

    final about = AboutModel(
      aboutOne: PortfolioData.aboutOne,
      aboutTwo: PortfolioData.aboutTwo,
      educationDegree: 'Diploma / Degree in Computer Engineering',
      educationOrg: 'Board of Technical Examinations / University',
      educationDuration: 'Ongoing',
      careerGoals: 'To excel as a cross-platform Flutter and web engineer, developing highly interactive applications that make a tangible positive impact on society.',
      statistics: PortfolioData.quickFacts.map((e) => {
        'value': e['value'] ?? '',
        'label': e['label'] ?? '',
      }).toList(),
    );

    final skills = PortfolioData.skills.map((e) {
      final Color color = e['color'] as Color;
      final int colorValue = color.toARGB32();
      final IconData icon = e['icon'] as IconData;
      return SkillModel(
        name: e['name'] as String,
        percentage: e['percentage'] as double,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
        colorHex: '0x${colorValue.toRadixString(16).toUpperCase()}',
      );
    }).toList();

    final projects = PortfolioData.projects.map((e) {
      return ProjectModel(
        title: e.title,
        subtitle: e.subtitle,
        description: e.description,
        technologies: e.technologies,
        imageBase64: '',
        githubUrl: e.githubUrl,
        liveUrl: e.liveUrl,
        category: e.category,
      );
    }).toList();

    final certifications = PortfolioData.certifications.map((e) {
      return CertificationModel(
        title: e.title,
        issuingOrganization: e.issuingOrganization,
        imageBase64: '',
        pdfBase64: '',
        pdfUrl: '',
        credentialUrl: e.credentialUrl,
        date: 'Ongoing',
      );
    }).toList();

    final experience = PortfolioData.experience.map((e) {
      final IconData icon = e['icon'] as IconData;
      return ExperienceModel(
        title: e['title'] as String,
        subtitle: e['subtitle'] as String,
        duration: e['duration'] as String,
        description: e['description'] as String,
        iconCodePoint: icon.codePoint,
        iconFontFamily: icon.fontFamily ?? 'MaterialIcons',
      );
    }).toList();

    final contact = ContactModel(
      phone: PortfolioData.phone,
      email: PortfolioData.email,
      location: PortfolioData.location,
      linkedinUrl: PortfolioData.linkedinUrl,
      githubUrl: PortfolioData.githubUrl,
      instagramUrl: PortfolioData.instagramUrl,
    );

    _state = PortfolioStateModel(
      profile: profile,
      about: about,
      skills: skills,
      projects: projects,
      certifications: certifications,
      experience: experience,
      contact: contact,
    );
  }

  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('portfolio_data', jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('Failed to save to local storage: $e');
    }
  }

  Future<void> resetToDefaults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('portfolio_data');
    } catch (_) {}

    _loadDefaults();
    _isLoading = false;
    notifyListeners();
  }

  // PROFILE EDITS
  void updateProfile(ProfileModel newProfile) {
    _state = _state.copyWith(profile: newProfile);
    saveToLocalStorage();
    notifyListeners();
  }

  // ABOUT EDITS
  void updateAbout(AboutModel newAbout) {
    _state = _state.copyWith(about: newAbout);
    saveToLocalStorage();
    notifyListeners();
  }

  // CONTACT EDITS
  void updateContact(ContactModel newContact) {
    _state = _state.copyWith(contact: newContact);
    saveToLocalStorage();
    notifyListeners();
  }

  // SKILLS CRUD
  void addSkill(SkillModel skill) {
    _state.skills.add(skill);
    saveToLocalStorage();
    notifyListeners();
  }

  void editSkill(int index, SkillModel skill) {
    if (index >= 0 && index < _state.skills.length) {
      _state.skills[index] = skill;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteSkill(int index) {
    if (index >= 0 && index < _state.skills.length) {
      _state.skills.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // PROJECTS CRUD
  void addProject(ProjectModel project) {
    _state.projects.add(project);
    saveToLocalStorage();
    notifyListeners();
  }

  void editProject(int index, ProjectModel project) {
    if (index >= 0 && index < _state.projects.length) {
      _state.projects[index] = project;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteProject(int index) {
    if (index >= 0 && index < _state.projects.length) {
      _state.projects.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // CERTIFICATIONS CRUD
  void addCertification(CertificationModel cert) {
    _state.certifications.add(cert);
    saveToLocalStorage();
    notifyListeners();
  }

  void editCertification(int index, CertificationModel cert) {
    if (index >= 0 && index < _state.certifications.length) {
      _state.certifications[index] = cert;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteCertification(int index) {
    if (index >= 0 && index < _state.certifications.length) {
      _state.certifications.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // EXPERIENCE CRUD
  void addExperience(ExperienceModel exp) {
    _state.experience.add(exp);
    saveToLocalStorage();
    notifyListeners();
  }

  void editExperience(int index, ExperienceModel exp) {
    if (index >= 0 && index < _state.experience.length) {
      _state.experience[index] = exp;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteExperience(int index) {
    if (index >= 0 && index < _state.experience.length) {
      _state.experience.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // IMPORT/EXPORT
  Future<void> exportConfig() async {
    try {
      final jsonString = jsonEncode(_state.toJson());
      final base64String = base64Encode(utf8.encode(jsonString));
      final uri = Uri.parse('data:application/json;charset=utf-8;base64,$base64String');
      
      // We launch the data URL. In browsers, it prompts a file download.
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch download link';
      }
    } catch (e) {
      debugPrint('Export failed: $e');
    }
  }

  Future<bool> importConfig(String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;
      // Basic validation
      if (data.containsKey('profile') && data.containsKey('skills') && data.containsKey('projects')) {
        _state = PortfolioStateModel.fromJson(data);
        await saveToLocalStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Import failed: $e');
    }
    return false;
  }
}
