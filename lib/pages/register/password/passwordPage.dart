import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../registerCtrl.dart';

class RegisterPasswordPage extends ConsumerStatefulWidget { const RegisterPasswordPage({super.key}); @override ConsumerState<RegisterPasswordPage> createState()=>_RegisterPasswordPageState(); }
class _RegisterPasswordPageState extends ConsumerState<RegisterPasswordPage> {
  final _form=GlobalKey<FormState>(); final _password=TextEditingController(); final _confirm=TextEditingController(); bool _hide=true;
  @override void dispose(){_password.dispose();_confirm.dispose();super.dispose();}
  Future<void> _continue() async {
    if(!_form.currentState!.validate())return;
    final ctrl=ref.read(registerControlProvider.notifier); ctrl.setPassword(_password.text);
    final user=ref.read(registerControlProvider).user; if(user==null)return;
    if(user.role=='passenger'){
      final ok=await ctrl.register(user); if(ok&&mounted)context.go('/public/otp',extra:{'email':user.email!,'role':user.role});
    } else { if(mounted)context.push('/public/kyc'); }
  }
  @override Widget build(BuildContext context){final state=ref.watch(registerControlProvider);final theme=Theme.of(context);final cs=theme.colorScheme;return Scaffold(backgroundColor:theme.scaffoldBackgroundColor,appBar:AppBar(title:Text('Sécurité du compte',style:TextStyle(color:cs.onSurface,fontWeight:FontWeight.bold)),backgroundColor:Colors.transparent,elevation:0),body:Padding(padding:const EdgeInsets.all(25),child:Form(key:_form,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Créez votre mot de passe',style:theme.textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),const SizedBox(height:8),Text('Utilisez au minimum 8 caractères.',style:TextStyle(color:cs.onSurface.withOpacity(.65))),const SizedBox(height:30),TextFormField(controller:_password,obscureText:_hide,decoration:InputDecoration(hintText:'Mot de passe',suffixIcon:IconButton(onPressed:()=>setState(()=>_hide=!_hide),icon:Icon(_hide?Icons.visibility_outlined:Icons.visibility_off_outlined))),validator:(v)=>(v??'').length<8?'Minimum 8 caractères':null),const SizedBox(height:15),TextFormField(controller:_confirm,obscureText:_hide,decoration:const InputDecoration(hintText:'Confirmer le mot de passe'),validator:(v)=>v!=_password.text?'Les mots de passe ne correspondent pas':null),if(state.error!=null)...[const SizedBox(height:15),Text(state.error!,style:TextStyle(color:cs.error))],const Spacer(),SizedBox(width:double.infinity,height:55,child:ElevatedButton(onPressed:state.isLoading?null:_continue,child:state.isLoading?CircularProgressIndicator(color:cs.onPrimary):const Text('Continuer',style:TextStyle(fontWeight:FontWeight.bold))))]))));}
}
