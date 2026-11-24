import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReelsFullScreenSkeleton extends StatelessWidget {
  const ReelsFullScreenSkeleton({super.key});

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _line(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade500,
      // direction: ShimmerDirection.ttb,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(color: Colors.black87),

          // LIKE + SHARE (same position as actual ReelPlayer)
          Positioned(
            right: 18,
            bottom: 140,
            child: Column(
              children: [
                // Like icon
                _circle(40),

                const SizedBox(height: 6),

                // Like count
                _line(30, 10),

                const SizedBox(height: 20),

                // Share icon
                _circle(34),
              ],
            ),
          ),

          // MUTE ICON (same position as actual ReelPlayer)
          Positioned(
            right: 18,
            bottom: 290,
            child: _circle(40),
          ),

          // USER INFO + CAPTION + TIME
          Positioned(
            left: 16,
            right: 80,
            bottom: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile + username
                Row(
                  children: [
                    _circle(60),

                    const SizedBox(width: 10),

                    _line(120, 12),
                  ],
                ),

                const SizedBox(height: 15),

                // Caption line 1
                _line(double.infinity, 10),

                const SizedBox(height: 8),

                // Caption line 2
                _line(180, 10),

                const SizedBox(height: 10),

                // Time ago
                _line(70, 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}