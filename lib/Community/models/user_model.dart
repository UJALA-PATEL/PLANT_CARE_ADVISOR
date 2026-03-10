class UserModel {
  final String id;
  final String name;
  final String email;
  final String profilePic;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePic,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePic: data['profilePic'] ?? '',
    );
  }
}
