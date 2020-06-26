import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:poolinspection/src/helpers/sharedpreferences/userpreferences.dart';
import 'package:poolinspection/src/repository/settings_repository.dart'
    as settingRepo;
import 'package:poolinspection/src/repository/user_repository.dart' as userRepo;
import 'package:poolinspection/config/app_config.dart';

class Controller extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;
  Controller() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  @override
  void initState() {
    // settingRepo.initSettings().then((setting) {
    //   setState(() {
    //     settingRepo.setting = setting;
    //   });
    // });
    // settingRepo.setCurrentLocation().then((locationData) {
    //   setState(() {
    //     settingRepo.locationData = locationData;
    //   });
    // });
    // UserSharedPreferencesHelper.logout();
    UserSharedPreferencesHelper.getCurrentToken().then((token) {
      setState(() {
        print("$token getCurrentToken token");
        userRepo.token = token;
      });
    });

    UserSharedPreferencesHelper.getCompanyDetail().then((company) {
      setState(() {
        print("${company.companyName} getCompanyDetail token");
        userRepo.company = company;
      });
    });

    UserSharedPreferencesHelper.getInspectorDetail().then((inspector) {
      setState(() {
        print("${inspector.id} getInspectorid token");
        userRepo.inspector = inspector;
      });
    });
    UserSharedPreferencesHelper.getUserDetails().then((user) {
      setState(() {
        // print("${user.userdata.inspector.firstName } controller user id");
        print("${user.id} userid getUserDetails");
        userRepo.user = user;
      });
    });
  }
}
