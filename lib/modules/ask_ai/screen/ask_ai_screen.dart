// lib/screens/ask_ai_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';
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

  void _sendMessage(BuildContext context) {
    final provider = context.read<AskAiProvider>();
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    provider.sendMessage(text);
    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        resizeToAvoidBottomInset: false, // Important: Keep this false
        body: Column(
          children: [
            // Header Section
            _buildHeaderSection(screenWidth, context),

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
              child: _buildInputSection(screenWidth, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double screenWidth, BuildContext context) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.online_prediction,
                    color: AppColors.accentYellow,
                    size: 20,
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

  Widget _buildInputSection(double screenWidth, BuildContext context) {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text Input Field
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 120,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type your question...',
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
                    onSubmitted: (_) => _sendMessage(context),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Send Button
              GestureDetector(
                onTap: () => _sendMessage(context),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.secondaryGreen,
                      ],
                    ),
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
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

//lib/screens/ask_ai_screen.dart


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
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
//   // Responsive helper methods
//   double _getResponsivePadding(double screenWidth) {
//     if (screenWidth > 600) return 24;
//     if (screenWidth > 400) return 20;
//     return 16;
//   }
//
//   double _getResponsiveFontSize(double screenWidth, double baseFontSize) {
//     if (screenWidth > 600) return baseFontSize * 1.1;
//     if (screenWidth < 360) return baseFontSize * 0.9;
//     return baseFontSize;
//   }
//
//   double _getMessageMaxWidth(double screenWidth) {
//     if (screenWidth > 600) return screenWidth * 0.6;
//     if (screenWidth > 400) return screenWidth * 0.7;
//     return screenWidth * 0.75;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<AskAiProvider>();
//     final messages = provider.messages;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 400),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//
//     return Scaffold(
//       backgroundColor: AppColors.backgroundLight,
//       resizeToAvoidBottomInset: false, // Important: Don't auto-resize
//       body: SizedBox(
//         height: MediaQuery.of(context).size.height,
//         child: Column(
//           children: [
//             // Header Section
//             _buildHeaderSection(screenWidth, context),
//
//             // Chat Messages Area - Expanded to fill space
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: _getResponsivePadding(screenWidth),
//                   vertical: 8,
//                 ),
//                 child: messages.isEmpty
//                     ? _buildEmptyState(screenWidth)
//                     : ListView.builder(
//                   controller: _scrollController,
//                   reverse: false,
//                   physics: const BouncingScrollPhysics(),
//                   itemCount: messages.length,
//                   itemBuilder: (context, index) {
//                     return _buildMessageBubble(
//                       messages[index],
//                       screenWidth,
//                     );
//                   },
//                 ),
//               ),
//             ),
//
//             if (provider.isLoading)
//               Padding(
//                 padding: EdgeInsets.all(_getResponsivePadding(screenWidth) * 0.5),
//                 child: const TypingIndicator(),
//               ),
//
//             // Input Section with keyboard aware padding
//             Padding(
//               padding: EdgeInsets.only(bottom: keyboardHeight),
//               child: _buildInputSection(screenWidth, context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderSection(double screenWidth, BuildContext context) {
//     final horizontalPadding = _getResponsivePadding(screenWidth);
//     final verticalPadding = screenWidth > 600 ? 24.0 : 20.0;
//     final iconSize = screenWidth > 600 ? 32.0 : 28.0;
//     final titleSize = _getResponsiveFontSize(screenWidth, 20);
//
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         horizontal: horizontalPadding,
//         vertical: verticalPadding,
//       ),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [AppColors.primaryGreen, AppColors.secondaryGreen],
//         ),
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(screenWidth > 600 ? 40 : 30),
//           bottomRight: Radius.circular(screenWidth > 600 ? 40 : 30),
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
//                   padding: EdgeInsets.all(screenWidth > 600 ? 14 : 12),
//                   decoration: BoxDecoration(
//                     color: AppColors.textOnPrimary.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.psychology,
//                     color: AppColors.textOnPrimary,
//                     size: iconSize,
//                   ),
//                 ),
//                 SizedBox(width: screenWidth > 600 ? 16 : 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Plant AI Assistant',
//                         style: AppTextStyles.headlineSmall.copyWith(
//                           color: AppColors.textOnPrimary,
//                           fontSize: titleSize,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         'Ask me anything about plants!',
//                         style: AppTextStyles.bodySmall.copyWith(
//                           color: AppColors.textOnPrimary.withOpacity(0.9),
//                           fontSize: _getResponsiveFontSize(screenWidth, 14),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(screenWidth > 600 ? 10 : 8),
//                   decoration: BoxDecoration(
//                     color: AppColors.textOnPrimary.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.online_prediction,
//                     color: AppColors.accentYellow,
//                     size: screenWidth > 600 ? 24 : 20,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: screenWidth > 600 ? 20 : 16),
//             // Quick Questions Chips
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildQuickQuestionChip(
//                     "How often to water?",
//                     context,
//                     screenWidth,
//                   ),
//                   _buildQuickQuestionChip(
//                     "Why leaves turning yellow?",
//                     context,
//                     screenWidth,
//                   ),
//                   _buildQuickQuestionChip(
//                     "Best soil for roses?",
//                     context,
//                     screenWidth,
//                   ),
//                   _buildQuickQuestionChip(
//                     "Sunlight requirements?",
//                     context,
//                     screenWidth,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickQuestionChip(
//       String text,
//       BuildContext context,
//       double screenWidth,
//       ) {
//     return Container(
//       margin: EdgeInsets.only(right: screenWidth > 600 ? 12 : 8),
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
//               fontSize: _getResponsiveFontSize(screenWidth, 12),
//             ),
//           ),
//           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           padding: EdgeInsets.symmetric(
//             horizontal: screenWidth > 600 ? 12 : 8,
//             vertical: screenWidth > 600 ? 8 : 4,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState(double screenWidth) {
//     final iconSize = screenWidth > 600 ? 80.0 : 64.0;
//     final spacing = screenWidth > 600 ? 24.0 : 20.0;
//
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: _getResponsivePadding(screenWidth)),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.all(screenWidth > 600 ? 32 : 24),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundCard,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.psychology_outlined,
//                 size: iconSize,
//                 color: AppColors.primaryGreen,
//               ),
//             ),
//             SizedBox(height: spacing),
//             Text(
//               'Start a Conversation',
//               style: AppTextStyles.headlineSmall.copyWith(
//                 color: AppColors.textPrimary,
//                 fontSize: _getResponsiveFontSize(screenWidth, 20),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Ask me anything about plant care,\nidentification, or problems!',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//                 fontSize: _getResponsiveFontSize(screenWidth, 14),
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMessageBubble(ChatMessage message, double screenWidth) {
//     final isUser = message.isUser;
//     final avatarSize = screenWidth > 600 ? 40.0 : 32.0;
//     final iconSize = screenWidth > 600 ? 22.0 : 18.0;
//     final padding = screenWidth > 600 ? 18.0 : 16.0;
//     final borderRadius = screenWidth > 600 ? 24.0 : 20.0;
//
//     return Container(
//       margin: EdgeInsets.symmetric(
//         vertical: screenWidth > 600 ? 10 : 8,
//       ),
//       child: Row(
//         mainAxisAlignment:
//         isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           if (!isUser)
//             Container(
//               width: avatarSize,
//               height: avatarSize,
//               margin: EdgeInsets.only(right: screenWidth > 600 ? 12 : 8),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryGreen,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.eco,
//                 color: AppColors.textOnPrimary,
//                 size: iconSize,
//               ),
//             ),
//           Flexible(
//             child: Container(
//               padding: EdgeInsets.all(padding),
//               constraints: BoxConstraints(
//                 maxWidth: _getMessageMaxWidth(screenWidth),
//               ),
//               decoration: BoxDecoration(
//                 color: isUser
//                     ? AppColors.primaryGreen
//                     : AppColors.backgroundWhite,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(borderRadius),
//                   topRight: Radius.circular(borderRadius),
//                   bottomLeft: Radius.circular(isUser ? borderRadius : 4),
//                   bottomRight: Radius.circular(isUser ? 4 : borderRadius),
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
//                       fontSize: _getResponsiveFontSize(screenWidth, 14),
//                     )
//                         : AppTextStyles.bodyMedium.copyWith(
//                       color: AppColors.textPrimary,
//                       fontSize: _getResponsiveFontSize(screenWidth, 14),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatTime(message.timestamp),
//                     style: AppTextStyles.caption.copyWith(
//                       color: isUser
//                           ? AppColors.textOnPrimary.withOpacity(0.7)
//                           : AppColors.textHint,
//                       fontSize: _getResponsiveFontSize(screenWidth, 11),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (isUser)
//             Container(
//               width: avatarSize,
//               height: avatarSize,
//               margin: EdgeInsets.only(left: screenWidth > 600 ? 12 : 8),
//               decoration: BoxDecoration(
//                 color: AppColors.accentYellow,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.person,
//                 color: AppColors.textOnPrimary,
//                 size: iconSize,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInputSection(double screenWidth, BuildContext context) {
//     final horizontalPadding = _getResponsivePadding(screenWidth);
//     final buttonSize = screenWidth > 600 ? 52.0 : 48.0;
//     final iconSize = screenWidth > 600 ? 24.0 : 20.0;
//
//     return Container(
//       padding: EdgeInsets.fromLTRB(
//         horizontalPadding,
//         12,
//         horizontalPadding,
//         16, // Fixed bottom padding
//       ),
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
//       child: Row(
//         children: [
//           // Text Input Field
//           Expanded(
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: screenWidth > 600 ? 20 : 16,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.backgroundCard,
//                 borderRadius: BorderRadius.circular(screenWidth > 600 ? 30 : 25),
//               ),
//               child: TextField(
//                 controller: _messageController,
//                 decoration: InputDecoration(
//                   hintText: 'Type your question...',
//                   hintStyle: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textHint,
//                     fontSize: _getResponsiveFontSize(screenWidth, 14),
//                   ),
//                   border: InputBorder.none,
//                   contentPadding: EdgeInsets.symmetric(
//                     vertical: screenWidth > 600 ? 14 : 12,
//                   ),
//                 ),
//                 style: AppTextStyles.bodyMedium.copyWith(
//                   color: AppColors.textPrimary,
//                   fontSize: _getResponsiveFontSize(screenWidth, 14),
//                 ),
//                 maxLines: null,
//                 textInputAction: TextInputAction.send,
//                 onSubmitted: (_) => _sendMessage(context),
//               ),
//             ),
//           ),
//           SizedBox(width: screenWidth > 600 ? 16 : 12),
//
//           // Send Button
//           GestureDetector(
//             onTap: () => _sendMessage(context),
//             child: Container(
//               width: buttonSize,
//               height: buttonSize,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primaryGreen,
//                     AppColors.secondaryGreen,
//                   ],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.send,
//                 color: AppColors.textOnPrimary,
//                 size: iconSize,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(DateTime timestamp) {
//     return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
//   }
// }
