import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wanderer_frontend/core/theme/wanderer_theme.dart';

/// Widget for sending trip updates (location + battery + optional message)
/// Displays as a floating bubble that expands to show message input
/// Only shown on Android, for trip owner, when trip is IN_PROGRESS
/// For MULTI_DAY trips, also includes "Finish Day N" / "Begin Day N+1" button
class TripUpdatePanel extends StatefulWidget {
  final bool isCollapsed;
  final bool isLoading;
  final VoidCallback onToggleCollapse;
  final Future<void> Function(String? message) onSendUpdate;

  /// Whether to show the "Finish Day / Begin Day" button (multi-day trips only)
  final bool showDayButton;

  /// Current day number for the day button label
  final int currentDay;

  /// Whether the trip is in resting state (affects day button label)
  final bool isResting;

  /// Callback when the day button is tapped.
  /// Receives the current message text (if any) so the caller can send a
  /// trip update alongside the status change.  Returns `true` when the
  /// action was completed (so the panel clears the message field).
  final Future<bool> Function(String? message)? onDayButtonTap;

  const TripUpdatePanel({
    super.key,
    required this.isCollapsed,
    required this.isLoading,
    required this.onToggleCollapse,
    required this.onSendUpdate,
    this.showDayButton = false,
    this.currentDay = 1,
    this.isResting = false,
    this.onDayButtonTap,
  });

  @override
  State<TripUpdatePanel> createState() => _TripUpdatePanelState();
}

class _TripUpdatePanelState extends State<TripUpdatePanel> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final message = _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim();
      await widget.onSendUpdate(message);
      _messageController.clear();
      // Collapse after successful send
      widget.onToggleCollapse();
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCollapsed) {
      return _buildCollapsedBubble();
    }
    return _buildExpandedPanel();
  }

  /// Collapsed state - floating bubble with send icon
  Widget _buildCollapsedBubble() {
    final icon = Icons.send_rounded;
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Material(
            color: WandererTheme.glassBackground,
            shape: CircleBorder(
              side: BorderSide(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: widget.onToggleCollapse,
              customBorder: const CircleBorder(),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: WandererTheme.primaryOrange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Expanded state - message input, send button, and optional day button
  Widget _buildExpandedPanel() {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        boxShadow: WandererTheme.floatingShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: WandererTheme.glassBlurSigma,
            sigmaY: WandererTheme.glassBlurSigma,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: WandererTheme.glassBackground,
              borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
              border: Border.all(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(WandererTheme.glassRadius),
                      topRight: Radius.circular(WandererTheme.glassRadius),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: WandererTheme.glassBorderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: WandererTheme.primaryOrange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Send Update',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: WandererTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: widget.onToggleCollapse,
                        color: WandererTheme.textSecondary,
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info text
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: WandererTheme.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Your location and battery level will be shared',
                              style: TextStyle(
                                fontSize: 12,
                                color: WandererTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Message input
                      TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Add a message (optional)',
                          hintStyle: TextStyle(
                            color: WandererTheme.textTertiary,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: WandererTheme.glassBorderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: WandererTheme.glassBorderColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: WandererTheme.primaryOrange,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        maxLines: 2,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSend(),
                      ),
                      const SizedBox(height: 12),

                      // Action buttons row: [Day Button?] [Send Update]
                      Row(
                        children: [
                          // Day button (Finish Day N / Begin Day N+1)
                          if (widget.showDayButton) ...[
                            Expanded(
                              child: _buildDayButton(),
                            ),
                            const SizedBox(width: 8),
                          ],
                          // Send update button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: (_isSending || widget.isLoading)
                                  ? null
                                  : _handleSend,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WandererTheme.primaryOrange,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.send, size: 18),
                              label: Text(
                                  _isSending ? 'Sending...' : 'Send Update'),
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
    );
  }

  /// Handle day button tap — passes current message text to the callback
  /// and clears the input field on success.
  Future<void> _handleDayButtonTap() async {
    if (widget.onDayButtonTap == null) return;

    final trimmed = _messageController.text.trim();
    final message = trimmed.isEmpty ? null : trimmed;

    final completed = await widget.onDayButtonTap!(message);
    if (completed && mounted) {
      _messageController.clear();
    }
  }

  /// Build the "Finish Day N" / "Begin Day N+1" button for multi-day trips
  Widget _buildDayButton() {
    final label = widget.isResting
        ? 'Begin Day ${widget.currentDay + 1}'
        : 'Finish Day ${widget.currentDay}';
    final icon =
        widget.isResting ? Icons.wb_sunny_outlined : Icons.nightlight_round;
    final color = widget.isResting
        ? WandererTheme.dayStartColor
        : WandererTheme.dayEndColor;

    return ElevatedButton.icon(
      onPressed: _handleDayButtonTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
