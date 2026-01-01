import 'libs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize storage FIRST
  await StorageService.instance.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pawfect Vendor App',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 300),
      theme: AppTheme.theme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
