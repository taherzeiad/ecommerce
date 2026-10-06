import 'package:flutter/material.dart';

class ExpandableCard extends StatelessWidget {
  final String title;
  final Widget content;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        // Lets the tile's ripple show above the card colour.
        child: Material(
          type: MaterialType.transparency,
          child: ExpansionTile(
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            iconColor: textColor,
            collapsedIconColor: textColor,
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedAlignment: AlignmentDirectional.topStart,
            children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
