import 'package:flutter/material.dart';

class ScrollControllerProvider extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  
  // 7 keys corresponding to 7 main UI sections
  final List<GlobalKey> sectionKeys = List.generate(7, (index) => GlobalKey());
  
  final List<String> sectionNames = [
    'Home',
    'About',
    'Skills',
    'Projects',
    'Certifications',
    'Experience',
    'Contact',
  ];

  int _activeSection = 0;
  int get activeSection => _activeSection;

  bool _isManualScroll = false;

  ScrollControllerProvider() {
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isManualScroll) return;
    
    // Find the section that is currently closest to the top of the viewport
    int newActive = 0;
    double minDiff = double.infinity;
    
    for (int i = 0; i < sectionKeys.length; i++) {
      final context = sectionKeys[i].currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize && box.attached) {
          try {
            final position = box.localToGlobal(Offset.zero);
            final dy = position.dy.abs();
            if (dy < minDiff) {
              minDiff = dy;
              newActive = i;
            }
          } catch (e) {
            // Guard against layout/attachment timing issues during rapid scrolling or resizing
          }
        }
      }
    }
    
    if (_activeSection != newActive) {
      _activeSection = newActive;
      notifyListeners();
    }
  }

  void scrollToSection(int index) {
    if (index < 0 || index >= sectionKeys.length) return;
    
    _isManualScroll = true;
    _activeSection = index;
    notifyListeners();

    final context = sectionKeys[index].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      ).then((_) {
        // Reset manual scroll override flag
        Future.delayed(const Duration(milliseconds: 100), () {
          _isManualScroll = false;
        });
      });
    } else {
      _isManualScroll = false;
    }
  }

  void updateActiveSection(int index) {
    if (_isManualScroll) return; // Prevent scroll observer from causing UI jitter while scrolling programmatically
    if (_activeSection != index) {
      _activeSection = index;
      notifyListeners();
    }
  }
}
