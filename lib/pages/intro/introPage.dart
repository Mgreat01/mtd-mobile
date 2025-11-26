import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../utils/navigationUtils.dart';
import 'appCtrl.dart';

class IntroPage extends ConsumerStatefulWidget {
  const IntroPage({super.key});

  @override
  ConsumerState<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends ConsumerState<IntroPage> {
  var navigation = getIt<NavigationUtils>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var ctrl = ref.read(appCtrlProvider.notifier);
      ctrl.getUser();
      //
      Future.delayed(Duration(seconds: 2), () {
        navigation.goNamed('home_page');
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_motoTaxi_Digital.png', width: 300, height: 300, fit: BoxFit.contain,),
            SizedBox(height: 80),
            CircularProgressIndicator(color: Colors.blue,)

          ],
        ),
      ),
    );
  }
}
