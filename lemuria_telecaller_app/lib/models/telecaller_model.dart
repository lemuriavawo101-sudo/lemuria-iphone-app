class Telecaller {
  final String id;
  final String name;
  final String username;
  final String role;
  final String line;
  final String avatar;

  Telecaller({
    required this.id,
    required this.name,
    required this.username,
    required this.role,
    required this.line,
    required this.avatar,
  });

  factory Telecaller.fromJson(Map<String, dynamic> json) {
    return Telecaller(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      role: json['role'] ?? '',
      line: json['line'] ?? '',
      avatar: json['avatar'] ?? '👩‍⚕️',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'username': username,
    'role': role,
    'line': line,
    'avatar': avatar,
  };
}

