import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_vs/screens/edit_profile.dart';
import 'package:flutter_application_vs/screens/sign_in.dart';
import 'package:flutter_application_vs/screens/change_pass.dart';

const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Color(0xFFF8F9FB);
const Color kGreyText = Color(0xFF7F8C8D);

class ProfileScreen extends StatefulWidget {
  static const String routeName = "/profile";

  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String phone = "";
  String location = "";
  String imageBase64 = "";
  String dob = "";
  String gender = "";
  bool isLoading = true;

  /// ================= CHANGE PROFILE IMAGE =================
  Future<void> changeProfileImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      if (picked == null) return;

      File imageFile = File(picked.path);

      String newBase64 =
      base64Encode(await imageFile.readAsBytes());

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "image": newBase64,
      }, SetOptions(merge: true));

      setState(() {
        imageBase64 = newBase64;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Profile picture updated"),
        ),
      );
    } catch (e) {
      debugPrint("IMAGE UPDATE ERROR => $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// ================= LOAD DATA =================
  Future<void> loadUserData() async {
    try {
      setState(() => isLoading = true);

      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          name = data["fullName"] ?? "";
          phone = data["phone"] ?? "";
          location = data["location"] ?? "";
          imageBase64 = data["image"] ?? "";
          dob = data["dateOfBirth"] ?? "";
          gender = data["gender"] ?? "";
          /// email ALWAYS from FirebaseAuth
          email = user.email ?? "";

          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("PROFILE LOAD ERROR => $e");
      setState(() => isLoading = false);
    }
  }

  /// ================= EDIT PROFILE =================
  Future<void> editProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          name: name,
          phone: phone,
          location: location,
          dob: dob,
          gender: gender,
          imagePath: imageBase64,
        ),
      ),
    );

    await loadUserData();
  }

  /// ================= Change Password =================
  Future<void> changePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }


  /// ================= LOGOUT =================
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,

      appBar: AppBar(
        backgroundColor: kSecondaryColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),

        child: Column(
          children: [

            /// ================= PROFILE IMAGE ================
            Stack(
              children: [

                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,

                  backgroundImage: imageBase64.isNotEmpty
                      ? MemoryImage(base64Decode(imageBase64))
                      : null,

                  child: imageBase64.isEmpty
                      ? const Icon(
                    Icons.person,
                    size: 55,
                    color: Colors.grey,
                  )
                      : null,
                ),

                /// CAMERA BUTTON
                Positioned(
                  bottom: 0,
                  right: 0,

                  child: GestureDetector(
                    onTap: changeProfileImage,

                    child: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// ================= NAME =================
            Text(
              name.isEmpty ? "No Name" : name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            /// ================= EMAIL =================
            Text(
              email,
              style: const TextStyle(
                color: kGreyText,
                fontSize: 15,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 75,

              child: Image.asset(
                "assets/images/w.png",
                fit: BoxFit.fitWidth,
              ),
            ),
            const SizedBox(height: 18),

            /// ================= INFO CARD =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.phone, "Phone", phone),
                  const Divider(height: 25),
                  _infoRow(Icons.location_on, "Location", location),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= BUTTONS =================
            _button(Icons.edit, "Edit Profile", editProfile),
            _button(Icons.lock, "Change Password", changePassword),
            _button(Icons.logout, "Logout", logout, Colors.red),

          ],
        ),
      ),
    );
  }

  /// ================= INFO ROW =================
  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: kPrimaryColor),
        const SizedBox(width: 12),

        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value.isEmpty ? "Not Set" : value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: kGreyText),
          ),
        ),
      ],
    );
  }

  /// ================= BUTTON =================
  Widget _button(
      IconData icon,
      String text,
      VoidCallback onTap, [
        Color color = kPrimaryColor,
      ]) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),

          child: Padding(
            padding: const EdgeInsets.all(14),

            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),

                Text(text),

                const Spacer(),

                const Icon(Icons.arrow_forward_ios, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}