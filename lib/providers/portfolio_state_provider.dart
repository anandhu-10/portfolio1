import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
  bool _firebaseStorageAvailable = true;

  PortfolioStateModel get state => _state;
  bool get isLoading => _isLoading;
  bool get editMode => _editMode;
  bool get isAdminAuthenticated => _isAdminAuthenticated;
  int get failedAttempts => _failedAttempts;
  DateTime? get lockoutUntil => _lockoutUntil;
  bool get isLockoutActive => _isLockoutActive;
  bool get firebaseStorageAvailable => _firebaseStorageAvailable;

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
        
        // Trigger automated Base64 cleanup and migration
        migrateBase64ToStorage();
        
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
        
        migrateBase64ToStorage();
        
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
    print('[Snapshot Event] Startup initialized. Loading state...');
    _isLoading = true;
    notifyListeners();

    // Load defaults immediately to prevent black screen / empty UI and ensure _state is initialized
    print('[Snapshot Event] Loading hardcoded defaults first...');
    _loadDefaults();

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
      print('[Snapshot Event] Failed to load settings/lockout from SharedPreferences: $e');
    }

    // Fallback: try loading from SharedPreferences immediately so UI displays data instantly (no delay)
    bool loadedFromCache = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      final localJson = prefs.getString('portfolio_data');

      if (localJson != null && localJson.isNotEmpty) {
        _state = PortfolioStateModel.fromJson(jsonDecode(localJson) as Map<String, dynamic>);
        loadedFromCache = true;
        print('[Snapshot Event] SharedPreferences cache found and loaded. Certs: ${_state.certifications.length}, Projects: ${_state.projects.length}');
      } else {
        print('[Snapshot Event] SharedPreferences cache is empty.');
      }
    } catch (e) {
      print('[Snapshot Event] SharedPreferences read failed: $e');
    }

    if (loadedFromCache) {
      _restoreCertificatesBase64();
    }

    // Stop showing the spinner; display cached or default content right away
    _isLoading = false;
    notifyListeners();

    // Now trigger migration if the admin session was restored
    if (_isAdminAuthenticated) {
      migrateBase64ToStorage();
    }

    // Now, listen to Firebase Firestore in real-time. Any changes will auto-update the UI on all devices.
    print('[Snapshot Event] Setting up Firestore real-time listener... Firebase enabled: $_isFirebaseEnabled');
    if (_isFirebaseEnabled) {
      try {
        FirebaseFirestore.instance
            .collection('portfolios')
            .doc('main_portfolio')
            .snapshots()
            .listen((doc) async {
          try {
            print('[Snapshot Event] Firestore snapshot event received! Document exists: ${doc.exists}');
            if (doc.exists && doc.data() != null) {
              _state = PortfolioStateModel.fromJson(doc.data()!);
              print('[Firestore Read] Snapshot data parsed successfully. Certs: ${_state.certifications.length}, Projects: ${_state.projects.length}');
              _restoreCertificatesBase64();

              // Sync with local SharedPreferences cache
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('portfolio_data', jsonEncode(_state.toJson()));
                print('[State Update] Local SharedPreferences cache updated to match Firestore.');
              } catch (e) {
                print('[State Update] Failed to update SharedPreferences cache: $e');
              }

              print('[State Update] State updated from snapshot. Triggering UI rebuild (notifyListeners)...');
              notifyListeners();
            } else {
              print('[Snapshot Event] Document main_portfolio does not exist in Firestore. Generating it with defaults/cache...');
              await _saveToFirestore();
            }
          } catch (e) {
            print('[Snapshot Event] ERROR processing Firestore snapshot data: $e');
          }
        }, onError: (Object e) {
          print('[Snapshot Event] Firestore real-time listener error: $e');
        });
      } catch (e) {
        print('[Snapshot Event] Failed to initialize Firestore real-time listener: $e');
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

  Future<void> _saveState(PortfolioStateModel newState) async {
    print('[State Update] Initiating state save and sync process...');
    final oldState = _state;
    _state = newState;
    
    // 1. Update SharedPreferences cache
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('portfolio_data', jsonEncode(newState.toJson()));
      print('[State Update] SharedPreferences local cache successfully updated.');
    } catch (e) {
      print('[State Update] ERROR updating SharedPreferences cache: $e');
    }
    
    notifyListeners();
    
    // 2. Sync to Firestore
    if (_isFirebaseEnabled) {
      try {
        await _saveToFirestore();
        print('[State Update] Firestore synchronization confirmed.');
      } catch (e) {
        print('[State Update] Firestore write failed. Initiating rollback to previous state...');
        _state = oldState;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('portfolio_data', jsonEncode(oldState.toJson()));
        } catch (_) {}
        notifyListeners();
        rethrow; // Rethrow to notify the calling UI dialog of the failure
      }
    } else {
      print('[State Update] Firebase is not enabled. Firestore synchronization skipped.');
    }
  }

  Future<void> saveToLocalStorage() async {
    await _saveState(_state);
  }

  Future<void> _saveToFirestore() async {
    print('[Firestore Write] Initiating Firestore write to portfolios/main_portfolio...');
    try {
      await FirebaseFirestore.instance
          .collection('portfolios')
          .doc('main_portfolio')
          .set(_state.toJson())
          .timeout(const Duration(seconds: 15));
      print('[Firestore Write] Document portfolios/main_portfolio successfully updated in Firestore!');
    } catch (e) {
      print('[Firestore Write] ERROR writing to Firestore: $e');
      rethrow;
    }
  }

  Future<String> uploadBase64ToStorage(String base64DataUrl, String storagePath) async {
    if (base64DataUrl.isEmpty) return '';
    if (base64DataUrl.startsWith('http://') || base64DataUrl.startsWith('https://')) {
      return base64DataUrl;
    }

    if (!_isFirebaseEnabled || !_firebaseStorageAvailable) {
      print('[Firestore Write] Firebase not enabled or Storage unavailable. Skipping storage upload, using Base64 directly.');
      return base64DataUrl;
    }

    try {
      print('[Firestore Write] Uploading base64 payload to path: $storagePath...');
      
      final parts = base64DataUrl.split(';');
      String mimeType = 'application/octet-stream';
      if (parts.isNotEmpty && parts[0].startsWith('data:')) {
        mimeType = parts[0].substring(5);
      }
      
      final base64String = base64DataUrl.split(',').last;
      final Uint8List bytes = base64Decode(base64String);
      
      final metadata = SettableMetadata(contentType: mimeType);
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      
      final uploadTask = ref.putData(bytes, metadata);
      
      // Attach a catchError handler to the future immediately to prevent uncaught exceptions
      final safeFuture = uploadTask.catchError((Object e) {
        print('[Firestore Write] Future error caught: $e');
        throw e;
      });

      // Subscribe to snapshotEvents to handle stream-level errors and prevent uncaught web zone exceptions
      uploadTask.snapshotEvents.listen(
        (snapshot) {},
        onError: (Object e) {
          print('[Firestore Write] Stream error caught: $e');
        },
        cancelOnError: true,
      );

      final snapshot = await safeFuture;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      print('[Firestore Write] Upload success. Download URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('[Firestore Write] WARNING: Firebase Storage upload failed: $e. Falling back to Base64 payload directly.');
      _firebaseStorageAvailable = false;
      notifyListeners();
      return base64DataUrl;
    }
  }

  Future<void> migrateBase64ToStorage() async {
    if (!_isAdminAuthenticated) return;
    print('[Migration] Checking if any Base64 content needs to be migrated to Firebase Storage...');
    
    bool needsMigration = false;
    if (_state.profile.profilePhotoBase64.startsWith('data:')) needsMigration = true;
    if (_state.profile.resumeBase64.startsWith('data:')) needsMigration = true;
    
    for (final proj in _state.projects) {
      if (proj.imageBase64.startsWith('data:')) {
        needsMigration = true;
        break;
      }
    }
    
    for (final cert in _state.certifications) {
      if (cert.imageBase64.startsWith('data:') || cert.pdfBase64.startsWith('data:')) {
        needsMigration = true;
        break;
      }
    }
    
    if (!needsMigration) {
      print('[Migration] No Base64 data found. Document is already fully migrated.');
      return;
    }
    
    print('[Migration] Base64 data found! Starting migration to Firebase Storage...');
    
    try {
      String profilePhotoUrl = _state.profile.profilePhotoBase64;
      if (profilePhotoUrl.startsWith('data:')) {
        profilePhotoUrl = await uploadBase64ToStorage(
          profilePhotoUrl,
          'profile/profile_photo_migrated.png',
        );
      }
      
      String resumeUrl = _state.profile.resumeBase64;
      if (resumeUrl.startsWith('data:')) {
        resumeUrl = await uploadBase64ToStorage(
          resumeUrl,
          'profile/resume_migrated.pdf',
        );
      }
      
      final migratedProfile = _state.profile.copyWith(
        profilePhotoBase64: profilePhotoUrl,
        resumeBase64: resumeUrl,
        resumeUrl: resumeUrl.isNotEmpty ? resumeUrl : _state.profile.resumeUrl,
      );
      
      final List<ProjectModel> migratedProjects = [];
      for (final proj in _state.projects) {
        String imageUrl = proj.imageBase64;
        if (imageUrl.startsWith('data:')) {
          final sanitizedTitle = proj.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
          imageUrl = await uploadBase64ToStorage(
            imageUrl,
            'projects/${sanitizedTitle}_image_migrated.png',
          );
        }
        migratedProjects.add(ProjectModel(
          title: proj.title,
          subtitle: proj.subtitle,
          description: proj.description,
          technologies: proj.technologies,
          imageBase64: imageUrl,
          githubUrl: proj.githubUrl,
          liveUrl: proj.liveUrl,
          category: proj.category,
        ));
      }
      
      final List<CertificationModel> migratedCerts = [];
      for (final cert in _state.certifications) {
        final sanitizedTitle = cert.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
        
        String imageUrl = cert.imageBase64;
        if (imageUrl.startsWith('data:')) {
          imageUrl = await uploadBase64ToStorage(
            imageUrl,
            'certifications/${sanitizedTitle}_image_migrated.png',
          );
        }
        
        String pdfUrl = cert.pdfBase64;
        if (pdfUrl.startsWith('data:')) {
          pdfUrl = await uploadBase64ToStorage(
            pdfUrl,
            'certifications/${sanitizedTitle}_doc_migrated.pdf',
          );
        }
        
        migratedCerts.add(CertificationModel(
          title: cert.title,
          issuingOrganization: cert.issuingOrganization,
          imageBase64: imageUrl,
          pdfBase64: pdfUrl,
          pdfUrl: pdfUrl,
          credentialUrl: cert.credentialUrl,
          date: cert.date,
        ));
      }
      
      final migratedState = _state.copyWith(
        profile: migratedProfile,
        projects: migratedProjects,
        certifications: migratedCerts,
      );
      
      print('[Migration] All files uploaded to Storage. Updating state...');
      await _saveState(migratedState);
      print('[Migration] Database migration completed successfully!');
    } catch (e) {
      print('[Migration] ERROR during migration: $e');
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
      try {
        await _saveToFirestore();
      } catch (e) {
        print('[resetToDefaults] Failed to write default state to Firestore: $e');
        rethrow;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // PROFILE EDITS
  Future<void> updateProfile(ProfileModel newProfile) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] updateProfile called');
    
    String profilePhotoUrl = newProfile.profilePhotoBase64;
    if (profilePhotoUrl.startsWith('data:')) {
      profilePhotoUrl = await uploadBase64ToStorage(
        profilePhotoUrl,
        'profile/profile_photo_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }
    
    String resumeUrl = newProfile.resumeBase64;
    if (resumeUrl.startsWith('data:')) {
      resumeUrl = await uploadBase64ToStorage(
        resumeUrl,
        'profile/resume_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    }
    
    final finalProfile = newProfile.copyWith(
      profilePhotoBase64: profilePhotoUrl,
      resumeBase64: resumeUrl,
      resumeUrl: resumeUrl.isNotEmpty ? resumeUrl : newProfile.resumeUrl,
    );
    
    final newState = _state.copyWith(profile: finalProfile);
    await _saveState(newState);
  }

  // ABOUT EDITS
  Future<void> updateAbout(AboutModel newAbout) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] updateAbout called');
    final newState = _state.copyWith(about: newAbout);
    await _saveState(newState);
  }

  // CONTACT EDITS
  Future<void> updateContact(ContactModel newContact) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] updateContact called');
    final newState = _state.copyWith(contact: newContact);
    await _saveState(newState);
  }

  // SKILLS CRUD
  Future<void> addSkill(SkillModel skill) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Add Operation] addSkill called for: ${skill.name}');
    final updatedSkills = List<SkillModel>.from(_state.skills)..add(skill);
    final newState = _state.copyWith(skills: updatedSkills);
    await _saveState(newState);
  }

  Future<void> editSkill(int index, SkillModel skill) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] editSkill called for index $index: ${skill.name}');
    if (index >= 0 && index < _state.skills.length) {
      final updatedSkills = List<SkillModel>.from(_state.skills);
      updatedSkills[index] = skill;
      final newState = _state.copyWith(skills: updatedSkills);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  Future<void> deleteSkill(int index) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Delete Operation] deleteSkill called for index $index');
    if (index >= 0 && index < _state.skills.length) {
      final updatedSkills = List<SkillModel>.from(_state.skills);
      updatedSkills.removeAt(index);
      final newState = _state.copyWith(skills: updatedSkills);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  // PROJECTS CRUD
  Future<void> addProject(ProjectModel project) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Add Operation] addProject called for: ${project.title}');
    
    String imageUrl = project.imageBase64;
    if (imageUrl.startsWith('data:')) {
      final sanitizedTitle = project.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      imageUrl = await uploadBase64ToStorage(
        imageUrl,
        'projects/${sanitizedTitle}_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }
    
    final finalProject = ProjectModel(
      title: project.title,
      subtitle: project.subtitle,
      description: project.description,
      technologies: project.technologies,
      imageBase64: imageUrl,
      githubUrl: project.githubUrl,
      liveUrl: project.liveUrl,
      category: project.category,
    );
    
    final updatedProjects = List<ProjectModel>.from(_state.projects)..add(finalProject);
    final newState = _state.copyWith(projects: updatedProjects);
    await _saveState(newState);
  }

  Future<void> editProject(int index, ProjectModel project) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] editProject called for index $index: ${project.title}');
    
    if (index >= 0 && index < _state.projects.length) {
      String imageUrl = project.imageBase64;
      if (imageUrl.startsWith('data:')) {
        final sanitizedTitle = project.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
        imageUrl = await uploadBase64ToStorage(
          imageUrl,
          'projects/${sanitizedTitle}_image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      }
      
      final finalProject = ProjectModel(
        title: project.title,
        subtitle: project.subtitle,
        description: project.description,
        technologies: project.technologies,
        imageBase64: imageUrl,
        githubUrl: project.githubUrl,
        liveUrl: project.liveUrl,
        category: project.category,
      );
      
      final updatedProjects = List<ProjectModel>.from(_state.projects);
      updatedProjects[index] = finalProject;
      final newState = _state.copyWith(projects: updatedProjects);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  Future<void> deleteProject(int index) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Delete Operation] deleteProject called for index $index');
    
    if (index >= 0 && index < _state.projects.length) {
      final updatedProjects = List<ProjectModel>.from(_state.projects);
      updatedProjects.removeAt(index);
      final newState = _state.copyWith(projects: updatedProjects);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  // CERTIFICATIONS CRUD
  Future<void> addCertification(CertificationModel cert) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Add Operation] addCertification called for: ${cert.title}');
    
    final sanitizedTitle = cert.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
    
    String imageUrl = cert.imageBase64;
    if (imageUrl.startsWith('data:')) {
      imageUrl = await uploadBase64ToStorage(
        imageUrl,
        'certifications/${sanitizedTitle}_image_${DateTime.now().millisecondsSinceEpoch}.png',
      );
    }
    
    String pdfUrl = cert.pdfBase64;
    if (pdfUrl.startsWith('data:')) {
      pdfUrl = await uploadBase64ToStorage(
        pdfUrl,
        'certifications/${sanitizedTitle}_doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    }
    
    final finalCert = CertificationModel(
      title: cert.title,
      issuingOrganization: cert.issuingOrganization,
      imageBase64: imageUrl,
      pdfBase64: pdfUrl,
      pdfUrl: pdfUrl,
      credentialUrl: cert.credentialUrl,
      date: cert.date,
    );
    
    final updatedCerts = List<CertificationModel>.from(_state.certifications)..add(finalCert);
    final newState = _state.copyWith(certifications: updatedCerts);
    await _saveState(newState);
  }

  Future<void> editCertification(int index, CertificationModel cert) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] editCertification called for index $index: ${cert.title}');
    
    if (index >= 0 && index < _state.certifications.length) {
      final sanitizedTitle = cert.title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_').toLowerCase();
      
      String imageUrl = cert.imageBase64;
      if (imageUrl.startsWith('data:')) {
        imageUrl = await uploadBase64ToStorage(
          imageUrl,
          'certifications/${sanitizedTitle}_image_${DateTime.now().millisecondsSinceEpoch}.png',
        );
      }
      
      String pdfUrl = cert.pdfBase64;
      if (pdfUrl.startsWith('data:')) {
        pdfUrl = await uploadBase64ToStorage(
          pdfUrl,
          'certifications/${sanitizedTitle}_doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
        );
      }
      
      final finalCert = CertificationModel(
        title: cert.title,
        issuingOrganization: cert.issuingOrganization,
        imageBase64: imageUrl,
        pdfBase64: pdfUrl,
        pdfUrl: pdfUrl,
        credentialUrl: cert.credentialUrl,
        date: cert.date,
      );
      
      final updatedCerts = List<CertificationModel>.from(_state.certifications);
      updatedCerts[index] = finalCert;
      final newState = _state.copyWith(certifications: updatedCerts);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  Future<void> deleteCertification(int index) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Delete Operation] deleteCertification called for index $index');
    
    if (index >= 0 && index < _state.certifications.length) {
      final updatedCerts = List<CertificationModel>.from(_state.certifications);
      updatedCerts.removeAt(index);
      final newState = _state.copyWith(certifications: updatedCerts);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  // EXPERIENCE CRUD
  Future<void> addExperience(ExperienceModel exp) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Add Operation] addExperience called for: ${exp.title}');
    final updatedExp = List<ExperienceModel>.from(_state.experience)..add(exp);
    final newState = _state.copyWith(experience: updatedExp);
    await _saveState(newState);
  }

  Future<void> editExperience(int index, ExperienceModel exp) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Edit Operation] editExperience called for index $index: ${exp.title}');
    
    if (index >= 0 && index < _state.experience.length) {
      final updatedExp = List<ExperienceModel>.from(_state.experience);
      updatedExp[index] = exp;
      final newState = _state.copyWith(experience: updatedExp);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  Future<void> deleteExperience(int index) async {
    if (!_isAdminAuthenticated) throw Exception('Not authenticated');
    print('[Delete Operation] deleteExperience called for index $index');
    
    if (index >= 0 && index < _state.experience.length) {
      final updatedExp = List<ExperienceModel>.from(_state.experience);
      updatedExp.removeAt(index);
      final newState = _state.copyWith(experience: updatedExp);
      await _saveState(newState);
    } else {
      throw Exception('Index out of bounds');
    }
  }

  // IMPORT/EXPORT
  Future<void> exportConfig() async {
    try {
      final jsonString = jsonEncode(_state.toJson());
      final base64String = base64Encode(utf8.encode(jsonString));
      final uri = Uri.parse('data:application/json;charset=utf-8;base64,$base64String');
      
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
      if (data.containsKey('profile') && data.containsKey('skills') && data.containsKey('projects')) {
        final newState = PortfolioStateModel.fromJson(data);
        await _saveState(newState);
        return true;
      }
    } catch (e) {
      debugPrint('Import failed: $e');
      rethrow;
    }
    return false;
  }
}
