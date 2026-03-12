import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wanderer_frontend/core/constants/enums.dart';
import 'package:wanderer_frontend/core/theme/wanderer_theme.dart';
import 'package:wanderer_frontend/presentation/helpers/ui_helpers.dart';

/// Minimum allowed update interval in minutes (Android WorkManager limitation)
const int _settingsMinIntervalMinutes = 15;

/// Maximum allowed update interval in minutes
const int _settingsMaxIntervalMinutes = 9999;

/// Collapsible settings panel shown as a cog-icon bubble when collapsed.
/// Contains: Show Planned Route toggle (all users, all platforms),
/// Trip Type selector (owner + in-progress, all platforms), and
/// Automatic Updates settings (owner + in-progress + mobile only).
/// Visible when the trip has a planned route OR the current user is the owner
/// and the trip is in progress.
class TripSettingsPanel extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  /// Whether the current user owns this trip
  final bool isOwner;

  /// Whether this trip was created from a plan (has planned waypoints)
  final bool tripHasPlannedRoute;

  /// Current state of the planned-route overlay on the map
  final bool showPlannedWaypoints;

  /// Toggled when the user flips the "Show Planned Route" switch
  final VoidCallback? onTogglePlannedWaypoints;

  // --- Automatic-update settings (owner + in-progress only) ---
  final bool automaticUpdates;
  final int? updateRefresh; // in seconds
  final TripModality? tripModality;
  final bool isLoading;
  final Function(
          bool automaticUpdates, int? updateRefresh, TripModality? tripModality)?
      onSettingsChange;
  final TripStatus tripStatus;
  final String? tripId;
  final VoidCallback? onTestBackgroundUpdate;

  /// Override for tests — defaults to [kIsWeb]
  final bool? isWeb;

  const TripSettingsPanel({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.isOwner,
    required this.tripHasPlannedRoute,
    required this.showPlannedWaypoints,
    this.onTogglePlannedWaypoints,
    required this.automaticUpdates,
    this.updateRefresh,
    this.tripModality,
    required this.isLoading,
    this.onSettingsChange,
    required this.tripStatus,
    this.tripId,
    this.onTestBackgroundUpdate,
    this.isWeb,
  });

  @override
  State<TripSettingsPanel> createState() => _TripSettingsPanelState();
}

class _TripSettingsPanelState extends State<TripSettingsPanel> {
  late bool _automaticUpdates;
  late TextEditingController _intervalController;
  TripModality? _tripModality;

  /// Converts seconds to clamped minutes for display in the interval field.
  int _secondsToMinutes(int? seconds) {
    if (seconds == null) return _settingsMinIntervalMinutes;
    return (seconds / 60)
        .round()
        .clamp(_settingsMinIntervalMinutes, _settingsMaxIntervalMinutes);
  }

  @override
  void initState() {
    super.initState();
    _automaticUpdates = widget.automaticUpdates;
    _tripModality = widget.tripModality;
    _intervalController = TextEditingController(
      text: _secondsToMinutes(widget.updateRefresh).toString(),
    );
  }

  @override
  void didUpdateWidget(TripSettingsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.automaticUpdates != widget.automaticUpdates) {
      _automaticUpdates = widget.automaticUpdates;
    }
    if (oldWidget.tripModality != widget.tripModality) {
      _tripModality = widget.tripModality;
    }
    if (oldWidget.updateRefresh != widget.updateRefresh) {
      _intervalController.text =
          _secondsToMinutes(widget.updateRefresh).toString();
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  /// Returns true when there is at least one section to display.
  bool get _hasContent {
    return widget.tripHasPlannedRoute ||
        (widget.isOwner && widget.tripStatus == TripStatus.inProgress);
  }

  /// Whether the trip type can still be changed (irreversible once multi-day).
  bool get _canChangeTripType => widget.tripModality != TripModality.multiDay;

  void _validateAndClampInterval() {
    final text = _intervalController.text.trim();
    final parsed = int.tryParse(text);
    if (text.isEmpty || parsed == null || parsed < _settingsMinIntervalMinutes) {
      setState(() {
        _intervalController.text = _settingsMinIntervalMinutes.toString();
        _intervalController.selection = TextSelection.collapsed(
          offset: _intervalController.text.length,
        );
      });
      if (mounted) {
        UiHelpers.showErrorMessage(
          context,
          'Minimum interval is $_settingsMinIntervalMinutes minutes',
        );
      }
    }
  }

  void _handleSave() {
    _validateAndClampInterval();
    // After clamping, the value is guaranteed to be valid.
    final minutes = int.tryParse(_intervalController.text);
    final seconds = minutes != null ? minutes * 60 : null;
    widget.onSettingsChange?.call(_automaticUpdates, seconds, _tripModality);
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    // Evaluate once so sub-methods can use it
    final effectiveIsWeb = widget.isWeb ?? kIsWeb;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      firstCurve: Curves.easeInOut,
      secondCurve: Curves.easeInOut,
      sizeCurve: Curves.easeInOut,
      alignment: Alignment.topLeft,
      crossFadeState:
          widget.isCollapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: _buildCollapsedBubble(),
      secondChild: _buildExpandedCard(context, effectiveIsWeb),
    );
  }

  Widget _buildCollapsedBubble() {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 8),
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
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const Icon(
                  Icons.settings,
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

  Widget _buildExpandedCard(BuildContext context, bool effectiveIsWeb) {
    return Container(
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WandererTheme.glassBackground,
              borderRadius: BorderRadius.circular(WandererTheme.glassRadius),
              border: Border.all(
                color: WandererTheme.glassBorderColor,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header row
                Row(
                  children: [
                    const Icon(
                      Icons.settings,
                      size: 18,
                      color: WandererTheme.primaryOrange,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Trip Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: WandererTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.remove,
                          size: 16,
                          color: WandererTheme.textSecondary,
                        ),
                        onPressed: widget.onToggleCollapse,
                        tooltip: 'Minimize',
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Show Planned Route toggle — available to ALL users on ALL platforms
                // when the trip was created from a plan.
                if (widget.tripHasPlannedRoute &&
                    widget.onTogglePlannedWaypoints != null) ...[
                  _buildPlannedRouteToggle(),
                  if (widget.isOwner &&
                      widget.tripStatus == TripStatus.inProgress)
                    const SizedBox(height: 12),
                ],

                // Owner-only settings — only when trip is in progress
                if (widget.isOwner &&
                    widget.tripStatus == TripStatus.inProgress) ...[
                  // Trip Type selector — available on all platforms when not
                  // already multi-day (irreversible once set).
                  if (_canChangeTripType) ...[
                    _buildSectionLabel(Icons.route, 'Trip Type'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildModalityButton(
                            label: 'Simple',
                            modality: TripModality.simple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildModalityButton(
                            label: 'Multi-Day',
                            modality: TripModality.multiDay,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Automatic Updates — mobile only (WorkManager / background
                  // location is an Android concept; not applicable on web).
                  if (!effectiveIsWeb) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.update,
                          size: 16,
                          color: WandererTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Automatic Updates',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WandererTheme.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Switch(
                          value: _automaticUpdates,
                          onChanged: widget.isLoading
                              ? null
                              : (value) {
                                  setState(() {
                                    _automaticUpdates = value;
                                  });
                                },
                          activeColor: WandererTheme.primaryOrange,
                        ),
                      ],
                    ),
                    if (_automaticUpdates) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _intervalController,
                              enabled: !widget.isLoading,
                              keyboardType: TextInputType.number,
                              textCapitalization: TextCapitalization.none,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText:
                                    'Update Interval (min $_settingsMinIntervalMinutes min)',
                                hintText: 'e.g., 15',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                isDense: true,
                                suffixText: 'min',
                              ),
                              style: const TextStyle(fontSize: 13),
                              onEditingComplete: _validateAndClampInterval,
                              onTapOutside: (_) {
                                _validateAndClampInterval();
                                FocusScope.of(context).unfocus();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSaveButton(),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Location will be automatically updated at this interval when trip is active',
                        style: TextStyle(
                          fontSize: 11,
                          color: WandererTheme.textSecondary,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      _buildSaveButton(fullWidth: true),
                    ],

                    // Debug-only test button
                    if (kDebugMode && widget.onTestBackgroundUpdate != null) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.isLoading
                              ? null
                              : widget.onTestBackgroundUpdate,
                          icon: const Icon(Icons.bug_report, size: 16),
                          label: const Text(
                            '🧪 Test Background Update Now',
                            style: TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                            side: const BorderSide(color: Colors.deepOrange),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'Fires a one-off WorkManager task immediately '
                        '(same code path as periodic, no 15 min wait)',
                        style: TextStyle(
                          fontSize: 10,
                          color: WandererTheme.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ] else if (_canChangeTripType) ...[
                    // Web: show Save button for Trip Type changes only.
                    _buildSaveButton(fullWidth: true),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlannedRouteToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.purple.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.route,
            size: 16,
            color: Colors.purple.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Show Planned Route',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: WandererTheme.textSecondary,
              ),
            ),
          ),
          SizedBox(
            height: 24,
            child: Switch(
              value: widget.showPlannedWaypoints,
              onChanged: (_) => widget.onTogglePlannedWaypoints?.call(),
              activeColor: Colors.purple.shade600,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: WandererTheme.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: WandererTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildModalityButton({
    required String label,
    required TripModality modality,
  }) {
    final isSelected = _tripModality == modality;
    return OutlinedButton(
      onPressed: widget.isLoading
          ? null
          : () {
              setState(() {
                _tripModality = modality;
              });
            },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? WandererTheme.primaryOrange : null,
        foregroundColor: isSelected ? Colors.white : null,
        side: BorderSide(
          color: isSelected
              ? WandererTheme.primaryOrange
              : WandererTheme.glassBorderColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size(0, 32),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSaveButton({bool fullWidth = false}) {
    final button = ElevatedButton(
      onPressed: widget.isLoading ? null : _handleSave,
      style: ElevatedButton.styleFrom(
        backgroundColor: WandererTheme.primaryOrange,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 32),
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Save',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
    );
    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
