class AuthResponseModel {
  final bool success;
  final String message;
  final bool? bypass;
  final String token;
  final UserModel user;

  AuthResponseModel({
    required this.success,
    required this.message,
    this.bypass,
    required this.token,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bypass: json['bypass'],
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'bypass': bypass,
      'token': token,
      'user': user.toJson(),
    };
  }
}

class UserModel {
  final String id;
  final String mobileNumber;
  final String userType;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.mobileNumber,
    required this.userType,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      userType: json['userType'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobileNumber': mobileNumber,
      'userType': userType,
      'isVerified': isVerified,
    };
  }
}
