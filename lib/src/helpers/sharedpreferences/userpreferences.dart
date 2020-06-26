import 'dart:convert';

import 'package:poolinspection/src/models/user.dart';
import 'package:poolinspection/src/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSharedPreferencesHelper {
  static final String roles = "roles";
  static final String userid = "userid";
  static final String useremail = "useremail";
  static final String token = "token";
  static final String status = "status";
  static final String is_password_approved = "is_password_approved";
  static final String is_password_change = "is_password_change";
  static final String inspectorDetail = "inspectordetail";
  static final String companyDetail = "companydetail";
  static final String userDetail = "userdetail";

  static Future<bool> setUserdetails(jsonString) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // await prefs.setInt(
    //     userid, json.decode(jsonString)['userdata']['user']['id']);
    // await prefs.setString(
    //     useremail, json.decode(jsonString)['userdata']['user']['email']);
    // await prefs.setInt(
    //     status, json.decode(jsonString)['userdata']['user']['status']);
    // await prefs.setInt(is_password_approved,
    //     json.decode(jsonString)['userdata']['user']['is_password_approved']);
    // await prefs.setInt(is_password_change,
    //     json.decode(jsonString)['userdata']['user']['is_password_change']);
    // await prefs.setInt(
    //     roles, json.decode(jsonString)['userdata']['user']['roles_manage']);
    await prefs.setString(token, json.encode(json.decode(jsonString)['token']));
    if (json.decode(jsonString)['userdata']['inspector'] != null) {
      await prefs.setString(inspectorDetail,
          json.encode(json.decode(jsonString)['userdata']['inspector']));
    } else if (json.decode(jsonString)['userdata']['company'] != null) {
      await prefs.setString(companyDetail,
          json.encode(json.decode(jsonString)['userdata']['company']));
    }
    if (json.decode(jsonString)['userdata']['user'] != null) {
      await prefs.setString(
          userDetail, json.encode(json.decode(jsonString)['userdata']['user']));
    }
  }

  static Future<User> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//  prefs.clear();
    if (prefs.containsKey(userDetail)) {
      user = User.fromJSON(json.decode(await prefs.get(userDetail)));
    }
    return user;
  }

  static Future<Inspector> getInspectorDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(inspectorDetail)) {
      inspector =
          Inspector.fromJSON(json.decode(await prefs.get(inspectorDetail)));
    }
    return inspector;
  }

  static Future<Company> getCompanyDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(companyDetail)) {
      company = Company.fromJSON(json.decode(await prefs.get(companyDetail)));
    }
    return company;
  }

  static Future<int> getUserid() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(userid)) {
      return prefs.getInt(userid) ?? 0;
    }
  }

  static Future<String> getUserEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(useremail)) {
      return prefs.getString(useremail) ?? null;
    }
  }

  static Future<int> getUserStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(status)) {
      return prefs.getInt(status) ?? 0;
    }
  }

  static Future<int> getIsPasswordApproved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(is_password_approved)) {
      return prefs.getInt(is_password_approved) ?? 0;
    }
  }

  static Future<int> getIsPasswordChange() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(is_password_change)) {
      return prefs.getInt(is_password_change) ?? 0;
    }
  }

  static Future<int> getRoles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(roles)) {
      return prefs.getInt(roles) ?? 0;
    }
  }

  static Future<String> getCurrentToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(token)) {
      return prefs.getString(token) ?? null;
    }
    else{
      return null;
    }
  }

  static Future<String> logout() async {
    currentUser = new UserModel();
    inspector = new Inspector();
    company = new Company();
    user = new User();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
}
