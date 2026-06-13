import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kPrimaryColor = Colors.deepPurple;

double getProportionateScreenWidth(double inputWidth) => inputWidth;

class SignUpScreen extends StatelessWidget {
  static String routeName = "/sign_up";

  const SignUpScreen({super.key});

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
          body: SignUpBody(),
        ),
      ],
    );
  }
}

class SignUpBody extends StatelessWidget {
  const SignUpBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 120),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(20),
            ),
            child: Column(
              children: [
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Join FindIt and help the community reconnect with what matters",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 30),
                const SignUpForm(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/sign_in");
                      },
                      child: const Text(
                        "Sign in",
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
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  String? fullName;
  String? email;
  String? password;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  bool isLoading = false;

  final passwordCtrl = TextEditingController();

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      /// 🔐 CREATE USER
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email!.trim(),
        password: password!.trim(),
      );

      /// 🗄 SAVE USER DATA IN FIRESTORE
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "fullName": fullName ?? "",
        "email": email ?? "",
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully")),
      );

      Navigator.pushReplacementNamed(context, "/sign_in");
    }

    /// ❌ FIREBASE AUTH ERROR
    on FirebaseAuthException catch (e) {
      debugPrint("AUTH ERROR: $e");

      String msg = "Signup Failed";

      if (e.code == "email-already-in-use") {
        msg = "Email already exists";
      } else if (e.code == "weak-password") {
        msg = "Password must be at least 6 characters";
      } else if (e.code == "invalid-email") {
        msg = "Invalid email";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }

    /// ❌ OTHER ERROR
    catch (e) {
      debugPrint("UNKNOWN ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: $e")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          /// FULL NAME
          TextFormField(
            onSaved: (v) => fullName = v,

            decoration: InputDecoration(
              labelText: "Full Name",

              prefixIcon: const Icon(
                Icons.person_outline,
                color: kPrimaryColor,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),

            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return "Enter full name";
              }

              if (v.trim().length < 3) {
                return "Minimum 3 characters required";
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          /// EMAIL
          TextFormField(
            keyboardType: TextInputType.emailAddress,
            onSaved: (v) => email = v,

            decoration: InputDecoration(
              labelText: "Email",

              prefixIcon: const Icon(
                Icons.email_outlined,
                color: kPrimaryColor,
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),

            validator: (v) {
              final emailRegex =
              RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");

              if (v == null || v.isEmpty) {
                return "Email is required";
              }

              if (!emailRegex.hasMatch(v)) {
                return "Enter valid email";
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          /// PASSWORD
          TextFormField(
            controller: passwordCtrl,
            obscureText: obscurePassword,
            onSaved: (v) => password = v,

            decoration: InputDecoration(
              labelText: "Password",

              prefixIcon: const Icon(
                Icons.lock_outline,
                color: kPrimaryColor,
              ),

              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),

                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),

            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Password is required";
              }

              if (v.length < 6) {
                return "Minimum 6 characters required";
              }

              return null;
            },
          ),

          const SizedBox(height: 20),

          /// CONFIRM PASSWORD
          TextFormField(
            obscureText: obscureConfirmPassword,

            decoration: InputDecoration(
              labelText: "Confirm Password",

              prefixIcon: const Icon(
                Icons.lock_outline,
                color: kPrimaryColor,
              ),

              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),

                onPressed: () {
                  setState(() {
                    obscureConfirmPassword =
                    !obscureConfirmPassword;
                  });
                },
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),

            validator: (v) {
              if (v == null || v.isEmpty) {
                return "Confirm your password";
              }

              if (v != passwordCtrl.text) {
                return "Passwords do not match";
              }

              return null;
            },
          ),

          const SizedBox(height: 30),

          /// BUTTON
          SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : signUp,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}