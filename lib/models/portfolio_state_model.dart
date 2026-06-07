class PortfolioStateModel {
  final ProfileModel profile;
  final AboutModel about;
  final List<SkillModel> skills;
  final List<ProjectModel> projects;
  final List<CertificationModel> certifications;
  final List<ExperienceModel> experience;
  final ContactModel contact;

  PortfolioStateModel({
    required this.profile,
    required this.about,
    required this.skills,
    required this.projects,
    required this.certifications,
    required this.experience,
    required this.contact,
  });

  factory PortfolioStateModel.fromJson(Map<String, dynamic> json) {
    return PortfolioStateModel(
      profile: ProfileModel.fromJson((json['profile'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      about: AboutModel.fromJson((json['about'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      skills: ((json['skills'] ?? <dynamic>[]) as List)
          .map((item) => SkillModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      projects: ((json['projects'] ?? <dynamic>[]) as List)
          .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      certifications: ((json['certifications'] ?? <dynamic>[]) as List)
          .map((item) => CertificationModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      experience: ((json['experience'] ?? <dynamic>[]) as List)
          .map((item) => ExperienceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      contact: ContactModel.fromJson((json['contact'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile.toJson(),
      'about': about.toJson(),
      'skills': skills.map((item) => item.toJson()).toList(),
      'projects': projects.map((item) => item.toJson()).toList(),
      'certifications': certifications.map((item) => item.toJson()).toList(),
      'experience': experience.map((item) => item.toJson()).toList(),
      'contact': contact.toJson(),
    };
  }

  PortfolioStateModel copyWith({
    ProfileModel? profile,
    AboutModel? about,
    List<SkillModel>? skills,
    List<ProjectModel>? projects,
    List<CertificationModel>? certifications,
    List<ExperienceModel>? experience,
    ContactModel? contact,
  }) {
    return PortfolioStateModel(
      profile: profile ?? this.profile,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      projects: projects ?? this.projects,
      certifications: certifications ?? this.certifications,
      experience: experience ?? this.experience,
      contact: contact ?? this.contact,
    );
  }
}

class ProfileModel {
  final String name;
  final String role;
  final String initials;
  final String tagline;
  final String profilePhotoBase64;
  final String resumeUrl;
  final String resumeBase64;

  ProfileModel({
    required this.name,
    required this.role,
    required this.initials,
    required this.tagline,
    required this.profilePhotoBase64,
    required this.resumeUrl,
    required this.resumeBase64,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      name: (json['name'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      initials: (json['initials'] as String?) ?? '',
      tagline: (json['tagline'] as String?) ?? '',
      profilePhotoBase64: (json['profilePhotoBase64'] as String?) ?? '',
      resumeUrl: (json['resumeUrl'] as String?) ?? '',
      resumeBase64: (json['resumeBase64'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
      'initials': initials,
      'tagline': tagline,
      'profilePhotoBase64': profilePhotoBase64,
      'resumeUrl': resumeUrl,
      'resumeBase64': resumeBase64,
    };
  }

  ProfileModel copyWith({
    String? name,
    String? role,
    String? initials,
    String? tagline,
    String? profilePhotoBase64,
    String? resumeUrl,
    String? resumeBase64,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      role: role ?? this.role,
      initials: initials ?? this.initials,
      tagline: tagline ?? this.tagline,
      profilePhotoBase64: profilePhotoBase64 ?? this.profilePhotoBase64,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeBase64: resumeBase64 ?? this.resumeBase64,
    );
  }
}

class AboutModel {
  final String aboutOne;
  final String aboutTwo;
  final String educationDegree;
  final String educationOrg;
  final String educationDuration;
  final String careerGoals;
  final List<Map<String, String>> statistics;

  AboutModel({
    required this.aboutOne,
    required this.aboutTwo,
    required this.educationDegree,
    required this.educationOrg,
    required this.educationDuration,
    required this.careerGoals,
    required this.statistics,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    var rawStats = json['statistics'] ?? <dynamic>[];
    List<Map<String, String>> statsList = [];
    if (rawStats is List) {
      for (var stat in rawStats) {
        if (stat is Map) {
          statsList.add({
            'value': (stat['value'] ?? '').toString(),
            'label': (stat['label'] ?? '').toString(),
          });
        }
      }
    }
    return AboutModel(
      aboutOne: (json['aboutOne'] as String?) ?? '',
      aboutTwo: (json['aboutTwo'] as String?) ?? '',
      educationDegree: (json['educationDegree'] as String?) ?? '',
      educationOrg: (json['educationOrg'] as String?) ?? '',
      educationDuration: (json['educationDuration'] as String?) ?? '',
      careerGoals: (json['careerGoals'] as String?) ?? '',
      statistics: statsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aboutOne': aboutOne,
      'aboutTwo': aboutTwo,
      'educationDegree': educationDegree,
      'educationOrg': educationOrg,
      'educationDuration': educationDuration,
      'careerGoals': careerGoals,
      'statistics': statistics,
    };
  }

  AboutModel copyWith({
    String? aboutOne,
    String? aboutTwo,
    String? educationDegree,
    String? educationOrg,
    String? educationDuration,
    String? careerGoals,
    List<Map<String, String>>? statistics,
  }) {
    return AboutModel(
      aboutOne: aboutOne ?? this.aboutOne,
      aboutTwo: aboutTwo ?? this.aboutTwo,
      educationDegree: educationDegree ?? this.educationDegree,
      educationOrg: educationOrg ?? this.educationOrg,
      educationDuration: educationDuration ?? this.educationDuration,
      careerGoals: careerGoals ?? this.careerGoals,
      statistics: statistics ?? this.statistics,
    );
  }
}

class SkillModel {
  final String name;
  final double percentage;
  final int iconCodePoint;
  final String iconFontFamily;
  final String colorHex;

  SkillModel({
    required this.name,
    required this.percentage,
    required this.iconCodePoint,
    required this.iconFontFamily,
    required this.colorHex,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: (json['name'] as String?) ?? '',
      percentage: ((json['percentage'] ?? 0.0) as num).toDouble(),
      iconCodePoint: (json['iconCodePoint'] as int?) ?? 58279, // fallback to code icon
      iconFontFamily: (json['iconFontFamily'] as String?) ?? 'MaterialIcons',
      colorHex: (json['colorHex'] as String?) ?? '0xFF38BDF8',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorHex': colorHex,
    };
  }
}

class ProjectModel {
  final String title;
  final String subtitle;
  final String description;
  final List<String> technologies;
  final String imageBase64;
  final String githubUrl;
  final String liveUrl;
  final String category;

  ProjectModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.technologies,
    required this.imageBase64,
    required this.githubUrl,
    required this.liveUrl,
    required this.category,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      technologies: List<String>.from((json['technologies'] as List?) ?? []),
      imageBase64: (json['imageBase64'] as String?) ?? '',
      githubUrl: (json['githubUrl'] as String?) ?? '',
      liveUrl: (json['liveUrl'] as String?) ?? '',
      category: (json['category'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'technologies': technologies,
      'imageBase64': imageBase64,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'category': category,
    };
  }
}

class CertificationModel {
  final String title;
  final String issuingOrganization;
  final String imageBase64;
  final String pdfBase64;
  final String pdfUrl;
  final String credentialUrl;
  final String date;

  CertificationModel({
    required this.title,
    required this.issuingOrganization,
    required this.imageBase64,
    required this.pdfBase64,
    required this.pdfUrl,
    required this.credentialUrl,
    required this.date,
  });

  factory CertificationModel.fromJson(Map<String, dynamic> json) {
    return CertificationModel(
      title: (json['title'] as String?) ?? '',
      issuingOrganization: (json['issuingOrganization'] as String?) ?? '',
      imageBase64: (json['imageBase64'] as String?) ?? '',
      pdfBase64: (json['pdfBase64'] as String?) ?? '',
      pdfUrl: (json['pdfUrl'] as String?) ?? '',
      credentialUrl: (json['credentialUrl'] as String?) ?? '',
      date: (json['date'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'issuingOrganization': issuingOrganization,
      'imageBase64': imageBase64,
      'pdfBase64': pdfBase64,
      'pdfUrl': pdfUrl,
      'credentialUrl': credentialUrl,
      'date': date,
    };
  }
}

class ExperienceModel {
  final String title;
  final String subtitle;
  final String duration;
  final String description;
  final int iconCodePoint;
  final String iconFontFamily;

  ExperienceModel({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.description,
    required this.iconCodePoint,
    required this.iconFontFamily,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      duration: (json['duration'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      iconCodePoint: (json['iconCodePoint'] as int?) ?? 58279,
      iconFontFamily: (json['iconFontFamily'] as String?) ?? 'MaterialIcons',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'duration': duration,
      'description': description,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
    };
  }
}

class ContactModel {
  final String phone;
  final String email;
  final String location;
  final String linkedinUrl;
  final String githubUrl;
  final String instagramUrl;

  ContactModel({
    required this.phone,
    required this.email,
    required this.location,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.instagramUrl,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      phone: (json['phone'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      location: (json['location'] as String?) ?? '',
      linkedinUrl: (json['linkedinUrl'] as String?) ?? '',
      githubUrl: (json['githubUrl'] as String?) ?? '',
      instagramUrl: (json['instagramUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'location': location,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'instagramUrl': instagramUrl,
    };
  }

  ContactModel copyWith({
    String? phone,
    String? email,
    String? location,
    String? linkedinUrl,
    String? githubUrl,
    String? instagramUrl,
  }) {
    return ContactModel(
      phone: phone ?? this.phone,
      email: email ?? this.email,
      location: location ?? this.location,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      instagramUrl: instagramUrl ?? this.instagramUrl,
    );
  }
}
