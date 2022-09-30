import 'dart:async';
import 'dart:developer';

import 'package:clints_app/app/modules/register_screen/model/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../home/views/home_view.dart';

class RegisterScreenController extends GetxController {
  static RegisterScreenController instance = Get.find();

  String token = "";

  Future regsterUser(String email, String password, String token) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        Usermodel usermodel = Usermodel(
          email: email,
          token: token,
        );
        await FirebaseFirestore.instance
            .collection("clints")
            .doc(userCredential.user!.uid)
            .set(usermodel.toJson())
            .catchError((e) {
          log(e.toString());
        });
        Get.offAll(HomeView());
      } else {
        Get.snackbar("Error Create account", "Please enter all fields");
      }
    } catch (e) {
      Get.snackbar("Error Create account", e.toString());
    }
  }
}
