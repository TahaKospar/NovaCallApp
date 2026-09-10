class Contacts {
  final String name;
  final String state;
  final String? image;
  final String emailOrPhone;
  final String uid;
final bool? isOnline;
  Contacts({
    required this.uid,
    required this.name,
    required this.state,
    this.image,
    required this.emailOrPhone,
    required this.isOnline,

  });

  factory Contacts.fromJson(Map<String, dynamic> json) {
    return Contacts(
      uid: json["uid"] ?? '',
      name: json["name"] ?? '',
      state: json["state"] ?? 'offline',
      image: json["image"] ?? '',
      emailOrPhone: json["emailOrPhone"] ?? '',
      isOnline: json["isOnline"] ?? false,
    );
  }
}
