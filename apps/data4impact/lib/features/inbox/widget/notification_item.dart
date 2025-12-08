import 'package:data4impact/core/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const NotificationItem({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRead = notification.status.toLowerCase() == 'read';

    // Get styling details based on notification type
    final (typeColor, typeIcon, displayType) = _getTypeDetails(
      notification.type,
      colorScheme,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isRead ? colorScheme.surface : typeColor.withOpacity(0.06),
              border: Border.all(
                color: isRead
                    ? colorScheme.outline.withOpacity(0.06)
                    : typeColor.withOpacity(0.12),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: typeColor.withOpacity(0.12),
                    ),
                    child: Icon(
                      typeIcon,
                      size: 18,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with title, type, and time
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: GoogleFonts.lexendDeca(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          displayType,
                                          style: GoogleFonts.lexendDeca(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: typeColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: typeColor,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatTime(notification.createdAt),
                                  style: GoogleFonts.lexendDeca(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MM/dd').format(notification.createdAt),
                                  style: GoogleFonts.lexendDeca(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Notification message
                        Text(
                          notification.message,
                          style: GoogleFonts.lexendDeca(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Footer with delete button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Status text
                            Text(
                              isRead ? 'Read' : 'Unread',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isRead
                                    ? const Color(0xFF10B981)
                                    : typeColor,
                              ),
                            ),

                            // Delete button
                            if (showDeleteButton && onDelete != null)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onDelete,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 14,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Delete',
                                          style: GoogleFonts.lexendDeca(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to get type details (color, icon, display name)
  (Color, IconData, String) _getTypeDetails(
      String type, ColorScheme colorScheme) {
    switch (type.toLowerCase()) {
      case 'alert':
      case 'warning':
        return (Colors.orange, HugeIcons.strokeRoundedEarRings01, 'Alert');
      case 'success':
      case 'completed':
        return (
        const Color(0xFF10B981),
        HugeIcons.strokeRoundedCheckmarkCircle01,
        'Success'
        );
      case 'error':
        return (
        const Color(0xFFEF4444),
        HugeIcons.strokeRoundedSettingsError01,
        'Error'
        );
      case 'info':
      case 'information':
        return (
        const Color(0xFF3B82F6),
        HugeIcons.strokeRoundedInformationCircle,
        'Info'
        );
      case 'invitation':
        return (
        const Color(0xFF8B5CF6),
        HugeIcons.strokeRoundedMail01,
        'Invitation'
        );
      case 'order':
      case 'payment':
        return (
        const Color(0xFFF59E0B),
        HugeIcons.strokeRoundedShoppingBag01,
        'Order'
        );
      case 'system':
        return (colorScheme.primary, HugeIcons.strokeRoundedRssError, 'System');
      default:
        return (
        colorScheme.primary,
        HugeIcons.strokeRoundedEarRings01,
        'Notification'
        );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 7).floor()}w';
    }
  }
}