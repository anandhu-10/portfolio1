import 'dart:js' as js;

/// Web implementation of the reload helper.
void reloadApp() {
  try {
    js.context['location'].callMethod('reload');
  } catch (e) {
    // ignore
  }
}
