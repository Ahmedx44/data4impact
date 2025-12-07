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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: typeColor.withOpacity(0.1),
          highlightColor: typeColor.withOpacity(0.05),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: isRead ? colorScheme.surface : typeColor.withOpacity(0.08),
              boxShadow: [
                if (!isRead)
                  BoxShadow(
                    color: typeColor.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: isRead
                    ? colorScheme.outline.withOpacity(0.08)
                    : typeColor.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon with glow effect
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: typeColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: typeColor.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      typeIcon,
                      size: 22,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: isRead
                                          ? colorScheme.onSurface
                                              .withOpacity(0.8)
                                          : colorScheme.onSurface,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Type badge with gradient
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          typeColor.withOpacity(0.1),
                                          typeColor.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: typeColor.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getMiniIcon(notification.type),
                                          size: 12,
                                          color: typeColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          displayType,
                                          style: GoogleFonts.lexendDeca(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: typeColor,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Time and unread indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceVariant
                                        .withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatTime(notification.createdAt),
                                    style: GoogleFonts.lexendDeca(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!isRead)
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          typeColor,
                                          typeColor.withOpacity(0.8),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: typeColor.withOpacity(0.3),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'N',
                                        style: GoogleFonts.lexendDeca(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Notification message with subtle background
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outline.withOpacity(0.1),
                            ),
                          ),
                          child: Text(
                            notification.message,
                            style: GoogleFonts.lexendDeca(
                              fontSize: 14,
                              color: colorScheme.onSurface.withOpacity(0.8),
                              height: 1.6,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Footer with status and actions
                        Row(
                          children: [
                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : typeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isRead
                                      ? const Color(0xFF10B981).withOpacity(0.3)
                                      : typeColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isRead
                                        ? Icons.check_circle_rounded
                                        : Icons.circle_rounded,
                                    size: 12,
                                    color: isRead
                                        ? const Color(0xFF10B981)
                                        : typeColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isRead ? 'Read' : 'Unread',
                                    style: GoogleFonts.lexendDeca(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isRead
                                          ? const Color(0xFF10B981)
                                          : typeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Timestamp with calendar icon
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.surfaceVariant.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(
                                      notification.createdAt,
                                    ),
                                    style: GoogleFonts.lexendDeca(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Delete button with modern styling
                            if (showDeleteButton && onDelete != null)
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: onDelete,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          colorScheme.error.withOpacity(0.1),
                                          colorScheme.error.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            colorScheme.error.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: colorScheme.error,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Delete',
                                          style: GoogleFonts.lexendDeca(
                                            fontSize: 12,
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

  // Helper method to get mini icon for badges
  IconData _getMiniIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
      case 'warning':
        return HugeIcons.strokeRoundedEarRings01;
      case 'success':
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case 'error':
        return HugeIcons.strokeRoundedSettingsError01;
      case 'info':
        return HugeIcons.strokeRoundedInformationCircle;
      case 'invitation':
        return HugeIcons.strokeRoundedMail01;
      case 'order':
        return HugeIcons.strokeRoundedShoppingBag01;
      default:
        return HugeIcons.strokeRoundedEarRings01;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
