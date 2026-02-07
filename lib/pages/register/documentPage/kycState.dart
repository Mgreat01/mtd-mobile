import 'dart:io';

class KycState {
  final File? identityDoc;
  final File? registrationCard;
  final File? businessLicense;
  final File? selfie;
  final bool isLoading;
  final String? error;

  KycState({
    this.identityDoc,
    this.registrationCard,
    this.businessLicense,
    this.selfie,
    this.isLoading = false,
    this.error,
  });

  KycState copyWith({
    File? identityDoc,
    File? registrationCard,
    File? businessLicense,
    File? selfie,
    bool? isLoading,
    String? error,
  }) {
    return KycState(
      identityDoc: identityDoc ?? this.identityDoc,
      registrationCard: registrationCard ?? this.registrationCard,
      businessLicense: businessLicense ?? this.businessLicense,
      selfie: selfie ?? this.selfie,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}