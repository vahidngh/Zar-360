class AuthResponse {
  final dynamic data;
  final List<String> errors;

  AuthResponse({
    required this.data,
    required this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      data: json['data'],
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get isSuccess => errors.isEmpty;
}

class SendOtpResponse {
  final String? message;
  final List<String> errors;

  SendOtpResponse({
    this.message,
    required this.errors,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
      message: json['data'] != null && json['data'] is Map
          ? json['data']['message'] as String?
          : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get isSuccess => errors.isEmpty && message != null;
}

class Seller {
  final String mobile;
  final String name;

  Seller({
    required this.mobile,
    required this.name,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      mobile: json['mobile'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class VerifyOtpResponse {
  final String? accessToken;
  final Seller? seller;
  final List<String> errors;

  VerifyOtpResponse({
    this.accessToken,
    this.seller,
    required this.errors,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] != null && json['data'] is Map ? json['data'] as Map<String, dynamic> : null;
    return VerifyOtpResponse(
      accessToken: data?['access_token'] as String?,
      seller: data?['seller'] != null ? Seller.fromJson(data!['seller'] as Map<String, dynamic>) : null,
      errors: json['errors'] != null
          ? List<String>.from(json['errors'])
          : [],
    );
  }

  bool get isSuccess => errors.isEmpty && accessToken != null;
}

