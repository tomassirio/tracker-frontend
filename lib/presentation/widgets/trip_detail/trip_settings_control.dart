import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:tracker_frontend/core/theme/wanderer_theme.dart';

/// Widget for controlling trip automatic update settings
/// Only shown on mobile (not web) and only for trip owners
class TripSettingsControl extends StatefulWidget {
  final bool automaticUpdates;
  final int? updateRefresh; // in seconds
  final bool isOwner;
  final bool isLoading;
  final Function(bool automaticUpdates, int? updateRefresh) onSettingsChange;

  /// Whether running on web platform. Defaults to [kIsWeb].
  /// Can be overridden for testing purposes.
  final bool? isWeb;

  const TripSettingsControl({
    super.key,
    required this.automaticUpdates,
    this.updateRefresh,
    required this.isOwner,
    required this.isLoading,
    required this.onSettingsChange,
    this.isWeb,
  });

  @override
  State<TripSettingsControl> createState() => _TripSettingsControlState();
}

class _TripSettingsControlState extends State<TripSettingsControl> {
  late bool _automaticUpdates;
  late TextEditingController _intervalController;

  @override
  void initState() {
    super.initState();
    _automaticUpdates = widget.automaticUpdates;
    // Convert seconds to minutes for display
    final minutes = widget.updateRefresh != null 
        ? (widget.updateRefresh! / 60).round() 
        : 30;
    _intervalController = TextEditingController(
      text: minutes.toString(),
    );
  }

  @override
  void didUpdateWidget(TripSettingsControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.automaticUpdates != widget.automaticUpdates) {
      _automaticUpdates = widget.automaticUpdates;
    }
    if (oldWidget.updateRefresh != widget.updateRefresh) {
      // Convert seconds to minutes for display
      final minutes = widget.updateRefresh != null 
          ? (widget.updateRefresh! / 60).round() 
          : 30;
      _intervalController.text = minutes.toString();
    }
  }

  @override
  void dispose() {
    _intervalController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final minutes = int.tryParse(_intervalController.text);
    if (_automaticUpdates && (minutes == null || minutes < 1)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid interval (minimum 1 minute)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Convert minutes to seconds for the backend
    final seconds = minutes != null ? minutes * 60 : null;
    widget.onSettingsChange(_automaticUpdates, seconds);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIsWeb = widget.isWeb ?? kIsWeb;

    // Only show on mobile (not web)
    if (effectiveIsWeb) {
      return const SizedBox.shrink();
    }

    // Only show for trip owners
    if (!widget.isOwner) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: WandererTheme.glassBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: WandererTheme.glassBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings,
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
                    decoration: InputDecoration(
                      labelText: 'Update Interval (minutes)',
                      hintText: 'e.g., 30',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: widget.isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WandererTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
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
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: WandererTheme.primaryOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
