import 'dart:developer';

import 'package:clints_app/app/modules/home/views/home_view.dart';
import 'package:clints_app/app/modules/register_screen/model/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';

import '../controllers/register_screen_controller.dart';

class RegisterScreenView extends StatefulWidget {
  @override
  State<RegisterScreenView> createState() => _RegisterScreenViewState();
}

class _RegisterScreenViewState extends State<RegisterScreenView> {
  final _emailcontroller = TextEditingController();

  final _paswordcontroller = TextEditingController();

  final controll = Get.put(RegisterScreenController());
  late AndroidNotificationChannel channel;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String mtoken = "";

  @override
  void initState() {
    super.initState();

    requestPermission();
    listenFCM();
    loadFCM();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token!;
      });

      storesdata(token!);
    });
  }

  void storesdata(String token) async {
    Usermodel usermodel = Usermodel(
      email: _emailcontroller.text,
      token: token,
    );
    await FirebaseFirestore.instance
        .collection("clints")
        .doc()
        .set(usermodel.toJson())
        .catchError((e) {
      log(e.toString());
    });
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              icon: 'launch_background',
            ),
          ),
        );
      }
    });
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              SizedBox(
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 100),
                child: Text(
                  "Create your \nAccount",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  height: MediaQuery.of(context).size.height * 0.069,
                  child: TextField(
                    controller: _emailcontroller,
                    decoration: InputDecoration(hintText: "Email"),
                  )),
              SizedBox(
                height: 25,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 30),
                  height: MediaQuery.of(context).size.height * 0.069,
                  child: TextField(
                    controller: _paswordcontroller,
                    decoration: InputDecoration(hintText: "Password"),
                  )),
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                  onPressed: () async {
                    await controll
                        .regsterUser(_emailcontroller.text,
                            _paswordcontroller.text, controll.token)
                        .then((value) {});
                  },
                  child: Text("Create ")),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 70,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an accoont ?",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
