import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../business/models/user/user.dart';
import '../../../business/services/user/userNetworkService.dart';
import '../../../main.dart';
import 'kycState.dart';

class KycController extends StateNotifier<KycState> {
  final UserNetworkService _networkService=getIt.get<UserNetworkService>();
  KycController():super(KycState());
  Future<void> pickDocument(String type) async { File? file; if(type=='selfie'){final x=await ImagePicker().pickImage(source:ImageSource.camera,imageQuality:75);if(x!=null)file=File(x.path);}else{final r=await FilePicker.platform.pickFiles(type:FileType.custom,allowedExtensions:['pdf','jpg','jpeg','png']);if(r?.files.single.path!=null)file=File(r!.files.single.path!);} if(file==null)return; if(type=='identity')state=state.copyWith(identityDoc:file);if(type=='registration')state=state.copyWith(registrationCard:file);if(type=='business')state=state.copyWith(businessLicense:file);if(type=='selfie')state=state.copyWith(selfie:file); }
  Future<bool> submitKyc(User user) async { if(state.identityDoc==null||state.registrationCard==null||state.businessLicense==null){state=state.copyWith(error:'Veuillez ajouter tous les documents requis.');return false;} state=state.copyWith(isLoading:true,error:null);try{final created=await _networkService.registerUser(user,profilePhoto:state.selfie??(user.photo!=null?File(user.photo!):null),identityDoc:state.identityDoc,registrationCard:state.registrationCard,businessLicense:state.businessLicense);state=state.copyWith(isLoading:false);return created!=null;}catch(e){state=state.copyWith(isLoading:false,error:_parseError(e));return false;} }
  String _parseError(dynamic e){try{final raw=e.toString();if(raw.contains('{')){final d=jsonDecode(raw.substring(raw.indexOf('{')));if(d['errors']!=null)return(d['errors']as Map).values.map((v)=>(v as List).join()).join('\n');return d['message']??raw;}}catch(_){}return e.toString().replaceAll('Exception: ','');}
}
final kycControllerProvider=StateNotifierProvider<KycController,KycState>((ref)=>KycController());
