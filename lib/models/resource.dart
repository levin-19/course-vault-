class Resource {
  final String id;
  final String userId;
  final String title;
  final String url;
  final String category;
  final String description;
  final DateTime createdAt;

  Resource({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    required this.category,
    required this.description,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'url': url,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
