import 'package:data4impact/core/service/api_service/Model/invitation_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const InvitationCard({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isExpired = invitation.expiredAt.isBefore(DateTime.now());
    final canRespond = !isExpired && invitation.status == 'pending';

    // Determine status colors and icons
    final (statusColor, statusIcon, displayStatus) = _getStatusDetails(
      invitation.status,
      isExpired,
      colorScheme,
    );

    return Card(
      elevation: 2,
      shadowColor: colorScheme.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.06),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and type
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getInvitationTypeTitle(invitation.type),
                        style: GoogleFonts.lexendDeca(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        invitation.message,
                        style: GoogleFonts.lexendDeca(
                          fontSize: 13,
                          color: colorScheme.onSurface.withOpacity(0.7),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        displayStatus,
                        style: GoogleFonts.lexendDeca(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Roles and expiry info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Roles
                Flexible(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: invitation.roles.take(3).map((role) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(role as String),
                            size: 12,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatRoleName(role),
                            style: GoogleFonts.lexendDeca(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ),

                // Expiry info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? colorScheme.error.withOpacity(0.05)
                        : colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExpired
                          ? colorScheme.error.withOpacity(0.2)
                          : colorScheme.outline.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isExpired ? Icons.timer_off_rounded : Icons.timer_rounded,
                        size: 12,
                        color: isExpired ? colorScheme.error : colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpired ? 'Expired' : 'Expires',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isExpired ? colorScheme.error : colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDateCompact(invitation.expiredAt),
                        style: GoogleFonts.lexendDeca(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isExpired ? colorScheme.error : colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// Action buttons - Conditional based on status
            if (canRespond)
              Row(
                children: [
                  // Reject button
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: colorScheme.error.withOpacity(0.5),
                          width: 1,
                        ),
                        foregroundColor: colorScheme.error,
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: onReject,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.error,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Decline',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Accept button
                  Expanded(
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(colorScheme.primary),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
                      ),
                      onPressed: onAccept,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Accept',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 13,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            else if (isExpired)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 16,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Invitation Expired',
                      style: GoogleFonts.lexendDeca(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              )
            else if (invitation.status == 'accepted')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Accepted',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                )
              else if (invitation.status == 'rejected')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_rounded,
                          size: 16,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Declined',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Helper method to get status details
  (Color, IconData, String) _getStatusDetails(String status, bool isExpired, ColorScheme colorScheme) {
    if (isExpired) {
      return (colorScheme.error, Icons.timer_off_rounded, 'Expired');
    }

    switch (status.toLowerCase()) {
      case 'pending':
        return (colorScheme.primary, Icons.pending_actions_rounded, 'Pending');
      case 'accepted':
        return (const Color(0xFF10B981), Icons.check_circle_rounded, 'Accepted');
      case 'rejected':
        return (colorScheme.error, Icons.cancel_rounded, 'Declined');
      default:
        return (colorScheme.primary, Icons.email_rounded, 'Invitation');
    }
  }

  // Helper method to get invitation type title
  String _getInvitationTypeTitle(String type) {
    switch (type.toLowerCase()) {
      case 'project':
        return 'Project Invitation';
      case 'team':
        return 'Team Invitation';
      case 'organization':
        return 'Organization Invitation';
      default:
        return 'Invitation';
    }
  }

  // Helper method to get role icon
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      case 'member':
        return Icons.person_rounded;
      case 'collector':
        return Icons.collections_rounded;
      case 'editor':
        return Icons.edit_rounded;
      case 'viewer':
        return Icons.visibility_rounded;
      default:
        return Icons.workspaces_rounded;
    }
  }

  // Helper method to format role name
  String _formatRoleName(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  // Helper method to format date compact
  String _formatDateCompact(DateTime date) {
    return '${date.day}/${date.month}';
  }
}