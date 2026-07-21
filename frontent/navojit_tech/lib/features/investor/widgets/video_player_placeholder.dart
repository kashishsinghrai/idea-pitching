import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';

class VideoPlayerPlaceholder extends StatelessWidget {
  const VideoPlayerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          boxShadow: AppColors.subtleShadow,
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1557804506-669a67965ba0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80'), // Placeholder pitch cover
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
          ),
        ),
        child: Center(
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(200),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceWhite.withAlpha(100), width: 2),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: AppColors.textOnDark,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
