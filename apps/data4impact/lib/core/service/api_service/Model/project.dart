class Project {
  final String id;
  final String title;
  final String slug;
  final String? description;

  Project({
    required this.id,
    required this.title,
    required this.slug,
    this.description,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['_id']as String ?? '',
      title: json['title'] as String ?? '',
      slug: json['slug'] as String ?? '',
      description: json['description'] as String,
    );
  }
}
