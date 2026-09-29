class VerifyOtp {
  final String email;
  final String otp;

  VerifyOtp({required this.email, required this.otp});

  factory VerifyOtp.fromJson(Map<String, dynamic> json) => VerifyOtp(
    email: json["email"] ?? '',
    otp: json["otp"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}