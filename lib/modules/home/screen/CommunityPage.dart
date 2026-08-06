import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text(
          'Plant Community',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -0.8,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
            ),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: StreamBuilder<QuerySnapshot> (
        stream: FirebaseFirestore.instance
            .collection('community_images')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingGrid();
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildSocialPostItem(context, data, doc.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.green[50]!,
          highlightColor: Colors.white,
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_mosaic_outlined, size: 100, color: Colors.green.withValues(alpha: 0.3)),
          ),
          const SizedBox(height: 24),
          const Text(
            'The feed is fresh...',
            style: TextStyle(fontSize: 24, color: Color(0xFF1B5E20), fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            'Share your first plant photo!',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialPostItem(BuildContext context, Map<String, dynamic> data, String docId) {
    final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
    final dateStr = timestamp != null ? DateFormat('MMMM dd, yyyy').format(timestamp) : 'Just now';
    final imageUrl = data['imageUrl'] ?? '';
    final isPest = data['type'] == 'pest';
    final itemName = data['itemName'] ?? 'My Plant';
    final userName = data['userName'] ?? 'Plant Explorer';
    
    // Social Likes Logic
    final List<dynamic> likes = data['likes'] ?? [];
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool isLiked = likes.contains(currentUserId);
    final int likeCount = likes.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER: User Info ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isPest 
                        ? [Colors.orange, Colors.red] 
                        : [const Color(0xFF00E676), const Color(0xFF1B5E20)],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green[50],
                      child: Icon(
                        isPest ? Icons.bug_report : Icons.person, 
                        size: 20, 
                        color: const Color(0xFF1B5E20)
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: Colors.black,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      isPest ? 'Spotted a Problem' : 'Gardening Update',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // --- DESCRIPTION (Above Image - Facebook Style) ---
          if ((data['description'] ?? '').toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: ExpandableText(text: data['description']),
            ),

          // --- MAIN IMAGE ---
          GestureDetector(
            onLongPress: () => _showFullScreenImage(context, imageUrl, itemName),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 300, maxHeight: 500),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[100]),
                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                  ),
                  // Floating Classification Badge
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isPest ? Icons.warning_amber_rounded : Icons.spa_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPest ? 'PEST ALERT' : 'HEALTHY PLANT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- ACTION BAR: Simplified to Like only ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded, 
                    size: 30,
                    color: isLiked ? Colors.red : Colors.black,
                  ),
                  onPressed: () => _toggleLike(docId, currentUserId, isLiked),
                ),
                if (likeCount > 0) ...[
                  const SizedBox(width: 2),
                  Text(
                    '$likeCount ${likeCount == 1 ? 'like' : 'likes'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
                const Spacer(),
                const Text(
                  'Community Favorite  ',
                  style: TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.bold, 
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Icon(Icons.stars, size: 16, color: Colors.amber),
              ],
            ),
          ),

          // --- CAPTION & INFO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14.5),
                    children: [
                      TextSpan(
                        text: '$userName ',
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                      ),
                      TextSpan(
                        text: itemName,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateStr.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      ),
    );
  }
  void _toggleLike(String docId, String userId, bool isCurrentlyLiked) async {
    if (docId.isEmpty || userId.isEmpty) return;

    final docRef = FirebaseFirestore.instance.collection('community_images').doc(docId);
    
    try {
      if (isCurrentlyLiked) {
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    } catch (e) {
      debugPrint("❌ [Like Error]: $e");
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl, String title) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.95),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: ScaleTransition(scale: anim1, child: child));
      },
      pageBuilder: (context, anim1, anim2) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            fit: StackFit.expand,
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: Color(0xFF00E676))),
                ),
              ),
              Positioned(
                top: 50,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2), 
                      shape: BoxShape.circle
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                  ),
                ),
              ),
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 20, 
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({Key? key, required this.text}) : super(key: key);

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Simple truncation logic for "See More"
    final bool longText = widget.text.length > 150;
    final String displayText = (longText && !isExpanded) 
        ? '${widget.text.substring(0, 140)}...' 
        : widget.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: TextStyle(
            color: Colors.grey[850],
            fontSize: 13.5,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
        ),
        if (longText)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                isExpanded ? 'Show Less' : 'See More',
                style: const TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
