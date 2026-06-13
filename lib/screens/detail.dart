import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_vs/screens/home.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {
  final DemoItem item;

  const DetailScreen({
    super.key,
    required this.item,
  });

  /// ================= EMAIL =================
  Future<void> launchEmail(BuildContext context) async {
    final email = item.userEmail;

    if (email == null || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No email available"),
        ),
      );
      return;
    }

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Lost Item Inquiry',
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open email app"),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// ================= PHONE =================
  Future<void> launchPhone(BuildContext context) async {
    final phone = item.userPhone;

    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No phone number available"),
        ),
      );
      return;
    }

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not open dialer"),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      resizeToAvoidBottomInset: false,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        elevation: 0,
        centerTitle: true,

        title: const Text(
          "Item Details",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        leading: const BackButton(
          color: Colors.black,
        ),
      ),

      /// ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// ================= IMAGE =================
            Padding(
              padding: const EdgeInsets.all(12),

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Container(
                  height: 240,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.all(10),

                  child: Image.memory(
                    base64Decode(item.image),
                    fit: BoxFit.contain,

                    errorBuilder:
                        (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,

                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            /// ================= TITLE + STATUS =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Expanded(
                    child: Text(
                      item.title,

                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(
                      color: item.status == "Lost"
                          ? Colors.red.withValues(
                        alpha: 0.1,
                      )
                          : Colors.green.withValues(
                        alpha: 0.1,
                      ),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Text(
                      item.status,

                      style: TextStyle(
                        color: item.status == "Lost"
                            ? Colors.red
                            : Colors.green,

                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            /// ================= LOCATION =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: [

                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.grey,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      item.location,

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// ================= INFO BOX =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 12),

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withValues(
                        alpha: 0.04,
                      ),

                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,

                  children: [

                    _info(
                      "Date",
                      item.time,
                    ),

                    _info(
                      "Category",
                      item.category,
                    ),

                    _info(
                      "Status",
                      item.status,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= DESCRIPTION TITLE =================
            const Padding(
              padding:
              EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                "Description",

                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// ================= DESCRIPTION =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),

              child: Text(
                item.description ?? "No description",

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// ================= CONTACT INFO =================
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16),

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius:
                  BorderRadius.circular(20),

                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.black.withValues(
                        alpha: 0.04,
                      ),

                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    const CircleAvatar(
                      radius: 25,
                      backgroundColor:
                      Colors.deepPurple,

                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,

                        children: [

                          const Text(
                            "Posted By",

                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            item.userEmail ??
                                "No Email",

                            style: const TextStyle(
                              fontWeight:
                              FontWeight.bold,

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// ================= BOTTOM BUTTONS =================
      bottomNavigationBar: SafeArea(
        child: Container(
          padding:
          const EdgeInsets.fromLTRB(
            12,
            10,
            12,
            16,
          ),

          decoration: const BoxDecoration(
            color: Colors.white,

            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),

          child: Row(
            children: [

              /// ================= CALL BUTTON =================
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    launchPhone(context);
                  },

                  icon: const Icon(Icons.call),

                  label: const Text(
                    "Call",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    backgroundColor:
                    Colors.green,

                    minimumSize:
                    const Size(
                      double.infinity,
                      52,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// ================= EMAIL BUTTON =================
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    launchEmail(context);
                  },

                  icon: const Icon(Icons.email),

                  label: const Text(
                    "Email",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  style:
                  ElevatedButton.styleFrom(
                    iconColor: Colors.white,
                    backgroundColor:
                    Colors.deepPurple,

                    minimumSize:
                    const Size(
                      double.infinity,
                      52,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= INFO ITEM =================
  Widget _info(
      String title,
      String value,
      ) {
    return Column(
      children: [

        Text(
          title,

          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,

          textAlign: TextAlign.center,

          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}