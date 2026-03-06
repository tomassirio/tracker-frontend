import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Screen that displays the Privacy Policy from the bundled asset.
class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  String? _htmlContent;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content =
          await rootBundle.loadString('assets/legal/privacy_policy.html');
      if (mounted) {
        setState(() {
          _htmlContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load privacy policy.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _loadContent();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Strip HTML tags for a basic text rendering on mobile
    final plainText = _stripHtmlTags(_htmlContent ?? '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: SelectableText(
        plainText,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFF595959),
          height: 1.5,
        ),
      ),
    );
  }

  /// Strips HTML tags to produce readable plain text.
  String _stripHtmlTags(String html) {
    // Remove style and head blocks
    var text = html.replaceAll(
      RegExp(r'<style[^>]*>.*?</style>', dotAll: true),
      '',
    );
    text = text.replaceAll(
      RegExp(r'<head[^>]*>.*?</head>', dotAll: true),
      '',
    );

    // Replace common block elements with newlines
    text = text.replaceAll(RegExp(r'<br\s*/?>'), '\n');
    text = text.replaceAll(RegExp(r'</?(div|p|h[1-6])[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'<li[^>]*>'), '\n• ');
    text = text.replaceAll(RegExp(r'</li>'), '');
    text = text.replaceAll(RegExp(r'</?ul[^>]*>'), '\n');
    text = text.replaceAll(RegExp(r'</?ol[^>]*>'), '\n');

    // Remove all remaining HTML tags
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');

    // Decode HTML entities
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&#39;', "'");
    text = text.replaceAll('&nbsp;', ' ');

    // Clean up excessive whitespace
    text = text.replaceAll(RegExp(r' +'), ' ');
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    text = text.trim();

    return text;
  }
}
