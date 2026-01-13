// import 'package:flutter/material.dart';
//
// import '../../../utils/app_colors.dart';
//
// class TypingIndicator extends StatefulWidget {
//   const TypingIndicator({super.key});
//
//   @override
//   State<TypingIndicator> createState() => _TypingIndicatorState();
// }
//
// class _TypingIndicatorState extends State<TypingIndicator>
//     with TickerProviderStateMixin {
//   late final List<AnimationController> _controllers;
//   late final List<Animation<double>> _animations;
//
//   @override
//   void initState() {
//     super.initState();
//     _controllers = List.generate(
//       3,
//           (i) => AnimationController(
//         vsync: this,
//         duration: const Duration(milliseconds: 600),
//       )..repeat(reverse: true, period: const Duration(milliseconds: 900)),
//     );
//
//     _animations = _controllers
//         .map((c) => Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(parent: c, curve: Curves.easeInOut),
//     ))
//         .toList();
//
//     // Delay start for staggered bounce
//     for (var i = 0; i < _controllers.length; i++) {
//       Future.delayed(Duration(milliseconds: i * 200), () {
//         if (mounted) _controllers[i].forward();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     for (var c in _controllers) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: List.generate(3, (i) {
//         return FadeTransition(
//           opacity: _animations[i],
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 2),
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 color: AppColors.primaryGreen,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }


import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
          (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      )..repeat(reverse: true, period: const Duration(milliseconds: 900)),
    );

    _animations = _controllers
        .map((c) => Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: c, curve: Curves.easeInOut),
    ))
        .toList();

    // Delay start for staggered bounce
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Helper method for responsive sizing
  Map<String, double> _getResponsiveSize(double screenWidth) {
    if (screenWidth > 600) {
      // Tablets and larger screens
      return {'dotSize': 10.0, 'spacing': 3.0};
    } else if (screenWidth > 400) {
      // Standard phones
      return {'dotSize': 8.0, 'spacing': 2.5};
    } else if (screenWidth > 360) {
      // Smaller phones
      return {'dotSize': 7.5, 'spacing': 2.0};
    } else {
      // Very small screens
      return {'dotSize': 7.0, 'spacing': 1.8};
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final sizes = _getResponsiveSize(screenWidth);
    final dotSize = sizes['dotSize']!;
    final spacing = sizes['spacing']!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return FadeTransition(
          opacity: _animations[i],
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: spacing),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
