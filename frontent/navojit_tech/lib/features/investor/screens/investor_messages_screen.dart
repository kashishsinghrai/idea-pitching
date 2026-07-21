import 'package:flutter/material.dart';
import 'package:navojit_tech/core/theme/app_colors.dart';
import 'package:navojit_tech/core/theme/app_dimensions.dart';
import 'package:navojit_tech/core/theme/app_text_styles.dart';
import 'package:navojit_tech/features/founder/widgets/activity_tile.dart';

class InvestorMessagesScreen extends StatelessWidget {
  const InvestorMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Messages & Secure Chat', style: AppTextStyles.heading2),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidthWide),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ActivityTile(
                    avatarInitial: 'S',
                    avatarColor: AppColors.accentTeal,
                    title: 'Sarah Jenkins (NexusPay)',
                    subtitle: 'Thanks for signing the NDA. Here is the link to...',
                    timeAgo: '10m',
                    isUnread: true,
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ActivityTile(
                    avatarInitial: 'R',
                    avatarColor: AppColors.primaryBlue,
                    title: 'Dr. Rahul Mehta (MediSync)',
                    subtitle: 'We just updated our Q3 projections in the VDR.',
                    timeAgo: '2h',
                    isUnread: false,
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ActivityTile(
                    avatarInitial: 'A',
                    avatarColor: AppColors.warningAmber,
                    title: 'David Chen (Aura)',
                    subtitle: 'Yes, we are actively looking for a lead on the round.',
                    timeAgo: '1d',
                    isUnread: false,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
