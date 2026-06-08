import 'package:url_launcher/url_launcher.dart';

/// Native/non-web implementation of the reload helper.
void reloadApp() {
  // No-op on native/non-web platforms.
}

/// Native implementation of launchInNewTab.
void launchInNewTab(String url) async {
  final Uri uri = Uri.parse(sanitizeUrl(url));
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // ignore
  }
}

String sanitizeUrl(String url) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('http://') ||
      lower.startsWith('https://') ||
      lower.startsWith('mailto:') ||
      lower.startsWith('tel:')) {
    return trimmed;
  }
  return 'https://$trimmed';
}
