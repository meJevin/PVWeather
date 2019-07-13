import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      _fcm.onIosSettingsRegistered.listen(
            (data) { saveDeviceToken(); },
      );

      _fcm.requestNotificationPermissions(
          IosNotificationSettings()
      );
    } else {
      saveDeviceToken();
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        final snackBar = SnackBar(
          content: Text(message['notification']['title']),
          action: SnackBarAction(label: 'Go', onPressed: () => null),
        );

        Scaffold.of(context).showSnackBar(snackBar);
      },

      onLaunch: (Map<String, dynamic> message) async {

      },

      onResume: (Map<String, dynamic> message) async {

      },
    );
  }

  saveDeviceToken() async {
    //FirebaseUser user = await _auth.currentUser();

    String uid = 'test';

    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = _db
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokenRef.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}