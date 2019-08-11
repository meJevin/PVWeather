import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geocoder/geocoder.dart';

import 'main.dart';

class FCMMessageHandler extends StatefulWidget {
  FCMMessageHandler({
    Key key,
    this.currentLocationInfos,
  }) : super(key: key);


  List<LocationInfo> currentLocationInfos;

  @override
  _FCMMessageHandlerState createState() => _FCMMessageHandlerState();
}

class _FCMMessageHandlerState extends State<FCMMessageHandler> {

  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    super.initState();

    //if (Platform.isIOS) {
    //  _fcm.onIosSettingsRegistered.listen(
    //        (data) { saveDeviceToken(); },
    //  );
//
    //  _fcm.requestNotificationPermissions(
    //      IosNotificationSettings()
    //  );
    //} else {
    //  saveDeviceToken();
    //}

    saveDeviceToken();

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

    String fcmToken = await _fcm.getToken();

    if (fcmToken != null) {
      var tokenRef = _db
          .collection('users')
          .document(fcmToken)
          .collection('places');

      var placecFromDB = await _db.collection('users').document(fcmToken)
          .collection('places').getDocuments()
          .then((value) {
        for (int i = 0; i < value.documents.length; ++i) {
          widget.currentLocationInfos.add(
              LocationInfo(
                  Coordinates(
                      value.documents[i]['lat'],
                      value.documents[i]['lon']
                  ),
                  value.documents[i]['name'],
                  false
              )
          );
          setState(() {

          });
        }
      });


    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}