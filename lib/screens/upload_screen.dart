import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';



class UploadItem extends StatefulWidget {
  static const String routeName = "/upload";

  const UploadItem({Key? key}) : super(key: key);

  @override
  State<UploadItem> createState() => _UploadItemState();
}

class _UploadItemState extends State<UploadItem> {
  int _isLostOrFound = 0;

  // ✅ SINGLE IMAGE ONLY
  File? selectedImage;
  String? base64Image;

  final ImagePicker _picker = ImagePicker();

  final Color primaryPurple = const Color(0xFF6C5CE7);

  final TextEditingController _titleController =
  TextEditingController();

  final TextEditingController _descController =
  TextEditingController();

  final TextEditingController _locationController =
  TextEditingController();

  final TextEditingController _dateController =
  TextEditingController();

  String? _selectedCategory;

  final List<String> _categories = [

    "Wallets",
    "Bags",
    "Keys",
    "Cards",
    "Laptops",
    "Accessories",
    "Others",
  ];

  // ---------------- IMAGE PICK ----------------
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);

      List<int> imageBytes = await file.readAsBytes();
      String base64String = base64Encode(imageBytes);

      setState(() {
        selectedImage = file;
        base64Image = base64String;
      });
    }
  }

  // ---------------- DATE PICK ----------------
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null) return;

    setState(() {
      _dateController.text =
          DateFormat('dd MMM yyyy').format(picked);
    });
  }

  // ---------------- CLEAR ----------------
  void _clearForm() {
    _titleController.clear();
    _descController.clear();
    _locationController.clear();
    _dateController.clear();

    setState(() {
      _selectedCategory = null;
      selectedImage = null;
      base64Image = null;
      _isLostOrFound = 0;
    });
  }

  // ---------------- FIREBASE SUBMIT ----------------
  Future<void> _submit() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _selectedCategory == null ||
        base64Image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("User not logged in"),
          ),
        );
        return;
      }

      DocumentReference docRef =
      FirebaseFirestore.instance
          .collection("items")
          .doc();

      await docRef.set({
        "postId": docRef.id,
        "title": _titleController.text.trim(),
        "description": _descController.text.trim(),
        "location": _locationController.text.trim(),
        "date": _dateController.text.trim(),
        "category": _selectedCategory,
        "type": _isLostOrFound,

        // ✅ SINGLE IMAGE
        "images": [base64Image],

        "userId": user.uid,
        "userEmail": user.email,

        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post Added Successfully"),
        ),
      );

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
        ),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: primaryPurple,
          ),
          onPressed: () {},
        ),

        title: Column(
          children: const [
            Text(
              "Post an Item",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Text(
              "Help others by posting items",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(horizontal: 20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            _toggleSection(),

            const SizedBox(height: 25),

            const Text(
              "Add Photos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _imagePickerArea(),

            const SizedBox(height: 30),

            _buildTextField(
              "Item Title *",
              "e.g. Black Wallet",
              Icons.local_offer_outlined,
              controller: _titleController,
              maxLength: 60,
            ),

            _buildTextField(
              "Description *",
              "Describe item detail...",
              Icons.notes_outlined,
              controller: _descController,
              maxLines: 3,
              maxLength: 300,
            ),

            _buildTextField(
              "Location *",
              "Enter location manually",
              Icons.location_on_outlined,
              controller: _locationController,
            ),

            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: _buildTextField(
                  "Date & Time *",
                  "Select date",
                  Icons.calendar_today_outlined,
                  controller: _dateController,
                ),
              ),
            ),

            _buildCategoryDropdown(),

            const SizedBox(height: 30),

            _postButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------- CATEGORY ----------------
  Widget _buildCategoryDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: DropdownButtonFormField<String>(
        value: _selectedCategory,

        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.grid_view_outlined,
            color: primaryPurple,
          ),

          filled: true,
          fillColor: Colors.grey[50],

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        hint: const Text("Select a category"),

        items: _categories
            .map(
              (c) => DropdownMenuItem(
            value: c,
            child: Text(c),
          ),
        )
            .toList(),

        onChanged: (v) =>
            setState(() => _selectedCategory = v),
      ),
    );
  }

  // ---------------- TEXT FIELD ----------------
  Widget _buildTextField(
      String label,
      String hint,
      IconData icon, {
        TextEditingController? controller,
        int maxLines = 1,
        int? maxLength,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,

            decoration: InputDecoration(
              counterText: "",
              hintText: hint,

              prefixIcon: Icon(
                icon,
                color: primaryPurple,
              ),

              filled: true,
              fillColor: Colors.grey[50],

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- POST BUTTON ----------------
  Widget _postButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: ElevatedButton(
        onPressed: _submit,

        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
        ),

        child: const Text(
          "Post Item",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // ---------------- TOGGLE ----------------
  Widget _toggleSection() {
    return Container(
      padding: const EdgeInsets.all(4),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [
          _toggleButton(
            "Lost Item",
            Icons.shopping_bag_outlined,
            0,
          ),

          _toggleButton(
            "Found Item",
            Icons.card_giftcard,
            1,
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(
      String text,
      IconData icon,
      int index,
      ) {
    bool isSelected = _isLostOrFound == index;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _isLostOrFound = index),

        child: Container(
          padding:
          const EdgeInsets.symmetric(vertical: 12),

          decoration: BoxDecoration(
            color: isSelected
                ? primaryPurple
                : Colors.transparent,

            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : Colors.grey[600],
                size: 18,
              ),

              const SizedBox(width: 8),

              Text(
                text,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- IMAGE UI ----------------
  Widget _imagePickerArea() {
    return GestureDetector(
      onTap: _pickImage,

      child: Container(
        width: double.infinity,
        height: 220,

        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(15),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          image: selectedImage != null
              ? DecorationImage(
            image: FileImage(selectedImage!),
            fit: BoxFit.cover,
          )
              : null,
        ),

        child: selectedImage == null
            ? Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: primaryPurple,
              size: 40,
            ),

            const SizedBox(height: 10),

            const Text(
              "Tap to add photos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )
            : Align(
          alignment: Alignment.topRight,

          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedImage = null;
                base64Image = null;
              });
            },

            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(6),

              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}