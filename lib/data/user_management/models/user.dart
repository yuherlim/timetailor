import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({
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

  factory User.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    final data = snapshot.data()!;
    return User(
      name: data["name"],
      email: data["email"],
      id: snapshot.id,
    );
  }
}
