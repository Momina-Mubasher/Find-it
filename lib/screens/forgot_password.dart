import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color kPrimaryColor = Colors.deepPurple;

class ForgotPasswordScreen extends StatefulWidget {
  static String routeName = "/forgot_password_screen";

  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  final RegExp emailValidatorRegExp =
  RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");

  /// ================== RESET PASSWORD ==================
  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset link sent to your email"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong";

      if (e.code == "user-not-found") {
        message = "No account found with this email";
      } else if (e.code == "invalid-email") {
        message = "Invalid email address";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// BACKGROUND IMAGE (same style as login)
        Image.asset(
          "assets/images/login1.png",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.
                        withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// TITLE
                            const Text(
                              "Forgot Password",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryColor,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Enter your email to receive reset link",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black87),
                            ),

                            const SizedBox(height: 30),

                            /// EMAIL FIELD
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                if (!emailValidatorRegExp.hasMatch(value)) {
                                  return "Enter a valid email";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                labelText: "Email",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                              ),
                            ),

                            const SizedBox(height: 25),

                            /// RESET BUTTON
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                isLoading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                  color: kPrimaryColor,
                                )
                                    : const Text(
                                  "Send Reset Link",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryColor,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 15),

                            /// BACK BUTTON
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Back to Sign In",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}