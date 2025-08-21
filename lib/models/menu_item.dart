class MenuItem {
  final String name;
  final String? imageUrl;

  MenuItem({required this.name, this.imageUrl});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}
