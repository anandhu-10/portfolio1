import 'package:url_launcher/url_launcher.dart';

/// Native/non-web implementation of the reload helper.
void reloadApp() {
  // No-op on native/non-web platforms.
}

/// Native implementation of launchInNewTab.
void launchInNewTab(String url) async {
  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // ignore
  }
}
