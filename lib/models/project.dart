class Project {
  final String title;
  final String subtitle;
  final String description;
  final List<String> technologies;
  final String imageUrl;
  final String githubUrl;
  final String liveUrl;
  final String category; // 'Flutter', 'React/Node.js', 'Other'

  const Project({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.technologies,
    required this.imageUrl,
    required this.githubUrl,
    required this.liveUrl,
    required this.category,
  });
}
