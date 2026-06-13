import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  static String routeName = "/mypost";

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final Color primaryPurple = const Color(0xFF6C5CE7);
  int _selectedType = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _firestore.collection("items").doc(postId).update(data);
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection("items").doc(postId).delete();
  }

  // ---------------- EDIT SHEET ----------------
  void openEditSheet(Map<String, dynamic> item) {
    final formKey = GlobalKey<FormState>();

    TextEditingController titleController =
    TextEditingController(text: item["title"]);
    TextEditingController descController =
    TextEditingController(text: item["description"]);
    TextEditingController locController =
    TextEditingController(text: item["location"]);

    String selectedCategory = item["category"];

    List images = item["images"] ?? [];

    File? pickedImage;
    String? newBase64Image;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setModalState) =>
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery
                          .of(context)
                          .viewInsets
                          .bottom + 15,
                      left: 15,
                      right: 15,
                      top: 10,
                    ),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.80,
                      child: Form(
                        key: formKey,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// TOP BAR
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              /// IMAGE
                              _buildLabel("Image"),

                              GestureDetector(
                                onTap: () async {
                                  final picker = ImagePicker();

                                  final XFile? file =
                                  await picker.pickImage(
                                    source: ImageSource.gallery,
                                  );

                                  if (file != null) {
                                    pickedImage = File(file.path);

                                    final bytes =
                                    await pickedImage!.readAsBytes();

                                    newBase64Image =
                                        base64Encode(bytes);

                                    setModalState(() {});
                                  }
                                },
                                child: Center(
                                  child: Container(
                                    height: 130, // smaller preview
                                    width: 130,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius:
                                      BorderRadius.circular(18),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(18),
                                      child: newBase64Image != null
                                          ? Image.memory(
                                        base64Decode(
                                            newBase64Image!),
                                        fit: BoxFit.cover,
                                      )
                                          : (images.isNotEmpty
                                          ? Image.memory(
                                        base64Decode(images[0].toString()),
                                        fit: BoxFit.cover,
                                      )
                                          : const Center(
                                        child: Icon(
                                          Icons.add_a_photo,
                                          size: 35,
                                          color: Colors.grey,
                                        ),
                                      )),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              _buildLabel("Item Title"),
                              _buildField(titleController),

                              const SizedBox(height: 15),

                              _buildLabel("Description"),
                              _buildField(
                                descController,
                                maxLines: 3,
                              ),

                              const SizedBox(height: 15),

                              _buildLabel("Location"),
                              _buildField(locController),

                              const SizedBox(height: 15),

                              _buildLabel("Category"),
                              _buildDropdown(
                                selectedCategory,
                                    (v) =>
                                    setModalState(
                                          () => selectedCategory = v!,
                                    ),
                              ),

                              const SizedBox(height: 30),

                              /// BUTTONS
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          Navigator.pop(context),
                                      child: const Text("Cancel"),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: ElevatedButton(
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        primaryPurple,
                                        padding:
                                        const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                      ),
                                      onPressed: () async {
                                        List updatedImages =
                                        List.from(images);

                                        if (newBase64Image != null) {
                                          if (updatedImages
                                              .isNotEmpty) {
                                            updatedImages[0] =
                                            newBase64Image!;
                                          } else {
                                            updatedImages.add(
                                                newBase64Image!);
                                          }
                                        }

                                        await updatePost(
                                          item["postId"],
                                          {
                                            "title":
                                            titleController.text,
                                            "description":
                                            descController.text,
                                            "location":
                                            locController.text,
                                            "category":
                                            selectedCategory,
                                            "images":
                                            updatedImages,
                                          },
                                        );

                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        "Save",
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  // ---------------- UI (UNCHANGED) ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text("My Posts",
            style:
            TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildToggle(),
          Expanded(
              child:StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("items")
                    .where("userId",
                    isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .where("type", isEqualTo: _selectedType)
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: Text("No data found"));
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("No posts found"));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(15),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final item =
                      docs[index].data() as Map<String, dynamic>;

                      return _postCard(item);
                    },
                  );
                },
              )
          ),
        ],
      ),
    );
  }

  // ---------------- POST CARD (UNCHANGED) ----------------
  Widget _postCard(Map<String, dynamic> item) {
    List images = item["images"] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: images.isNotEmpty
                ? Image.memory(
              base64Decode(images[0]),
              fit: BoxFit.contain,
            )
                : Container(
              height: 220,
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 12),
          Text(item["title"] ?? "",
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          _iconText(Icons.location_on_outlined, item["location"] ?? ""),
          _iconText(Icons.grid_view_outlined, item["category"] ?? ""),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => openEditSheet(item),
                  icon: Icon(Icons.edit, color: primaryPurple),
                  label: const Text("Edit"),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => deletePost(item["postId"]),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ---------------- HELPERS (UNCHANGED) ----------------
  Widget _buildField(TextEditingController c, {int maxLines = 1}) =>
      TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildDropdown(String val, Function(String?) onChange) =>
      DropdownButtonFormField<String>(
        initialValue: val,
        items: [
          "Electronics",
          "Documents",
          "Wallets/Bags",
          "Keys",
          "Others"
        ]
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChange,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border:
          OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

  Widget _buildLabel(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(t,
          style: const TextStyle(fontWeight: FontWeight.bold)));

  Widget _iconText(IconData i, String t) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(children: [
        Icon(i, size: 14, color: primaryPurple),
        const SizedBox(width: 8),
        Text(t,
            style:
            const TextStyle(color: Colors.grey, fontSize: 12))
      ]));

  // ---------------- TOGGLE (UNCHANGED) ----------------
  Widget _buildToggle() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _toggleItem("Lost Items", Icons.shopping_bag_outlined, 0),
          _toggleItem("Found Items", Icons.card_giftcard, 1),
        ],
      ),
    );
  }

  Widget _toggleItem(String label, IconData icon, int index) {
    bool active = _selectedType == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? Colors.white : Colors.grey),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}