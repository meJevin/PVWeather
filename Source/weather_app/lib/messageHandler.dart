import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geocoder/geocoder.dart';

import 'main.dart';

class FirebaseConnector  {
  FirebaseConnector({
    this.currentLocationInfos,
  });

  String fcmToken;

  Firestore _db = Firestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  List<LocationInfo> currentLocationInfos;

  DocumentReference userDocRef =  null;
  CollectionReference userPlacesRef = null;

  void GetUserPlaces() {
    userPlacesRef.getDocuments().then((value) {
      for (int i = 0; i < value.documents.length; ++i) {
        currentLocationInfos.add(
            LocationInfo(
                Coordinates(
                    value.documents[i]['lat'],
                    value.documents[i]['lon']
                ),
                value.documents[i]['name'],
                false,
              value.documents[i].documentID
            )
        );
      }
    });
  }

  Future<Null> AddUserPlace(LocationInfo newInfo) async {
    userPlacesRef.add(
      {
        'lon': newInfo.coordinates.longitude,
        'lat': newInfo.coordinates.latitude,
        'name': newInfo.name,
      }
    ).then((val){
      newInfo.ID = val.documentID;
    });

    currentLocationInfos.add(newInfo);
  }

  Future<Null> RemoveUserPlace(String infoIDToDelete) async {
    userPlacesRef.document(infoIDToDelete).delete();

    currentLocationInfos.removeWhere((info) {
      return info.ID == infoIDToDelete;
    });
  }

  Future<Null> Init() async {

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
      },

      onLaunch: (Map<String, dynamic> message) async {

      },

      onResume: (Map<String, dynamic> message) async {

      },
    );

    fcmToken = await _fcm.getToken();

    if (fcmToken != null) {

      // Get reference to user document
      if (userDocRef == null) {
        userDocRef = _db
            .collection('users')
            .document(fcmToken);
      }

      // Check if the user is launching app for the first time and in that case create a record for him
      userDocRef.get().then((value) {
        if (value.data == null) {
          userDocRef.setData({
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Get reference to places collection of current user
      if (userPlacesRef == null) {
        userPlacesRef = userDocRef.collection('places');
      }

    }
  }

}
