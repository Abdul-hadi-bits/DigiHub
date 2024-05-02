// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

class FireUser {
  String? firstName = "";
  String? lastName = "";
  String? location = "";
  String? gender = "";
  String? profilePicture = "";

  FireUser({
    this.firstName,
    this.lastName,
    this.location,
    this.gender,
    this.profilePicture,
  });

  FireUser copyWith({
    String? firstName,
    String? lastName,
    String? location,
    String? gender,
    String? profilePicture,
    User? user,
  }) {
    return FireUser(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'gender': gender,
      'profilePicture': profilePicture,
    };
  }

  factory FireUser.fromMap(Map<String, dynamic> map) {
    return FireUser(
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      location: map['location'] != null ? map['location'] as String : null,
      gender: map['gender'] != null ? map['gender'] as String : null,
      profilePicture:
          map['imageUrl'] != null ? map['imageUrl'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory FireUser.fromJson(String source) =>
      FireUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'FireUser(firstName: $firstName, lastName: $lastName, location: $location, gender: $gender, profilePicture: $profilePicture)';
  }

  @override
  bool operator ==(covariant FireUser other) {
    if (identical(this, other)) return true;

    return other.firstName == firstName &&
        other.lastName == lastName &&
        other.location == location &&
        other.gender == gender &&
        other.profilePicture == profilePicture;
  }

  @override
  int get hashCode {
    return firstName.hashCode ^
        lastName.hashCode ^
        location.hashCode ^
        gender.hashCode ^
        profilePicture.hashCode;
  }
}
