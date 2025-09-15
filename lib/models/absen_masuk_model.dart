// To parse this JSON data, do
//
//     final absenMasukModel = absenMasukModelFromJson(jsonString);

import 'dart:convert';

AbsenCheckInModel absenMasukModelFromJson(String str) => AbsenCheckInModel.fromJson(json.decode(str));

String absenMasukModelToJson(AbsenCheckInModel data) => json.encode(data.toJson());

class AbsenCheckInModel {
    String? message;
    Data? data;

    AbsenCheckInModel({
        this.message,
        this.data,
    });

    factory AbsenCheckInModel.fromJson(Map<String, dynamic> json) => AbsenCheckInModel(
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    int? userId;
    DateTime? checkIn;
    String? checkInLocation;
    int? checkInLat;
    double? checkInLng;
    String? checkInAddress;
    String? status;
    dynamic alasanIzin;
    DateTime? updatedAt;
    DateTime? createdAt;
    int? id;

    Data({
        this.userId,
        this.checkIn,
        this.checkInLocation,
        this.checkInLat,
        this.checkInLng,
        this.checkInAddress,
        this.status,
        this.alasanIzin,
        this.updatedAt,
        this.createdAt,
        this.id,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        userId: json["user_id"],
        checkIn: json["check_in"] == null ? null : DateTime.parse(json["check_in"]),
        checkInLocation: json["check_in_location"],
        checkInLat: json["check_in_lat"],
        checkInLng: json["check_in_lng"]?.toDouble(),
        checkInAddress: json["check_in_address"],
        status: json["status"],
        alasanIzin: json["alasan_izin"],
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "user_id": userId,
        "check_in": checkIn?.toIso8601String(),
        "check_in_location": checkInLocation,
        "check_in_lat": checkInLat,
        "check_in_lng": checkInLng,
        "check_in_address": checkInAddress,
        "status": status,
        "alasan_izin": alasanIzin,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "id": id,
    };
}
