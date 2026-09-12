class Contacts {
  final String uid;
  final String name;
  final String emailOrPhone;
  final String? image;
  final bool isOnline;

  Contacts({
    required this.uid,
    required this.name,
    required this.emailOrPhone,
    this.image,
    this.isOnline = false,
  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      uid: json["uid"] ?? '',
      name: json["name"] ?? '',
      emailOrPhone: json["email"] ?? '',
      image: (json["photo"] != null && json["photo"].toString().isNotEmpty)
          ? json["photo"]
          : null,
      isOnline: json["isOnline"] ?? false,
    );
  }
}