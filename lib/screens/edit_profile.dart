import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Color(0xFFF8F9FB);

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String phone;
  final String location;
  final String? imagePath;
  final String dob;
  final String gender;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.location,
    required this.dob,
    required this.gender,
    this.imagePath,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController locCtrl;
  late TextEditingController dobCtrl;
  late TextEditingController genderCtrl;

  File? imageFile;
  String base64Image = "";
  bool isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    nameCtrl = TextEditingController(text: widget.name);
    phoneCtrl = TextEditingController(text: widget.phone);
    locCtrl = TextEditingController(text: widget.location);
    dobCtrl = TextEditingController(text: widget.dob);
    genderCtrl = TextEditingController(text: widget.gender);

    base64Image = widget.imagePath ?? "";
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    locCtrl.dispose();
    dobCtrl.dispose();
    genderCtrl.dispose();
    super.dispose();
  }

  /// ================= PICK IMAGE =================
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (picked != null) {
      imageFile = File(picked.path);
      base64Image = base64Encode(await imageFile!.readAsBytes());
      setState(() {});
    }
  }

  /// ================= DATE PICKER =================
  Future<void> pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dobCtrl.text =
        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  /// ================= SAVE =================
  Future<void> saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .set({
        "fullName": nameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "location": locCtrl.text.trim(),

        // NEW FIELDS
        "dateOfBirth": dobCtrl.text.trim(),
        "gender": genderCtrl.text.trim(),

        "image": base64Image,
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            /// ================= PROFILE CARD =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ],
              ),

              child: Column(
                children: [

                  /// PROFILE IMAGE
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: Colors.grey.shade200,

                        backgroundImage: imageFile != null
                            ? FileImage(imageFile!)
                            : (base64Image.isNotEmpty
                            ? MemoryImage(base64Decode(base64Image))
                            : null),

                        child: (imageFile == null &&
                            base64Image.isEmpty)
                            ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                            : null,
                      ),

                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// FORM
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        _buildField(
                          nameCtrl,
                          "Full Name",
                          Icons.person,
                        ),

                        _buildField(
                          phoneCtrl,
                          "Phone",
                          Icons.phone,
                        ),

                        _buildField(
                          locCtrl,
                          "Location",
                          Icons.location_on,
                        ),

                        /// DATE OF BIRTH
                        Padding(
                          padding:
                          const EdgeInsets.only(bottom: 15),
                          child: TextFormField(
                            controller: dobCtrl,
                            readOnly: true,
                            onTap: pickDate,

                            validator: (value) =>
                            value == null || value.isEmpty
                                ? "Date of Birth is required"
                                : null,

                            decoration: InputDecoration(
                              labelText: "Date of Birth",

                              prefixIcon: const Icon(
                                Icons.calendar_today,
                                color: kPrimaryColor,
                              ),

                              filled: true,
                              fillColor: kSecondaryColor,

                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        /// GENDER FIELD
                        _buildField(
                          genderCtrl,
                          "Gender",
                          Icons.people,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                  const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Save Changes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= TEXT FIELD WITH ICON =================
  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),

      child: TextFormField(
        controller: controller,

        validator: (value) =>
        value == null || value.isEmpty
            ? "$label is required"
            : null,

        decoration: InputDecoration(
          labelText: label,

          prefixIcon: Icon(
            icon,
            color: kPrimaryColor,
          ),

          filled: true,
          fillColor: kSecondaryColor,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}