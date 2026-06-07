import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/portfolio_data.dart';
import '../models/portfolio_state_model.dart';

class PortfolioStateProvider extends ChangeNotifier {
  late PortfolioStateModel _state;
  bool _isLoading = true;
  bool _editMode = false;

  PortfolioStateModel get state => _state;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;

  bool get _isFirebaseEnabled {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

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

    bool loaded = false;
    bool loadedFromFirestore = false;

    // 1. Try loading from Firebase Firestore
    if (_isFirebaseEnabled) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('portfolios')
            .doc('main_portfolio')
            .get()
            .timeout(const Duration(seconds: 4));
        if (doc.exists && doc.data() != null) {
          _state = PortfolioStateModel.fromJson(doc.data()!);
          loaded = true;
          loadedFromFirestore = true;
        }
      } catch (e) {
        debugPrint('Failed to load portfolio from Firestore: $e');
      }
    }

    // 2. Fallback to LocalStorage
    if (!loaded) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final localJson = prefs.getString('portfolio_data');

        if (localJson != null && localJson.isNotEmpty) {
          _state = PortfolioStateModel.fromJson(jsonDecode(localJson) as Map<String, dynamic>);
          loaded = true;
        }
      } catch (_) {}
    }

    // 3. Merge fail-safe: restore base64 data for certificates if empty in the database
    if (loaded) {
      final restoredCerts = _state.certifications.map((cert) {
        if (cert.imageBase64.isEmpty || cert.pdfBase64.isEmpty) {
          try {
            final defCert = PortfolioData.certifications.firstWhere(
              (d) => d.title == cert.title,
            );
            return CertificationModel(
              title: cert.title,
              issuingOrganization: cert.issuingOrganization,
              imageBase64: cert.imageBase64.isEmpty ? defCert.imageBase64 : cert.imageBase64,
              pdfBase64: cert.pdfBase64.isEmpty ? defCert.pdfBase64 : cert.pdfBase64,
              pdfUrl: cert.pdfUrl,
              credentialUrl: cert.credentialUrl,
              date: cert.date,
            );
          } catch (_) {
            return cert;
          }
        }
        return cert;
      }).toList();
      _state = _state.copyWith(certifications: restoredCerts);
    }

    // 4. Default hardcoded fallback
    if (!loaded) {
      _loadDefaults();
      if (_isFirebaseEnabled) {
        _saveToFirestore(); // Run in background, do not block UI loading
      }
    } else {
      // If we loaded successfully from local storage or assets but Firebase is enabled,
      // upload this local data to Firestore to keep them in sync
      if (_isFirebaseEnabled && !loadedFromFirestore) {
        _saveToFirestore(); // Run in background, do not block UI loading
      }
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
      educationDegree: PortfolioData.educationDegree,
      educationOrg: PortfolioData.educationOrg,
      educationDuration: PortfolioData.educationDuration,
      careerGoals: PortfolioData.careerGoals,
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
        imageBase64: e.imageBase64,
        pdfBase64: e.pdfBase64,
        pdfUrl: e.pdfUrl,
        credentialUrl: e.credentialUrl,
        date: e.date.isNotEmpty ? e.date : 'Ongoing',
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
    // 1. Save locally to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('portfolio_data', jsonEncode(_state.toJson()));
    } catch (e) {
      debugPrint('Failed to save to local storage: $e');
    }

    // 2. Save to Firestore
    if (_isFirebaseEnabled) {
      await _saveToFirestore();
    }
  }

  Future<void> _saveToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('portfolios')
          .doc('main_portfolio')
          .set(_state.toJson())
          .timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Failed to save to Firestore: $e');
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

    if (_isFirebaseEnabled) {
      _saveToFirestore(); // Run in background, do not block UI transition
    }

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
