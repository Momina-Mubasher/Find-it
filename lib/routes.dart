

// We use name route
// All our routes will be available here
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_vs/screens/forgot_password.dart';
import 'package:flutter_application_vs/screens/home.dart';
import 'package:flutter_application_vs/screens/my_post.dart';
import 'package:flutter_application_vs/screens/profile.dart';
import 'package:flutter_application_vs/screens/sign_in.dart';
import 'package:flutter_application_vs/screens/sign_up.dart';
import 'package:flutter_application_vs/screens/splash.dart';
import 'package:flutter_application_vs/screens/upload_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => const SplashScreen(),
  SignInScreen.routeName: (context) => const SignInScreen(),
  SignUpScreen.routeName: (context) => const SignUpScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  UploadItem.routeName: (context) => const UploadItem(),
  ProfileScreen.routeName: (context) => const ProfileScreen(),
  PostScreen.routeName: (context) => const PostScreen(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
};




