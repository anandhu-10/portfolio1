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
  bool _isAdminAuthenticated = false;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;
  bool _isLockoutActive = false;

  PortfolioStateModel get state => _state;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;
  bool get isLockoutActive => _isLockoutActive;

  void checkLockout() {
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      _isLockoutActive = true;
    } else {
      _isLockoutActive = false;
      _lockoutUntil = null;
    }
  }

  Future<bool> authenticate(String password) async {
    checkLockout();
    if (_isLockoutActive) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (password == 'A1N1A1N1D1H1U1') {
        _isAdminAuthenticated = true;
        _failedAttempts = 0;
        _lockoutUntil = null;
        _isLockoutActive = false;
        await prefs.remove('failed_attempts');
        await prefs.remove('lockout_until');
        
        // Save session expiry (2 hours from now)
        final expiry = DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch;
        await prefs.setInt('admin_session_expiry', expiry);
        
        notifyListeners();
        return true;
      } else {
        _failedAttempts++;
        await prefs.setInt('failed_attempts', _failedAttempts);
        if (_failedAttempts >= 5) {
          _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
          _isLockoutActive = true;
          await prefs.setInt('lockout_until', _lockoutUntil!.millisecondsSinceEpoch);
        }
        notifyListeners();
        return false;
      }
    } catch (_) {
      if (password == 'A1N1A1N1D1H1U1') {
        _isAdminAuthenticated = true;
        _failedAttempts = 0;
        _lockoutUntil = null;
        _isLockoutActive = false;
        notifyListeners();
        return true;
      } else {
        _failedAttempts++;
        if (_failedAttempts >= 5) {
          _lockoutUntil = DateTime.now().add(const Duration(seconds: 30));
          _isLockoutActive = true;
        }
        notifyListeners();
        return false;
      }
    }
  }

  void logoutAdmin() async {
    _isAdminAuthenticated = false;
    _editMode = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_session_expiry');
    } catch (_) {}
  }

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
    if (!_isAdminAuthenticated) {
      _editMode = false;
    } else {
      _editMode = !_editMode;
    }
    notifyListeners();
  }

  void setEditMode(bool value) {
    if (value && !_isAdminAuthenticated) {
      _editMode = false;
    } else {
      _editMode = value;
    }
    notifyListeners();
  }

  Future<void> _initData() async {
    print('[_initData] Startup initialized. Loading state...');
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _failedAttempts = prefs.getInt('failed_attempts') ?? 0;
      final lockoutMillis = prefs.getInt('lockout_until');
      if (lockoutMillis != null) {
        _lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
      }
      checkLockout();

      // Load session expiry to restore authentication state
      final sessionExpiryMillis = prefs.getInt('admin_session_expiry');
      if (sessionExpiryMillis != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(sessionExpiryMillis);
        if (DateTime.now().isBefore(expiry)) {
          _isAdminAuthenticated = true;
          // Extend session by 2 hours
          await prefs.setInt('admin_session_expiry', DateTime.now().add(const Duration(hours: 2)).millisecondsSinceEpoch);
        } else {
          await prefs.remove('admin_session_expiry');
        }
      }
    } catch (e) {
      print('[_initData] Failed to load settings/lockout from SharedPreferences: $e');
    }

    // Load defaults immediately to prevent black screen / empty UI
    print('[_initData] Loading hardcoded defaults first...');
    _loadDefaults();

    // Fallback: try loading from SharedPreferences immediately so UI displays data instantly (no delay)
    bool loadedFromCache = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('portfolio_data');

      if (localJson != null && localJson.isNotEmpty) {
        _state = PortfolioStateModel.fromJson(jsonDecode(localJson) as Map<String, dynamic>);
        loadedFromCache = true;
        print('[_initData] SharedPreferences cache found and loaded. Certs: ${_state.certifications.length}, Projects: ${_state.projects.length}');
      } else {
        print('[_initData] SharedPreferences cache is empty.');
      }
    } catch (e) {
      print('[_initData] SharedPreferences read failed: $e');
    }

    if (loadedFromCache) {
      _restoreCertificatesBase64();
    }

    // Stop showing the spinner; display cached or default content right away
    _isLoading = false;
    notifyListeners();

    // Now, listen to Firebase Firestore in real-time. Any changes will auto-update the UI on all devices.
    print('[_initData] Setting up Firestore real-time listener... Firebase enabled: $_isFirebaseEnabled');
    if (_isFirebaseEnabled) {
      try {
        FirebaseFirestore.instance
            .collection('portfolios')
            .doc('main_portfolio')
            .snapshots()
            .listen((doc) async {
          print('[_initData] Firestore snapshot event received! Document exists: ${doc.exists}');
          if (doc.exists && doc.data() != null) {
            _state = PortfolioStateModel.fromJson(doc.data()!);
            print('[_initData] Snapshot data parsed. Certs: ${_state.certifications.length}, Projects: ${_state.projects.length}');
            _restoreCertificatesBase64();

            // Sync with local SharedPreferences cache
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('portfolio_data', jsonEncode(_state.toJson()));
              print('[_initData] Local SharedPreferences cache updated to match Firestore.');
            } catch (e) {
              print('[_initData] Failed to update SharedPreferences cache: $e');
            }

            print('[_initData] State updated from snapshot. Triggering UI rebuild (notifyListeners)...');
            notifyListeners();
          } else {
            print('[_initData] Document main_portfolio does not exist in Firestore. Generating it with defaults/cache...');
            _saveToFirestore();
          }
        }, onError: (e) {
          print('[_initData] Firestore real-time listener error: $e');
        });
      } catch (e) {
        print('[_initData] Failed to initialize Firestore real-time listener: $e');
      }
    }
  }

  void _restoreCertificatesBase64() {
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
    print('[_saveToFirestore] Initiating Firestore write to portfolios/main_portfolio...');
    try {
      await FirebaseFirestore.instance
          .collection('portfolios')
          .doc('main_portfolio')
          .set(_state.toJson())
          .timeout(const Duration(seconds: 4));
      print('[_saveToFirestore] Document portfolios/main_portfolio successfully updated in Firestore!');
    } catch (e) {
      print('[_saveToFirestore] ERROR writing to Firestore: $e');
    }
  }

  Future<void> resetToDefaults() async {
    if (!_isAdminAuthenticated) return;
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
    if (!_isAdminAuthenticated) return;
    _state = _state.copyWith(profile: newProfile);
    saveToLocalStorage();
    notifyListeners();
  }

  // ABOUT EDITS
  void updateAbout(AboutModel newAbout) {
    if (!_isAdminAuthenticated) return;
    _state = _state.copyWith(about: newAbout);
    saveToLocalStorage();
    notifyListeners();
  }

  // CONTACT EDITS
  void updateContact(ContactModel newContact) {
    if (!_isAdminAuthenticated) return;
    _state = _state.copyWith(contact: newContact);
    saveToLocalStorage();
    notifyListeners();
  }

  // SKILLS CRUD
  void addSkill(SkillModel skill) {
    if (!_isAdminAuthenticated) return;
    _state.skills.add(skill);
    saveToLocalStorage();
    notifyListeners();
  }

  void editSkill(int index, SkillModel skill) {
    if (!_isAdminAuthenticated) return;
    if (index >= 0 && index < _state.skills.length) {
      _state.skills[index] = skill;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteSkill(int index) {
    if (!_isAdminAuthenticated) return;
    if (index >= 0 && index < _state.skills.length) {
      _state.skills.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // PROJECTS CRUD
  void addProject(ProjectModel project) {
    print('[_stateProvider] addProject called for: ${project.title}');
    if (!_isAdminAuthenticated) {
      print('[_stateProvider] addProject REJECTED: Not authenticated.');
      return;
    }
    _state.projects.add(project);
    saveToLocalStorage();
    notifyListeners();
  }

  void editProject(int index, ProjectModel project) {
    print('[_stateProvider] editProject called for index $index: ${project.title}');
    if (!_isAdminAuthenticated) {
      print('[_stateProvider] editProject REJECTED: Not authenticated.');
      return;
    }
    if (index >= 0 && index < _state.projects.length) {
      _state.projects[index] = project;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteProject(int index) {
    print('[_stateProvider] deleteProject called for index $index');
    if (!_isAdminAuthenticated) {
      print('[_stateProvider] deleteProject REJECTED: Not authenticated.');
      return;
    }
    if (index >= 0 && index < _state.projects.length) {
      _state.projects.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // CERTIFICATIONS CRUD
  void addCertification(CertificationModel cert) {
    print('[_stateProvider] addCertification called for: ${cert.title}');
    if (!_isAdminAuthenticated) {
      print('[_stateProvider] addCertification REJECTED: Not authenticated.');
      return;
    }
    _state.certifications.add(cert);
    saveToLocalStorage();
    notifyListeners();
  }

  void editCertification(int index, CertificationModel cert) {
    print('[_stateProvider] editCertification called for index $index: ${cert.title}');
    if (!_isAdminAuthenticated) {
      print('[_stateProvider] editCertification REJECTED: Not authenticated.');
      return;
    }
    if (index >= 0 && index < _state.certifications.length) {
      _state.certifications[index] = cert;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteCertification(int index) {
    if (!_isAdminAuthenticated) return;
    if (index >= 0 && index < _state.certifications.length) {
      _state.certifications.removeAt(index);
      saveToLocalStorage();
      notifyListeners();
    }
  }

  // EXPERIENCE CRUD
  void addExperience(ExperienceModel exp) {
    if (!_isAdminAuthenticated) return;
    _state.experience.add(exp);
    saveToLocalStorage();
    notifyListeners();
  }

  void editExperience(int index, ExperienceModel exp) {
    if (!_isAdminAuthenticated) return;
    if (index >= 0 && index < _state.experience.length) {
      _state.experience[index] = exp;
      saveToLocalStorage();
      notifyListeners();
    }
  }

  void deleteExperience(int index) {
    if (!_isAdminAuthenticated) return;
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
    if (!_isAdminAuthenticated) return false;
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
