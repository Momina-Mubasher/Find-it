import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';

import '../component/bottomnav.dart';

/// ================== CONSTANTS ==================
const Color kPrimaryColor = Colors.deepPurple;

final RegExp emailValidatorRegExp =
RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");

const String kEmailNullError = "Please enter your email";
const String kInvalidEmailError = "Invalid email";
const String kPassNullError = "Please enter your password";
const String kShortPassError = "Password too short";

/// ================== SIGN IN SCREEN ==================
class SignInScreen extends StatelessWidget {
  static String routeName = "/sign_in";

  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/images/login1.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        const Scaffold(
          backgroundColor: Colors.transparent,
          body: SignInBody(),
        ),
      ],
    );
  }
}

/// ================== BODY ==================
class SignInBody extends StatelessWidget {
  const SignInBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 220, 20, 20),
        child: Column(
          children: [
            const Text(
              "Sign In",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),

            const SizedBox(height: 40),

            const SignForm(),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? "),

                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, "/sign_up"),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// ================== SIGN FORM ==================
class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  State<SignForm> createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();

  String? email;
  String? password;

  bool remember = false;
  bool isLoading = false;
  bool obscurePassword = true;

  List<String> errors = [];

  void addError(String error) {
    if (!errors.contains(error)) {
      setState(() => errors.add(error));
    }
  }

  void removeError(String error) {
    if (errors.contains(error)) {
      setState(() => errors.remove(error));
    }
  }

  /// ================== SUCCESS POPUP ==================
  void showLoginSuccessPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle,
                color: Color(0xFFa23ae8),
                size: 60,
              ),

              SizedBox(height: 15),

              Text(
                "Login Successful 🎉",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFa23ae8),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomBottomNavBar(),
        ),
            (route) => false,
      );
    });
  }

  /// ================== LOGIN FUNCTION ==================
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      /// FIREBASE LOGIN
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!.trim(),
        password: password!.trim(),
      );

      if (!mounted) return;

      showLoginSuccessPopup(context);
    }

    on FirebaseAuthException catch (e) {
      String errorMessage = "Login Failed";

      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      }

      else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      }

      else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email";
      }

      else if (e.code == 'invalid-credential') {
        errorMessage = "Invalid email or password";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
        ),
      );
    }

    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                /// EMAIL
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  onSaved: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return kEmailNullError;
                    }

                    if (!emailValidatorRegExp.hasMatch(value)) {
                      return kInvalidEmailError;
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",

                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: kPrimaryColor,
                    ),

                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                /// PASSWORD
                TextFormField(
                  obscureText: obscurePassword,
                  onSaved: (value) => password = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return kPassNullError;
                    }
                    if (value.length < 8) {
                      return kShortPassError;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",

                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: kPrimaryColor,
                    ),

                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(),

                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),

                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// REMEMBER ME
                Row(
                  children: [
                    Checkbox(
                      value: remember,
                      onChanged: (value) {
                        setState(() {
                          remember = value ?? false;
                        });
                      },
                    ),

                    const Text("Remember me"),

                    const Spacer(),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/forgot_password_screen");
                      },
                      child: const Text(
                        "Forgot Password",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                /// ERRORS
                Column(
                  children: errors
                      .map(
                        (e) => Text(
                      e,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  )
                      .toList(),
                ),

                const SizedBox(height: 20),

                /// BUTTON
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(
                      color: kPrimaryColor,
                    )
                        : const Text(
                      "Sign In",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}