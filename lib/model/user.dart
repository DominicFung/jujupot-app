import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_api/amplify_api.dart';

import 'package:jujupot_app_v1/hommieoconfiguration.dart';

class User {
  bool loading = true;
  String error = "";
  String userId;

  String appId = "";
  String appSecret = "";

  static const String _userIdKey = "userId";
  static const String _userAccessKey = "userAccess";
  static const String _userCognitoIdKey = "userCognitoId";

  // needs to be overwritten
  String getAccessKey() {
    return "";
  }

  static final Future<SharedPreferences> _prefs =
      SharedPreferences.getInstance();

  User() : userId = "";

  Future<User> init() async {
    // -- Read Hommieo configurations -- //
    Map<String, dynamic> hommieoApp = jsonDecode(hommieoconfig);
    if (hommieoApp.containsKey("appId")) {
      appId = hommieoApp["appId"];
    } else {
      throw "No appId found in hommieoconfig.json";
    }

    if (hommieoApp.containsKey("appSecret")) {
      appSecret = hommieoApp["appSecret"];
    } else {
      throw "No appSecret found in hommieoconfig.json";
    }

    print("appId: $appId, appSecret: $appSecret");

    final SharedPreferences prefs = await _prefs;

    String savedUserId = prefs.getString(_userIdKey) ?? "";
    String savedCognitoId = prefs.getString(_userCognitoIdKey) ?? "";
    String savedAccessKey = prefs.getString(_userAccessKey) ?? "";

    if (savedUserId.isNotEmpty && savedCognitoId.isNotEmpty) {
      loading = false;
      return AuthenticatedUser(savedUserId, savedCognitoId);
    }

    // App has been open before, shuffle accessKey
    else if (savedUserId.isNotEmpty && savedAccessKey.isNotEmpty) {
      User u = await _exchangeToken(savedUserId, savedAccessKey);
      loading = false;
      return u;
    }

    // App open first time - create user
    else if (savedUserId.isEmpty && savedAccessKey.isEmpty) {
      User u = await createGuestUser();
      loading = false;
      return u;
    } else {
      loading = false;
      return NoneUser();
    }
  }

  Future<User> createGuestUser() async {
    final SharedPreferences prefs = await _prefs;

    RestOptions options = RestOptions(path: '/user/guest/create', headers: {
      'hommieo-app-identity': appId,
      'hommieo-app-secret': appSecret
    });
    RestOperation restOperation = Amplify.API.post(restOptions: options);
    RestResponse response = await restOperation.response;
    print(response.body);

    Map<String, dynamic> data = json.decode(response.body);

    if (data.containsKey("userId") && data.containsKey("accessKey")) {
      print(data["userId"]);
      prefs.setString(_userIdKey, data["userId"]);
      prefs.setString(_userAccessKey, data["accessKey"]);
      return GuestUser.fromJson(data);
    } else {
      print("UserId or AccessKey is empty!");
      // prefs.setString(_userIdKey, "");
      // prefs.setString(_userAccessKey, "");
      return NoneUser();
    }
  }

  Future<User> _exchangeToken(String userId, String accessKey) async {
    final SharedPreferences prefs = await _prefs;
    String body = json.encode({
      'userId': userId,
      'accessKey': accessKey,
    });

    RestOptions options = RestOptions(
        path: '/user/guest/shuffle-key',
        body: Uint8List.fromList(body.codeUnits));

    RestResponse response;
    try {
      RestOperation restOperation = Amplify.API.post(restOptions: options);
      response = await restOperation.response;
    } on RestException catch (e) {
      print(e.response.body);
      User u = NoneUser();
      u.error = e.response.body;
      return u;
    }

    Map<String, dynamic> data = json.decode(response.body);
    String newAccessKey = data["accessKey"] ?? "";
    print('newAccessKey: $newAccessKey');

    if (newAccessKey.isNotEmpty) {
      prefs.setString(_userIdKey, userId);
      prefs.setString(_userAccessKey, newAccessKey);
      return GuestUser(userId, newAccessKey);
    } else {
      return NoneUser();
    }
  }
}

class GuestUser extends User {
  @override
  String userId;
  String userAccess;

  GuestUser(this.userId, this.userAccess);
  GuestUser.fromJson(Map<String, dynamic> json)
      : userId = json['userId'],
        userAccess = json['accessKey'];

  Map<String, dynamic> toJson() {
    return {
      'userId': userId as dynamic,
      'accessKey': userAccess as dynamic,
    };
  }

  @override
  String getAccessKey() {
    return userAccess;
  }
}

class AuthenticatedUser extends User {
  late String cognitoId;

  AuthenticatedUser(userId, this.cognitoId) : super();

  @override
  String getAccessKey() {
    return "";
  }
}

class NoneUser extends User {
  NoneUser() : super();

  @override
  String getAccessKey() {
    return "";
  }
}

//class GuestUser extends User {}

//class AuthenticatedUser extends User {}
