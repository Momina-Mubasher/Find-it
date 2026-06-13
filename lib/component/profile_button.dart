import 'package:flutter/material.dart';
class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color color;

  const ProfileButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 15),
              Text(
                text,
                style: TextStyle(fontSize: 16, color: color),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}