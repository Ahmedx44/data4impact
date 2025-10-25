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
        colorScheme
    );

    return Card(
      elevation: 3,
      shadowColor: colorScheme.primary.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surface,
              colorScheme.surfaceVariant.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header with status and invitation type
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status indicator with icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      size: 20,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Invitation type and status badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getInvitationTypeTitle(invitation.type),
                          style: GoogleFonts.lexendDeca(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: statusColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            displayStatus,
                            style: GoogleFonts.lexendDeca(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Invitation message
              Text(
                invitation.message,
                style: GoogleFonts.lexendDeca(
                  fontSize: 15,
                  color: colorScheme.onSurface.withOpacity(0.75),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 24),

              /// Roles section with visual indicators
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Assigned Roles',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        '${invitation.roles.length} ${invitation.roles.length == 1 ? 'Role' : 'Roles'}',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Roles chips container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: invitation.roles.map((role) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withOpacity(0.1),
                              colorScheme.primary.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRoleIcon(role as String),
                              size: 14,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatRoleName(role),
                              style: GoogleFonts.lexendDeca(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),

                  // Expiry timeline dots
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ExpiryDot(
                        date: invitation.createdAt,
                        label: 'Sent',
                        isActive: true,
                        colorScheme: colorScheme,
                      ),
                      _ExpiryDot(
                        date: invitation.expiredAt,
                        label: isExpired ? 'Expired' : 'Expires',
                        isActive: isExpired,
                        isWarning: true,
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// Action buttons - Conditional based on status
              if (canRespond)
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Reject button
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: colorScheme.error.withOpacity(0.6),
                              width: 1,
                            ),
                            foregroundColor: colorScheme.error,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                          ),
                          onPressed: onReject,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Decline',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Accept button
                      // Accept button
                      Expanded(
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(colorScheme.primary),
                            padding: WidgetStateProperty.all(
                              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            ),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),

                          onPressed: onAccept,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Accept',
                                style: GoogleFonts.lexendDeca(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isExpired)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.error.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Invitation Expired',
                          style: GoogleFonts.lexendDeca(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (invitation.status == 'accepted')
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: const Color(0xFF10B981),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Invitation Accepted',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (invitation.status == 'rejected')
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.error.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cancel_rounded,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Invitation Declined',
                              style: GoogleFonts.lexendDeca(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ],
          ),
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
        return (colorScheme.primary, Icons.pending_actions_rounded, 'Pending Response');
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
}

// Expiry timeline dot widget
class _ExpiryDot extends StatelessWidget {
  final DateTime date;
  final String label;
  final bool isActive;
  final bool isWarning;
  final ColorScheme colorScheme;

  const _ExpiryDot({
    required this.date,
    required this.label,
    required this.isActive,
    this.isWarning = false,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? (isActive ? colorScheme.error : colorScheme.outline.withOpacity(0.3))
        : (isActive ? colorScheme.primary : colorScheme.outline.withOpacity(0.3));

    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: color.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(date),
          style: GoogleFonts.lexendDeca(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? color : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.lexendDeca(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive ? color : colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}