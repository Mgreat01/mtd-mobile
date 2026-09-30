import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moto_taxi_digital_mobile/business/models/user/user.dart';
import 'package:moto_taxi_digital_mobile/pages/register/registerCtrl.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String role;
  final String phone;
  const RegisterPage({super.key, required this.role, required this.phone});
  @override ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  final _name = TextEditingController(); final _postnom = TextEditingController();
  final _prenom = TextEditingController(); final _gender = TextEditingController();
  final _birthDate = TextEditingController(); final _email = TextEditingController();
  final _commune = TextEditingController();

  @override void dispose() { for (final c in [_name,_postnom,_prenom,_gender,_birthDate,_email,_commune]) { c.dispose(); } super.dispose(); }
  Future<void> _pickImage() async { final x=await ImagePicker().pickImage(source: ImageSource.gallery,imageQuality:70); if(x!=null)setState(()=>_selectedImage=File(x.path)); }
  Future<void> _selectDate() async { final p=await showDatePicker(context:context,initialDate:DateTime(2000),firstDate:DateTime(1940),lastDate:DateTime.now()); if(p!=null)setState(()=>_birthDate.text=DateFormat('yyyy-MM-dd').format(p)); }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final user=User(name:_name.text.trim(),postnom:_postnom.text.trim(),prenom:_prenom.text.trim(),phone:widget.phone,gender:_gender.text,birthDate:_birthDate.text,commune:_commune.text.trim(),email:_email.text.trim(),role:widget.role,photo:_selectedImage?.path);
    ref.read(registerControlProvider.notifier).storeTempUser(user);
    context.push('/public/register-password');
  }

  @override Widget build(BuildContext context) {
    final theme=Theme.of(context); final cs=theme.colorScheme;
    return Scaffold(backgroundColor:theme.scaffoldBackgroundColor,appBar:AppBar(title:Text('Informations personnelles',style:TextStyle(color:cs.onSurface,fontWeight:FontWeight.bold)),backgroundColor:Colors.transparent,elevation:0,leading:IconButton(icon:Icon(Icons.arrow_back,color:cs.onSurface),onPressed:()=>context.pop())),body:SingleChildScrollView(padding:const EdgeInsets.all(25),child:Form(key:_formKey,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      _input(_name,'Nom',theme),const SizedBox(height:15),Row(children:[Expanded(child:_input(_postnom,'Post-nom',theme,required:false)),const SizedBox(width:15),Expanded(child:_input(_prenom,'Prénom',theme,required:false))]),const SizedBox(height:15),
      _input(_birthDate,'Date de naissance',theme,readOnly:true,onTap:_selectDate),const SizedBox(height:15),_genderDrop(theme),const SizedBox(height:15),_input(_email,'Adresse e-mail',theme,keyboardType:TextInputType.emailAddress,email:true),const SizedBox(height:15),_input(_commune,'Commune',theme),const SizedBox(height:25),
      Text('Photo de profil',style:TextStyle(fontWeight:FontWeight.bold,color:cs.onSurface)),const SizedBox(height:10),GestureDetector(onTap:_pickImage,child:Container(height:120,width:double.infinity,decoration:BoxDecoration(color:theme.inputDecorationTheme.fillColor,borderRadius:BorderRadius.circular(12),border:Border.all(color:cs.outline.withOpacity(.3))),child:_selectedImage!=null?ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.file(_selectedImage!,fit:BoxFit.cover)):Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.add_a_photo_outlined,color:cs.onSurface.withOpacity(.4),size:40),const SizedBox(height:8),Text('Ajouter une photo',style:TextStyle(color:cs.onSurface.withOpacity(.5)))]))),const SizedBox(height:35),
      SizedBox(width:double.infinity,height:55,child:ElevatedButton(onPressed:_continue,style:theme.elevatedButtonTheme.style,child:const Text('Continuer',style:TextStyle(fontWeight:FontWeight.bold,fontSize:16))))
    ]))));
  }

  Widget _input(TextEditingController c,String hint,ThemeData theme,{bool required=true,bool readOnly=false,VoidCallback? onTap,TextInputType keyboardType=TextInputType.text,bool email=false})=>TextFormField(controller:c,readOnly:readOnly,onTap:onTap,keyboardType:keyboardType,decoration:InputDecoration(hintText:hint,suffixIcon:readOnly?Icon(Icons.calendar_today,color:theme.colorScheme.primary):null),validator:(v){final x=v?.trim()??'';if(required&&x.isEmpty)return 'Ce champ est requis';if(email&&x.isNotEmpty&&!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(x))return 'Adresse e-mail invalide';return null;});
  Widget _genderDrop(ThemeData theme)=>DropdownButtonFormField<String>(dropdownColor:theme.colorScheme.surface,decoration:const InputDecoration(),items:const [DropdownMenuItem(value:'M',child:Text('Masculin')),DropdownMenuItem(value:'F',child:Text('Féminin'))],onChanged:(v)=>_gender.text=v??'',hint:const Text('Genre'),validator:(v)=>v==null?'Sélectionnez un genre':null);
}
