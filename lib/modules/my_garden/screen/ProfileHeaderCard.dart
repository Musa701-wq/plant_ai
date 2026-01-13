import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String? profileImage; // Now accepts base64 string or null
  final String name;
  final String email;
  final String accountType;
  final VoidCallback onCameraPressed;
  final VoidCallback? onEditPressed; // New callback for edit button

  const ProfileHeaderCard({
    Key? key,
    required this.profileImage,
    required this.name,
    required this.email,
    required this.accountType,
    required this.onCameraPressed,
    this.onEditPressed,
  }) : super(key: key);

  /// Convert base64 string to Uint8List for Image.memory
  Uint8List? _getImageBytes() {
    if (profileImage == null || profileImage!.isEmpty) {
      return null;
    }

    try {
      // Remove data URI prefix if present
      String base64String = profileImage!;
      if (base64String.contains('base64,')) {
        base64String = base64String.split('base64,').last;
      }

      // Decode base64
      return base64Decode(base64String);
    } catch (e) {
      debugPrint("❌ [ProfileHeaderCard] Error decoding base64: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getImageBytes();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Edit Button at top right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onEditPressed != null)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEditPressed,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Profile Image with Camera Button
          Stack(
            children: [
              // Profile Image Circle
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: imageBytes != null
                      ? MemoryImage(imageBytes) as ImageProvider
                      : null,
                  child: imageBytes == null
                      ? Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey[600],
                  )
                      : null,
                ),
              ),
              // Camera Button
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onCameraPressed,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_outline, size: 16),
                const SizedBox(width: 8),
                Text(
                  accountType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}