import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  static String routeName = "/change_pass";

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool loading = false;

  /// 👁 VISIBILITY STATES
  bool oldVisible = false;
  bool newVisible = false;
  bool confirmVisible = false;

  Future<void> updatePassword() async {
    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("New passwords do not match")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) return;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = "Error";

      if (e.code == "wrong-password") {
        msg = "Current password is incorrect";
      } else if (e.code == "weak-password") {
        msg = "Password is too weak";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password",style: TextStyle(
          color: Colors.white,
        ),),
        backgroundColor: Colors.deepPurple,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ================= OLD PASSWORD =================
            TextField(
              controller: oldPassController,
              obscureText: !oldVisible,
              decoration: InputDecoration(
                labelText: "Current Password",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    oldVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      oldVisible = !oldVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ================= NEW PASSWORD =================
            TextField(
              controller: newPassController,
              obscureText: !newVisible,
              decoration: InputDecoration(
                labelText: "New Password",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    newVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      newVisible = !newVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ================= CONFIRM PASSWORD =================
            TextField(
              controller: confirmPassController,
              obscureText: !confirmVisible,
              decoration: InputDecoration(
                labelText: "Confirm New Password",
                border: const OutlineInputBorder(),

                suffixIcon: IconButton(
                  icon: Icon(
                    confirmVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      confirmVisible = !confirmVisible;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: loading ? null : updatePassword,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password",style: TextStyle(
                  color: Colors.white,
                ),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}