class VerifyOtp {
  String? email;
  String? otp;

  VerifyOtp({
    this.email,
    this.otp,
  });

  factory VerifyOtp.fromJson(Map<String, dynamic> json) => VerifyOtp(
    email: json["email"],
    otp: json["opt"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
  };
}
