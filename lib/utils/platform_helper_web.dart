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
    js.context.callMethod('open', [url, '_blank']);
  } catch (e) {
    // ignore
  }
}
