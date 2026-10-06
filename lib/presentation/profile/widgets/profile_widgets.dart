import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/profile_entity.dart';

/// The user's photo, or their initials when there is none.
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final bool isLoading;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.name = '',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = ProfileEntity.initialsOf(name);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                Colors.transparent,
                AppColors.primary,
                Colors.transparent,
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              foregroundImage: imageUrl == null ? null : NetworkImage(imageUrl!),
              onForegroundImageError: imageUrl == null ? null : (_, _) {},
              child: initials.isEmpty
                  ? const Icon(Icons.person, size: 56, color: AppColors.primary)
                  : Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ),
        ),
        if (isLoading)
          const SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
      ],
    );
  }
}

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;

  const ProfileListItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      // ListTile draws its ripple on the nearest Material; without this one
      // the coloured Container above would hide it.
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            icon,
            color: iconColor ?? AppColors.primary,
            size: 24,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.textTheme.bodySmall?.color,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        ),
      ),
    );
  }
}
