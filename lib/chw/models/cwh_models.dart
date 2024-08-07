class CwhModels {
  bool approved;
  String cwhId;
  String fullName;
  String email;
  String phoneNumber;
  String healthFacility;
  String position;
  String qualificationNumber;
  String villageTown;
  String countryValue;
  String cityValue;
  String stateValue;
  String cwhImage;

  CwhModels(
      {required this.approved,
      required this.cwhId,
      required this.fullName,
      required this.email,
      required this.phoneNumber,
      required this.healthFacility,
      required this.position,
      required this.qualificationNumber,
      required this.villageTown,
      required this.countryValue,
      required this.cityValue,
      required this.stateValue,
      required this.cwhImage});

  CwhModels.fromJson(Map<String, Object?> json)
      : this(
          approved: json['approved']! as bool,
          cwhId: json['cwhId']! as String,
          fullName: json['fullName']! as String,
          email: json['email']! as String,
          phoneNumber: json['phoneNumber']! as String,
          healthFacility: json['healthFacility']! as String,
          position: json['position']! as String,
          qualificationNumber: json['qualificationNumber']! as String,
          villageTown: json['villageTown']! as String,
          countryValue: json['countryValue']! as String,
          cityValue: json['cityValue']! as String,
          stateValue: json['stateValue']! as String,
          cwhImage: json['cwhImage']! as String,
        );

  Map<String, Object?> toJson() {
    return {
      'approved': approved,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'healthFacility': healthFacility,
      'position': position,
      'qualificationNumber': qualificationNumber,
      'villageTown': villageTown,
      'countryValue': countryValue,
      'cityValue': cityValue,
      'stateValue': stateValue,
      'cwhImage': cwhImage,
      'cwhId': cwhId,
    };
  }
}
