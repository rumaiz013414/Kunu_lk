import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:testing/customer_screens/customer_profile/customer_profile_details.dart';
import 'package:testing/customer_screens/customer_profile/customer_profile_photo.dart';
import 'package:testing/garbage_collector_screens/garbage_collector_profile/garbage_profile_details.dart';
import 'package:testing/garbage_collector_screens/garbage_collection_routes.dart';
import 'authentication_screens/login_screen.dart';
import 'authentication_screens/registration_screen.dart';
import 'authentication_screens/password_reset_screen.dart';
import 'customer_screens/customer_home_routes.dart';
import 'garbage_collector_screens/get_garbage_collector_information_form.dart';
import 'garbage_collector_screens/garbage_collector_home.dart';
import 'admin_screens/admin_home.dart';
import 'customer_screens/customer_info_form.dart';
import 'services/auth_wrapper.dart';
import 'garbage_collector_screens/garbage_collector_profile/edit_garbage_profile.dart';
import 'customer_screens/customer_profile/edit_customer_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kunu.Lk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/customerHome': (context) => CustomerHomePage(),
        '/garbageCollectorHome': (context) => GarbageCollectorHomePage(),
        '/adminHome': (context) => AdminHome(),
        '/reset': (context) => PasswordResetPage(),
        '/customerProfile': (context) => CustomerProfileDetails(),
        '/customerProfilePhoto': (context) => CustomerProfilePhotoPage(),
        '/editGarbageProfile': (context) => EditGarbageProfilePage(),
        '/garbageCollectorProfile': (context) =>
            GarbageCollectorProfileSection(),
        '/editCustomerProfile': (context) => EditCustomerProfilePage(),
        '/customerInfoForm': (context) => CustomerInfoFormPage(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/garbageCollectorInfoForm': (context) => GarbageCollectorInfoFormPage(
              user: ModalRoute.of(context)!.settings.arguments as User,
            ),
        '/garbageCollectionRoutes': (context) => GarbageCollectionRoutes(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/customerInfoForm') {
          final User user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) {
              return CustomerInfoFormPage(user: user);
            },
          );
        } else if (settings.name == '/garbageCollectorInfoForm') {
          final User user = settings.arguments as User;
          return MaterialPageRoute(
            builder: (context) {
              return GarbageCollectorInfoFormPage(user: user);
            },
          );
        }
        return null;
      },
    );
  }
}
