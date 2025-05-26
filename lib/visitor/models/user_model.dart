class User {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final List<String> favoriteIds;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    this.favoriteIds = const [],
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    List<String>? favoriteIds,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'favoriteIds': favoriteIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      favoriteIds: List<String>.from(json['favoriteIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}