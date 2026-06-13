import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'detail.dart';
import 'dart:convert';


/// ================== CONSTANTS ==================
const Color kPrimaryColor = Colors.deepPurple;
const Color kSecondaryColor = Color(0xFFF8F9FB);
const Color kLightPurple = Color(0xFFA29BFE);
const Color kDarkText = Color(0xFF2D3436);
const Color kGreyText = Color(0xFF7F8C8D);
const Color kCardColor = Color(0xFFFFFFFF);

/// ================== MODEL ==================
class DemoItem {
  final String id;
  final String image;
  final String title;
  final String location;
  final String time;
  final String status;
  final int peopleLooking;
  final String category;

  final String description; // ✅ ADD THIS
  final String userPhone;
  final String userEmail;

  DemoItem({
    required this.id,
    required this.image,
    required this.title,
    required this.location,
    required this.time,
    required this.status,
    required this.peopleLooking,
    required this.category,
    required this.description, // ✅ ADD THIS
    required this.userEmail,
    required this.userPhone,
  });

  factory DemoItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    return DemoItem(
      id: doc.id,
      image: (data['images'] != null && data['images'].isNotEmpty)
          ? data['images'][0]
          : '',

      title: data['title'] ?? '',
      location: data['location'] ?? '',
      category: data['category'] ?? 'Others',
      time: data['date']?.toString() ?? 'No Date',

      status: data['type'] == 0 ? "Lost" : "Found",

      peopleLooking: 0,

      description: data['description'] ?? '', // ✅ FIX HERE
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'] ?? '',
    );
  }
}

/// ================== HOME SCREEN ==================
class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSecondaryColor,
      body: const HomeBody(),
    );
  }
}

/// ================== BODY ==================
class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {

  final TextEditingController _searchController =
  TextEditingController();

  String selectedFilter = "All";
  String selectedCategory = "All";
  List<String> selectedSearchFilters = [];

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            const HomeHeader(),

            const SizedBox(height: 15),

            /// ================= SEARCH =================
            SearchBar(
              controller: _searchController,

              onChanged: (value) {
                setState(() {});
              },

              onFiltersApplied: (filters) {

                setState(() {

                  selectedSearchFilters = filters;

                });
              },
            ),

            const SizedBox(height: 15),

            /// ================= CATEGORY FILTER =================
            CategoryRow(
              selected: selectedCategory,
              onSelected: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// ================= LOST / FOUND FILTER =================
            SectionTitle(
              title: 'Latest Updates',
              selected: selectedFilter,
              onSelected: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

            const SizedBox(height: 10),

            /// ================= FIREBASE DATA =================
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('items')
                    .orderBy("createdAt", descending: true)
                    .snapshots(),

                builder: (context, snapshot) {

                  /// LOADING
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  /// NO DATA
                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  /// ================= CONVERT TO MODEL =================
                  List<DemoItem> allItems =
                  snapshot.data!.docs
                      .map((doc) => DemoItem.fromFirestore(doc))
                      .toList();

                  /// ================= FILTERING =================
                  List<DemoItem> items =
                  allItems.where((item) {

                    /// SEARCH
                    bool matchesSearch =
                        item.title.toLowerCase().contains(
                          _searchController.text
                              .toLowerCase(),
                        ) ||
                            item.location
                                .toLowerCase()
                                .contains(
                              _searchController.text
                                  .toLowerCase(),
                            );

                    /// CATEGORY
                    bool matchesCategory =
                    selectedCategory == "All"
                        ? true
                        : item.category ==
                        selectedCategory;

                    /// STATUS
                    bool matchesStatus =
                    selectedFilter == "All"
                        ? true
                        : item.status ==
                        selectedFilter;

                    /// MULTI FILTER
                    bool matchesMultiFilter =
                    selectedSearchFilters.isEmpty
                        ? true
                        : selectedSearchFilters.contains(item.category);

                    return matchesSearch &&
                        matchesCategory &&
                        matchesStatus &&
                        matchesMultiFilter;

                  }).toList();

                  /// NO FILTER RESULT
                  if (items.isEmpty) {
                    return const Center(
                      child: Text(
                        "No matching items found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  /// ================= LIST =================
                  return ListView.builder(
                    itemCount: items.length,

                    itemBuilder: (context, index) {

                      DemoItem item = items[index];

                      return ItemCard(
                        item: item,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================== HEADER ==================
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  Future<String> getUserName() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return "User";
    }

    try {

      DocumentSnapshot doc =
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {

        Map<String, dynamic> data =
        doc.data() as Map<String, dynamic>;

        return data["fullName"] ?? "User";
      }

      return "User";
    }

    catch (e) {
      return "User";
    }
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<String>(
      future: getUserName(),

      builder: (context, snapshot) {

        String userName = "User";

        if (snapshot.hasData) {
          userName = snapshot.data!;
        }

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            /// TOP ROW
            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                /// LOGO
                Expanded(
                  flex: 1,

                  child: Align(
                    alignment:
                    Alignment.centerLeft,

                    child: SvgPicture.asset(
                      "assets/images/logo.svg",
                      height: 60,
                    ),
                  ),
                ),

                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,

                  child: Icon(
                    Icons.notifications_none,
                    color: kDarkText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            /// GREETING
            Text(
              "Hello, $userName 👋",

              style: const TextStyle(
                fontSize: 14,
                color: kGreyText,
              ),
            ),

            const SizedBox(height: 5),

            /// TITLE
            Row(
              children: const [

                Text(
                  "Find what ",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                    color: kDarkText,
                  ),
                ),

                Text(
                  "matters",

                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                    FontWeight.bold,
                    fontStyle:
                    FontStyle.italic,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// ================== SEARCH ==================
/// ================== SEARCH ==================
class SearchBar extends StatefulWidget {

  final TextEditingController controller;
  final Function(String) onChanged;

  /// 🔥 RETURN SELECTED FILTERS
  final Function(List<String>)? onFiltersApplied;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onFiltersApplied,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  /// MULTI SELECT FILTERS
  List<String> selectedFilters = [];

  /// ALL FILTER ITEMS
  final List<Map<String, dynamic>> filterItems = [

    {
      "icon": Icons.wallet,
      "text": "Wallets",
    },

    {
      "icon": Icons.backpack,
      "text": "Bags",
    },

    {
      "icon": Icons.key,
      "text": "Keys",
    },

    {
      "icon": Icons.phone_android,
      "text": "Phones",
    },

    {
      "icon": Icons.watch,
      "text": "Watches",
    },

    {
      "icon": Icons.credit_card,
      "text": "Cards",
    },

    {
      "icon": Icons.laptop,
      "text": "Laptop",
    },

    {
      "icon": Icons.headphones,
      "text": "Accessories",
    },
  ];

  /// ================= FILTER SHEET =================
  void showFilterSheet(BuildContext context) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      backgroundColor: Colors.white,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {

        return StatefulBuilder(
          builder: (context, setModalState) {

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,

                  /// 🔥 IMPORTANT FIX FOR MOBILE NAVIGATION
                  bottom: MediaQuery.of(context).padding.bottom + 25,
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [

                    /// TITLE
                    const Center(
                      child: Text(
                        "Select Filters",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    /// FILTER CHIPS
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,

                      children:
                      filterItems.map((item) {

                        bool isSelected =
                        selectedFilters.contains(
                          item["text"],
                        );

                        return GestureDetector(
                          onTap: () {

                            setModalState(() {

                              if (isSelected) {

                                selectedFilters.remove(
                                  item["text"],
                                );

                              } else {

                                selectedFilters.add(
                                  item["text"],
                                );
                              }
                            });

                            setState(() {});
                          },

                          child: Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),

                            decoration: BoxDecoration(

                              color: isSelected
                                  ? kPrimaryColor
                                  : kPrimaryColor.withValues(
                                alpha: 0.08,
                              ),

                              borderRadius:
                              BorderRadius.circular(15),

                              border: Border.all(
                                color: isSelected
                                    ? kPrimaryColor
                                    : kPrimaryColor.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),

                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,

                              children: [

                                Icon(
                                  item["icon"],

                                  color: isSelected
                                      ? Colors.white
                                      : kPrimaryColor,

                                  size: 18,
                                ),

                                const SizedBox(width: 8),

                                Text(
                                  item["text"],

                                  style: TextStyle(
                                    fontWeight:
                                    FontWeight.w600,

                                    color: isSelected
                                        ? Colors.white
                                        : kPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    /// APPLY BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        onPressed: () {

                          /// SEND FILTERS BACK
                          if (widget.onFiltersApplied != null) {
                            widget.onFiltersApplied!(
                              selectedFilters,
                            );
                          }

                          Navigator.pop(context);
                        },

                        icon: const Icon(Icons.check),

                        label: const Text(
                          "Apply Filters",

                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          kPrimaryColor,

                          foregroundColor:
                          Colors.white,

                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Row(
      children: [

        /// SEARCH FIELD
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(30),

              boxShadow: [
                BoxShadow(
                  color:
                  kPrimaryColor.withValues(alpha: 0.1),

                  blurRadius: 10,

                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,

              decoration: InputDecoration(
                hintText:
                "Search for lost or found items...",

                hintStyle:
                const TextStyle(color: kGreyText),

                prefixIcon: const Icon(
                  Icons.search,
                  color: kPrimaryColor,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(30),

                  borderSide: BorderSide.none,
                ),

                contentPadding:
                const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        /// FILTER BUTTON
        GestureDetector(
          onTap: () {
            showFilterSheet(context);
          },

          child: Container(
            height: 50,
            width: 50,

            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  kPrimaryColor,
                  kLightPurple,
                ],
              ),

              borderRadius:
              BorderRadius.circular(15),
            ),

            child: const Icon(
              Icons.tune,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
/// ================== CATEGORY ==================
class CategoryRow extends StatelessWidget {
  final String selected;
  final Function(String) onSelected;

  const CategoryRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [

        _item("All", Icons.grid_view),
        _item("Bags", Icons.backpack),
        _item("Wallets", Icons.wallet),
        _item("Keys", Icons.vpn_key_outlined),
        _item("Others", Icons.more_horiz),
      ],
    );
  }

  Widget _item(String label, IconData icon) {
    bool isActive = selected == label;

    return GestureDetector(
      onTap: () => onSelected(label),

      child: Column(
        children: [
          CircleAvatar(
            backgroundColor:
            isActive ? Colors.deepPurple : Colors.grey.shade300,
            child: Icon(icon,
                color: isActive ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.deepPurple : Colors.grey,
              fontWeight:
              isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryItem({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: kLightPurple,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 5),

        Text(label),
      ],
    );
  }
}

/// ================== SECTION TITLE ==================
class SectionTitle extends StatelessWidget {
  final String title;
  final String selected;
  final Function(String) onSelected;

  const SectionTitle({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 10),

      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,

        children: [

          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          Row(
            children: [

              _chip("All"),

              const SizedBox(width: 6),

              _chip("Lost"),

              const SizedBox(width: 6),

              _chip("Found"),
            ],
          )
        ],
      ),
    );
  }

  Widget _chip(String text) {
    bool active = selected == text;

    return GestureDetector(
      onTap: () => onSelected(text),

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),

        decoration: BoxDecoration(
          color:
          active ? kPrimaryColor : Colors.white,

          borderRadius:
          BorderRadius.circular(20),

          border: Border.all(
            color: active
                ? kPrimaryColor
                : Colors.grey.shade300,
          ),
        ),

        child: Text(
          text,
          style: TextStyle(
            color:
            active ? Colors.white : kGreyText,

            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
/// ================== ITEM CARD ==================
class ItemCard extends StatelessWidget {
  final DemoItem item;

  const ItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.symmetric(vertical: 10),

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.06),

            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              base64Decode(item.image),
              width: 90,
              height: 110,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 110,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          /// TEXT AREA
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                /// STATUS CHIP
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: item.status == "Lost"
                        ? Colors.red.withValues(alpha: 0.1)
                        : Colors.green
                        .withValues(alpha: 0.1),

                    borderRadius:
                    BorderRadius.circular(20),
                  ),

                  child: Text(
                    item.status,

                    style: TextStyle(
                      color:
                      item.status == "Lost"
                          ? Colors.red
                          : Colors.green,

                      fontWeight:
                      FontWeight.bold,

                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                /// TITLE
                Text(
                  item.title,

                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                /// LOCATION
                Row(
                  children: [

                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 4),

                    Expanded(
                      child: Text(
                        item.location,

                        overflow:
                        TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                /// TIME
                Row(
                  children: [

                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      item.time,

                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// PEOPLE + BUTTON
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    /// PEOPLE
                    Row(
                      children: [

                        const Icon(
                          Icons.remove_red_eye,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          "${item.peopleLooking} people",

                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    /// BUTTON
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                DetailScreen(
                                  item: item,
                                ),
                          ),
                        );
                      },

                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration: BoxDecoration(
                          gradient:
                          const LinearGradient(
                            colors: [
                              Colors.deepPurple,
                              Color(0xFFA29BFE),
                            ],
                          ),

                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: const Row(
                          children: [

                            Text(
                              "View",

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),

                            SizedBox(width: 4),

                            Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================== DETAIL SCREEN ==================
class Detailscreen extends StatelessWidget {
  final DemoItem item;

  const Detailscreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text(item.title)),

      body: Column(
        children: [

          Image.memory(base64Decode(item.image)),

          const SizedBox(height: 10),

          Text(
            item.title,
            style:
            const TextStyle(fontSize: 20),
          ),

          Text(item.location),

          Text(item.time),

          Text(item.status),
        ],
      ),
    );
  }
}