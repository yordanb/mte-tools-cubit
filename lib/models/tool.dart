// Struktur file: lib/models/tool.dart

class Tool {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}