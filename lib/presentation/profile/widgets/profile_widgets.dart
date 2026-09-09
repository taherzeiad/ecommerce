import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool showEdit;
  final VoidCallback? onEdit;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.showEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
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
            child: const CircleAvatar(
              radius: 58,
              backgroundImage: NetworkImage(
                'https://i.pravatar.cc/300?img=11', // Dummy image for Ramiz Man
              ),
            ),
          ),
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
    );
  }
}
