import 'package:cloud_firestore/cloud_firestore.dart';

class Usermodel {
  Usermodel({required this.email, required this.token});

  String email;
  String token;

  static Usermodel formSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Usermodel(email: snapshot["email"], token: snapshot["token"]);
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "token": token,
      };
}
