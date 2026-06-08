import 'dart:js' as js;

/// Web implementation of the reload helper.
void reloadApp() {
  try {
    js.context['location'].callMethod('reload');
  } catch (e) {
    // ignore
  }
}

/// Web implementation of launchInNewTab to open url in a new tab without reloads.
void launchInNewTab(String url) {
  try {
    js.context.callMethod('open', [sanitizeUrl(url), '_blank']);
  } catch (e) {
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
