// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../Auth/apple_auth.dart';
// import '../../../Auth/auth_state.dart';
// import '../../../Auth/google_auth.dart';
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_text_style.dart';
// import '../provider/ask_ai_provider.dart';
// import '../widgets/typing_indicator.dart';
//
// class AskAiScreen extends StatefulWidget {
//   const AskAiScreen({super.key});
//
//   @override
//   State<AskAiScreen> createState() => _AskAiScreenState();
// }
//
// class _AskAiScreenState extends State<AskAiScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   void _sendMessage(BuildContext context) {
//     final provider = context.read<AskAiProvider>();
//     final text = _messageController.text.trim();
//     if (text.isEmpty) return;
//
//     provider.sendMessage(text);
//     _messageController.clear();
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final authState = context.watch<AuthState>();
//
//     // Check if user is signed in
//     if (!authState.isUserSignedIn) {
//       return _buildSignInRequiredScreen(context);
//     }
//
//     // User is signed in, show normal chat interface
//     final provider = context.watch<AskAiProvider>();
//     final messages = provider.messages;
//
//     // Auto-scroll to bottom when new messages arrive
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients && messages.isNotEmpty) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//
//     final screenWidth = MediaQuery.of(context).size.width;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: AppColors.backgroundLight,
//         resizeToAvoidBottomInset: false,
//         body: Column(
//           children: [
//             // Header Section
//             _buildHeaderSection(screenWidth, context),
//
//             // Chat Messages Area with keyboard padding
//             Expanded(
//               child: AnimatedPadding(
//                 duration: const Duration(milliseconds: 100),
//                 padding: EdgeInsets.only(bottom: keyboardHeight),
//                 child: messages.isEmpty
//                     ? _buildEmptyState()
//                     : ListView.builder(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     return _buildMessageBubble(messages[index]);
//                   },
//                 ),
//               ),
//             ),
//
//             // Typing Indicator
//             if (provider.isLoading)
//               Padding(
//                 padding: EdgeInsets.only(
//                   left: 16,
//                   right: 16,
//                   bottom: keyboardHeight > 0 ? 8 : 8,
//                 ),
//                 child: const Align(
//                   alignment: Alignment.centerLeft,
//                   child: TypingIndicator(),
//                 ),
//               ),
//
//             // Input Section - moves with keyboard
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 100),
//               transform: Matrix4.translationValues(0, -keyboardHeight, 0),
//               child: _buildInputSection(screenWidth, context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // NEW: Sign-in required screen
//   Widget _buildSignInRequiredScreen(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // AI Icon
//                 Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primaryGreen.withOpacity(0.2),
//                         AppColors.secondaryGreen.withOpacity(0.2),
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.psychology,
//                     size: 80,
//                     color: AppColors.primaryGreen,
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//
//                 // Title
//                 Text(
//                   'AI Assistant',
//                   style: AppTextStyles.headlineSmall.copyWith(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//
//                 // Description
//                 Text(
//                   'Sign in to unlock AI-powered plant care assistance',
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 40),
//
//                 // Features List
//                 _buildFeatureItem(
//                   icon: Icons.chat_bubble_outline,
//                   title: 'Expert Plant Advice',
//                   description: 'Get instant answers to your plant care questions',
//                 ),
//                 const SizedBox(height: 16),
//                 _buildFeatureItem(
//                   icon: Icons.local_florist,
//                   title: 'Plant Identification',
//                   description: 'Identify plants and learn about their care needs',
//                 ),
//                 const SizedBox(height: 16),
//                 _buildFeatureItem(
//                   icon: Icons.health_and_safety,
//                   title: 'Problem Diagnosis',
//                   description: 'Diagnose and solve plant health issues',
//                 ),
//                 const SizedBox(height: 40),
//
//                 // Sign-in Buttons
//                 _buildSignInButton(
//                   context: context,
//                   onPressed: () async {
//                     await signInWithGoogleUI(context);
//                   },
//                   icon: Icons.g_mobiledata,
//                   label: 'Continue with Google',
//                   backgroundColor: Colors.white,
//                   textColor: AppColors.textPrimary,
//                   borderColor: Colors.grey.shade300,
//                 ),
//                 const SizedBox(height: 12),
//                 _buildSignInButton(
//                   context: context,
//                   onPressed: () async {
//                     await AppleAuth.signInWithAppleUI(context);
//                   },
//                   icon: Icons.apple,
//                   label: 'Continue with Apple',
//                   backgroundColor: Colors.black,
//                   textColor: Colors.white,
//                 ),
//                 const SizedBox(height: 24),
//
//                 // Privacy Note
//                 Text(
//                   'Your data is secure and private',
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.textHint,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFeatureItem({
//     required IconData icon,
//     required String title,
//     required String description,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppColors.backgroundWhite,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.primaryGreen.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: AppColors.primaryGreen,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: AppTextStyles.caption.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSignInButton({
//     required BuildContext context,
//     required VoidCallback onPressed,
//     required IconData icon,
//     required String label,
//     required Color backgroundColor,
//     required Color textColor,
//     Color? borderColor,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 56,
//       child: ElevatedButton(
//         onPressed: onPressed,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: backgroundColor,
//           foregroundColor: textColor,
//           elevation: borderColor != null ? 0 : 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//             side: borderColor != null
//                 ? BorderSide(color: borderColor, width: 1)
//                 : BorderSide.none,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 24),
//             const SizedBox(width: 12),
//             Text(
//               label,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//                 color: textColor,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection(double screenWidth, BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
//         ),
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(30),
//           bottomRight: Radius.circular(30),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryGreen.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         bottom: false,
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: AppColors.textOnPrimary.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.psychology,
//                     color: AppColors.textOnPrimary,
//                     size: 28,
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Plant AI Assistant',
//                         style: AppTextStyles.headlineSmall.copyWith(
//                           color: AppColors.textOnPrimary,
//                           fontSize: 20,
//                         ),
//                       ),
//                       Text(
//                         'Ask me anything about plants!',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: AppColors.textOnPrimary.withOpacity(0.9),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.textOnPrimary.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.online_prediction,
//                     color: AppColors.accentYellow,
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             // Quick Questions Chips
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildQuickQuestionChip("How often to water?", context),
//                   _buildQuickQuestionChip("Why leaves turning yellow?", context),
//                   _buildQuickQuestionChip("Best soil for roses?", context),
//                   _buildQuickQuestionChip("Sunlight requirements?", context),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickQuestionChip(String text, BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       child: GestureDetector(
//         onTap: () {
//           _messageController.text = text;
//           _sendMessage(context);
//         },
//         child: Chip(
//           backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
//           label: Text(
//             text,
//             style: AppTextStyles.caption.copyWith(
//               color: AppColors.textPrimary,
//             ),
//           ),
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundCard,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.psychology_outlined,
//                 size: 64,
//                 color: AppColors.primaryGreen,
//               ),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'Start a Conversation',
//               style: AppTextStyles.headlineSmall.copyWith(
//                 color: AppColors.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Ask me anything about plant care,\nidentification, or problems!',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage message) {
//     final isUser = message.isUser;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser)
//             Container(
//               width: 32,
//               height: 32,
//               margin: const EdgeInsets.only(right: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryGreen,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.eco,
//                 color: AppColors.textOnPrimary,
//                 size: 18,
//               ),
//             ),
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               constraints: BoxConstraints(
//                 maxWidth: MediaQuery.of(context).size.width * 0.75,
//               ),
//               decoration: BoxDecoration(
//                 color: isUser
//                     ? AppColors.primaryGreen
//                     : AppColors.backgroundWhite,
//                 borderRadius: BorderRadius.only(
//                   topLeft: const Radius.circular(20),
//                   topRight: const Radius.circular(20),
//                   bottomLeft: Radius.circular(isUser ? 20 : 4),
//                   bottomRight: Radius.circular(isUser ? 4 : 20),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     message.text,
//                     style: isUser
//                         ? AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textOnPrimary,
//                     )
//                         : AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatTime(message.timestamp),
//                     style: AppTextStyles.caption.copyWith(
//                       color: isUser
//                           ? AppColors.textOnPrimary.withOpacity(0.7)
//                           : AppColors.textHint,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isUser)
//             Container(
//               width: 32,
//               height: 32,
//               margin: const EdgeInsets.only(left: 8),
//               decoration: BoxDecoration(
//                 color: AppColors.accentYellow,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.person,
//                 color: AppColors.textOnPrimary,
//                 size: 18,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputSection(double screenWidth, BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.backgroundWhite,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               // Text Input Field
//               Expanded(
//                 child: Container(
//                   constraints: const BoxConstraints(
//                     maxHeight: 120,
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                   decoration: BoxDecoration(
//                     color: AppColors.backgroundCard,
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       hintText: 'Type your question...',
//                       hintStyle: AppTextStyles.bodyMedium.copyWith(
//                         color: AppColors.textHint,
//                       ),
//                       border: InputBorder.none,
//                       contentPadding: EdgeInsets.zero,
//                       isDense: true,
//                     ),
//                     style: AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textPrimary,
//                     ),
//                     maxLines: null,
//                     keyboardType: TextInputType.multiline,
//                     textInputAction: TextInputAction.send,
//                     onSubmitted: (_) => _sendMessage(context),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//
//               // Send Button
//               GestureDetector(
//                 onTap: () => _sendMessage(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(14),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         AppColors.primaryGreen,
//                         AppColors.secondaryGreen,
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.send,
//                     color: AppColors.textOnPrimary,
//                     size: 20,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   String _formatTime(DateTime timestamp) {
//     return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../Auth/apple_auth.dart';
import '../../../Auth/auth_state.dart';
import '../../../Auth/google_auth.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
import '../../my_garden/services/CreditManager.dart';
import '../../my_garden/services/CreditsPurchaseScreen.dart';
import '../../my_garden/widgets/insufficient_credits_dialog.dart';
import '../provider/ask_ai_provider.dart';
import '../widgets/typing_indicator.dart';

class AskAiScreen extends StatefulWidget {
  const AskAiScreen({super.key});

  @override
  State<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends State<AskAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendMessage(BuildContext context) async {
    final provider = context.read<AskAiProvider>();
    final creditManager = context.read<CreditManager>();
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    // ✅ CHECK: Does user have enough credits?
    if (!creditManager.hasEnoughCredits(AskAiProvider.creditCostPerQuestion)) {
      _showInsufficientCreditsDialog(context);
      return;
    }

    // ✅ DEDUCT: 1 credit before sending message
    final deducted = await creditManager.deductCredits(
      AskAiProvider.creditCostPerQuestion,
      reason: 'ask_ai_question',
    );

    if (!deducted) {
      _showErrorDialog(context, 'Failed to deduct credits. Please try again.');
      return;
    }

    // Send message
    provider.sendMessage(text);
    _messageController.clear();
  }

  void _showInsufficientCreditsDialog(BuildContext context) {
    InsufficientCreditsDialog.show(context);
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthState>();
    final creditManager = context.watch<CreditManager>();

    // Check if user is signed in
    if (!authState.isUserSignedIn) {
      return _buildSignInRequiredScreen(context);
    }

    // User is signed in, show normal chat interface
    final provider = context.watch<AskAiProvider>();
    final messages = provider.messages;

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && messages.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            // Header Section with Credits Display
            _buildHeaderSection(screenWidth, context, creditManager),

            // Chat Messages Area with keyboard padding
            Expanded(
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 100),
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageBubble(messages[index]);
                  },
                ),
              ),
            ),

            // Typing Indicator
            if (provider.isLoading)
              Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: keyboardHeight > 0 ? 8 : 8,
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: TypingIndicator(),
                ),
              ),

            // Input Section - moves with keyboard
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              transform: Matrix4.translationValues(0, -keyboardHeight, 0),
              child: _buildInputSection(screenWidth, context, creditManager),
            ),
          ],
        ),
      ),
    );
  }

  // Sign-in required screen (unchanged)
  Widget _buildSignInRequiredScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.2),
                        AppColors.secondaryGreen.withOpacity(0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.psychology,
                    size: 80,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'AI Assistant',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in to unlock AI-powered plant care assistance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildFeatureItem(
                  icon: Icons.chat_bubble_outline,
                  title: 'Expert Plant Advice',
                  description: 'Get instant answers to your plant care questions',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.local_florist,
                  title: 'Plant Identification',
                  description: 'Identify plants and learn about their care needs',
                ),
                const SizedBox(height: 16),
                _buildFeatureItem(
                  icon: Icons.health_and_safety,
                  title: 'Problem Diagnosis',
                  description: 'Diagnose and solve plant health issues',
                ),
                const SizedBox(height: 40),
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    //await signInWithGoogleUI(context);
                    await GoogleAuth.signInWithGoogleUI(context);
                  },
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  textColor: AppColors.textPrimary,
                  borderColor: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                _buildSignInButton(
                  context: context,
                  onPressed: () async {
                    await AppleAuth.signInWithAppleUI(context);
                  },
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  'Your data is secure and private',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: borderColor != null ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
      double screenWidth,
      BuildContext context,
      CreditManager creditManager,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: AppColors.textOnPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plant AI Assistant',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: AppColors.textOnPrimary,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Ask me anything about plants!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textOnPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // ✅ Credits Display
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/credits_purchase'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.stars,
                          color: AppColors.accentYellow,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${creditManager.credits}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick Questions Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickQuestionChip("How often to water?", context),
                  _buildQuickQuestionChip("Why leaves turning yellow?", context),
                  _buildQuickQuestionChip("Best soil for roses?", context),
                  _buildQuickQuestionChip("Sunlight requirements?", context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickQuestionChip(String text, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _messageController.text = text;
          _sendMessage(context);
        },
        child: Chip(
          backgroundColor: AppColors.textOnPrimary.withOpacity(0.2),
          label: Text(
            text,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_outlined,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Start a Conversation',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about plant care,\nidentification, or problems!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '💡 Each question costs ${AskAiProvider.creditCostPerQuestion} credit',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.eco,
                color: AppColors.textOnPrimary,
                size: 18,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryGreen
                    : AppColors.backgroundWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: isUser
                        ? AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textOnPrimary,
                    )
                        : AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: isUser
                          ? AppColors.textOnPrimary.withOpacity(0.7)
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppColors.accentYellow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppColors.textOnPrimary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
      double screenWidth,
      BuildContext context,
      CreditManager creditManager,
      ) {
    final hasCredits = creditManager.hasEnoughCredits(AskAiProvider.creditCostPerQuestion);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            children: [
              // Credit warning if low
              if (!hasCredits)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Insufficient credits. Get more to continue.',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CreditsPurchaseScreen())),// Navigator.pushNamed(context, '/credits_purchase'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Get More'),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text Input Field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: hasCredits
                              ? 'Type your question...'
                              : 'Get credits to continue...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.send,
                        onSubmitted: hasCredits ? (_) => _sendMessage(context) : null,
                        enabled: hasCredits,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send Button
                  GestureDetector(
                    onTap: hasCredits ? () => _sendMessage(context) : null,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: hasCredits
                            ? LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.secondaryGreen,
                          ],
                        )
                            : null,
                        color: hasCredits ? null : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.send,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}