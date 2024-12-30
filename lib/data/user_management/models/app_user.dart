import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String name;
  final String email;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toFirestore() {
    return {
      "name": name,
      "email": email,
    };
  }

  factory AppUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return AppUser(
      name: data["name"],
      email: data["email"],
      id: snapshot.id,
    );
  }
}
