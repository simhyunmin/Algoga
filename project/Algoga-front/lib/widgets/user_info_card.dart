import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  final String name;
  final String birth;
  final String disease;
  final String travelLocation;
  const UserInfoCard({
    super.key,
    required this.name,
    required this.birth,
    required this.disease,
    required this.travelLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, color: Colors.blue, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.isNotEmpty ? name : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    disease.isNotEmpty ? disease : 'No disease information',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Travel Location: ${travelLocation.isNotEmpty ? travelLocation : '-'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    'Birth Date: ${birth.isNotEmpty ? birth : '-'}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
