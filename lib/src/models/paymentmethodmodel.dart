// To parse this JSON data, do
//
//     final addPAymentModel = addPAymentModelFromJson(jsonString);

import 'dart:convert';

AddPAymentModel addPAymentModelFromJson(String str) => AddPAymentModel.fromJson(json.decode(str));

String addPAymentModelToJson(AddPAymentModel data) => json.encode(data.toJson());

class AddPAymentModel {
  String status;
  String messages;
  int error;

  AddPAymentModel({
    this.status,
    this.messages,
    this.error,
  });

  factory AddPAymentModel.fromJson(Map<String, dynamic> json) => AddPAymentModel(
    status: json["status"],
    messages: json["messages"],
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "messages": messages,
    "error": error,
  };
}
